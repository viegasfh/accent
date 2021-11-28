-- ACCENT 
-- 
-- A Compiler Compiler for the Entire Class of Context-Free Languages
-- 
-- Copyright (C) 1999  Friedrich Wilhelm Schroeer
-- 
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.


'module' code

'use' bnf

'export' fix_code

'action' Put(STRING)
'action' Nl

'action' fix_code
   
   'rule' fix_code

      Nl
      Put("extern YYSTYPE yylval;") Nl
      Put("YYSTYPE yylval;") Nl
      Put("extern long yypos;") Nl
      --Put("extern char * yytokenname;") Nl --xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      (|
         GentleFlag -> yes
         -- yypos is defined in grts
         Put("/* GentleFlag = yes */") Nl
      ||
         Put("long yypos = 1;") Nl
         --Put("char * yytokenname = \"notoken\";") Nl --xxxxxxxxxxxxxxxxxxxxx
         Put("/* GentleFlag = no */") Nl
      |)
      Put("") Nl
      Put("typedef struct LEXELEMSTRUCT {") Nl
      Put("   YYSTYPE val;") Nl
      Put("   long pos;") Nl
      Put("   long sym;") Nl
      Put("   char * text;") Nl --xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      Put("   struct LEXELEMSTRUCT *next;") Nl
      Put("} LEXELEM;") Nl
      Put("   ") Nl
      Put("LEXELEM *first_lexelem, *cur_lexelem;") Nl
      Put("") Nl
      Put("init_lexelem()") Nl
      Put("{") Nl
      Put("   cur_lexelem = first_lexelem;") Nl
      Put("}") Nl
      Put("") Nl
      Put("first_lexval () {") Nl
      Put("   LEXELEM *p;") Nl
      Put("   p = (LEXELEM *)malloc(sizeof(LEXELEM));") Nl
      Put("   if (! p) yymallocerror();") Nl
      Put("   p->val = yylval;") Nl
      Put("   p->pos = yypos;") Nl
      --Put("   p->text = yytokenname;") Nl --xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      Put("   p->next = 0;") Nl
      Put("   cur_lexelem = p;") Nl
      Put("   first_lexelem = p;") Nl
      Put("}") Nl
      Put("") Nl
      Put("next_lexval() {") Nl
      Put("   LEXELEM *p;") Nl
      Put("   p = (LEXELEM *)malloc(sizeof(LEXELEM));") Nl
      Put("   if (! p) yymallocerror();") Nl
      Put("   cur_lexelem-> next = p;") Nl
      Put("   p->val = yylval;") Nl
      Put("   p->pos = yypos;") Nl
      --Put("   p->text = yytokenname;") Nl --xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      Put("   p->next = 0;") Nl
      Put("   cur_lexelem = p;") Nl
      Put("}") Nl
      Put("") Nl
      Put("get_lexval() {") Nl
      Put("   extern int FREE_LEXELEMS;") Nl
      Put("   LEXELEM *p;") Nl -- xxx new
      Put("   yylval = cur_lexelem->val;") Nl
      Put("   yypos = cur_lexelem->pos;") Nl
      --Put("   yytokenname = cur_lexelem->text;") Nl --xxxxxxxxxxxxxxxxxxxxx
      --Put("   printf(\"<%s pos=\\\"%d\\\"/>\\n\", yytokenname, yypos);") Nl --xxxxxxxxxxxxxxxxxxxxx
      Put("   p = cur_lexelem;") Nl -- xxx new
      Put("   cur_lexelem = cur_lexelem->next;") Nl
      Put("   free(p);") Nl -- xxx new
      Put("}") Nl
      Nl
