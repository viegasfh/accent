"{" {   /* Code Blocks */

   int ch;
   int blocklevel = 1;

   yysetpos();


   ch = input(); yypos++;

   for(;;) {
      /* 1: eof */
      if (ch <= 0) {
	 yyerror("EOF inside action block");
	 break;
      }

      /* 2: strings, chars */
      else if (ch == '"' || ch == '\'') {
	 char this_terminator = ch;

	 AppendToString(this_terminator);
	 for(;;) {
	    ch = input(); yypos++;
	    if (ch <= 0) {
	       yyerror("EOF inside string");
	       break;
	    }
	    if (ch == '\\') { /* escape inside string */
               ch = input(); yypos++;
	       if (ch <= 0) {
		  yyerror("EOF inside string");
		  break;
	       }
	       AppendToString('\\');
	       AppendToString(ch);
               if (ch == '\n') yyPosToNextLine();
	    }
	    else if (ch == this_terminator) {
	       break;
	    }
	    else {
	       AppendToString(ch);
               if (ch == '\n') yyPosToNextLine();
            }
	 }
	 AppendToString(this_terminator);
         ch = input(); yypos++;
      }

      /* 3: escaped characters */
      else if (ch == '\\') {
	 ch = input(); yypos++;
	 if (ch <= 0) {
	    yyerror("EOF inside action block");
	    break;
	 }
	 AppendToString('\\');
	 AppendToString(ch);
         if (ch == '\n') yyPosToNextLine();
         ch = input(); yypos++;
      }

      /* 4: nested action block */
      else if (ch == '{') {
	 blocklevel++;
	 AppendToString(ch);
         ch = input(); yypos++;
      }

      /* 5: end of (nested ?) action block */
      else if (ch == '}') {
	 blocklevel--;
	 if (blocklevel == 0) {
	    char *str;
	    GetStringRef(&str);
	    yylval.attr[1] = (long) str;
	    return CodeBlock;
	 }
	 else {
	    AppendToString(ch);
            ch = input(); yypos++;
	 }
      }

      /* 6: comment ? */
      else if (ch == '/') {
	 AppendToString('/');
	 ch = input(); yypos++;
	 if (ch == '*') { /* "/*"comment */
	    AppendToString('*');
	    ch = input(); yypos++;
	    for(;;) {
	       AppendToString(ch);
	       if (ch == '\n') {
		  AppendToString(ch);
		  yyPosToNextLine();
	       }
	       ch = input(); yypos++;
	       if (ch == '*') {
		  do {
	             AppendToString(ch);
		     ch = input(); yypos++;
		  } while (ch == '*');
		  if (ch == '/') {
	             AppendToString(ch);
                     ch = input(); yypos++;
		     break;
		  }
	       }
	       else if (ch <= 0) {
		  yyerror("EOF inside comment");
		  break;
	       }
	    }
	 }
	 else if (ch == '/') { /* "//" comment */
	    for(;;) {
	       AppendToString(ch);
	       ch = input(); yypos++;
	       if (ch == '\n') {
		  AppendToString(ch);
                  ch = input();
		  yyPosToNextLine();
		  break;
	       }
	       else if (ch <= 0) {
		  yyerror("EOF inside comment");
		  break;
	       }
	    }
	 }
	 else {
            AppendToString(ch);
            ch = input(); yypos++;
	 }
      }

      /* 7: else */
      else {
         AppendToString(ch);
         if (ch == '\n') {
            yyPosToNextLine();
         }
         ch = input(); yypos++;
      }
   }
}
