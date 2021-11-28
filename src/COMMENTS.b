"//" {   /* C++ style comment */
   yypos += 2;
   for(;;) {
      int ch = input(); yypos++;
      if (ch == '\n') {
	 yyPosToNextLine();
	 break;
      }
      else if (ch <= 0) {
	 yyerror("EOF inside comment");
	 break;
      }
   }
}
"/*" { /* C style comment with nesting */
   int nesting = 1;
   int start;
   char ch;
   start = yypos+1;
   yypos += 2;
   ch = input();
   yypos++;
   
   for (;;) {
      if (ch == '\n') yyPosToNextLine();
      /* begin of comment ? */
      if (ch == '/') {
         ch = input();
         yypos++;
         if (ch == '*') {
            ch = input();
            yypos++;
            nesting++;
         }
      }
      /* end of comment ? */
      else if (ch == '*') {
         ch = input();
         yypos++;
         if (ch == '/') {
            nesting--;
            if (nesting == 0) break;
         }
      }
      else if (ch == -1) {
         yypos = start;
         yyerror("EOF inside comment");
      }
      else {
         ch = input();
         yypos++;
      }
   }
}
