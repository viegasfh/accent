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


'module' lexinfo

'use'
   bnf
   encode

'export'
   init_lexinfo
   enter_token
   enter_literal
   lexinfo
   lex_printnames

'action' init_lexinfo
   'rule' init_lexinfo
      Tokens <- nil
      Literals <- nil

'var' Tokens: TKNLIST
'var' Literals: LITLIST

'type' TKNLIST 
   list(TKN, TKNLIST)
   nil

'type' TKN
   token(IDENT, INT)

'type' LITLIST
   list(LIT, LITLIST)
   nil

'type' LIT
   literal(STRING, INT)

'action' enter_token(IDENT, INT)
   'rule' enter_token(Id, N)
      Tokens -> L
      Tokens <- list(token(Id, N), L)

'action' enter_literal(STRING, INT)
   'rule' enter_literal(Str, N)
      Literals -> L
      Literals <- list(literal(Str, N), L)

'action' lexinfo

'rule' lexinfo
   OpenOutput("yygrammar.h")
   Put("#ifndef YYSTYPE") Nl
   Put("#define YYSTYPE long") Nl
   Put("#endif") Nl
   Put("extern YYSTYPE yylval;") Nl
   Put("extern long yypos;") Nl
   Nl

   Tokens -> TL
   <*
      where(TL -> list(Head, Tail))
      where(Head -> token(Id, N))
      id_to_string(Id -> Str)
      Put("#define ")
      Put(Str)
      Put(" ")
      PutI(N)
      Nl
      wherenext(Tail -> TL)
   *>

   Literals -> LL
   <*
      where(LL -> list(Head, Tail))
      where(Head -> literal(Str, N))
      Put("#define yytoken_")
      PutI(N)
      Put(" ")
      PutI(N)
      Nl

      wherenext(Tail -> LL)
   *>
   CloseOutput

'action' lex_printnames
'rule' lex_printnames

   -- output to yysym.c

   Tokens -> TL
   <*
      where(TL -> list(Head, Tail))
      where(Head -> token(Id, N))
      Put("         case ")
      PutI(N)
      Put(": return \"")
      id_to_string(Id -> Str)
      Put(Str)
      Put("\"; break;") Nl

      wherenext(Tail -> TL)
   *>

   Literals -> LL
   <*
      where(LL -> list(Head, Tail))
      where(Head -> literal(Str, N))
      Put("         case ")
      PutI(N)
      Put(": return \"")
      Put(Str)
      Put("\"; break;") Nl

      wherenext(Tail -> LL)
   *>
