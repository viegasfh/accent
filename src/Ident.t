[A-Za-z][A-Za-z0-9_]* { 
   long id;
   string_to_id (yytext, &id);
   yylval.attr[1] = id;
   yysetpos();
   return Ident;
}
