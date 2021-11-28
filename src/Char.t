'\\.' {
   char ch;
   switch (yytext[2]) {
   case 'n' :
      ch = '\n';
      break;
   case 't' :
      ch = '\t';
      break;
   case 'v' :
      ch = '\v';
      break;
   case 'b' :
      ch = '\b';
      break;
   case 'r' :
      ch = '\r';
      break;
   case 'f' :
      ch = '\f';
      break;
   case 'a' :
      ch = '\a';
      break;
   case '\\' :
      ch = '\\';
      break;
   case '?' :
      ch = '\?';
      break;
   case '\'' :
      ch = '\'';
      break;
   case '"' :
      ch = '\"';
      break;
   default :
      ch = yytext[2];
   }
   yylval.attr[1] = ch;
   yysetpos();
   return Char;
}
'.' {
   yylval.attr[1] = yytext[1];
   yysetpos();
   return Char;
}
