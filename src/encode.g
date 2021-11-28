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


'module' encode
'use'
   bnf
   lexinfo

'export'
   INIT_ENCODE

   START_RULE
   END_RULE
   ADD_NONTERM_MEMBER
   ADD_TOKEN_MEMBER
   ADD_SUBPHRASE_REFERENCE
   START_ALTERNATIVE
   END_ALTERNATIVE

   ENCODE

   OpenOutput
   CloseOutput
   PutI
   Put
   Nl

   LHSKEYS
   LHSKEY
   LHS_List
   LHS
   CLAUSEKEYS
   CLAUSEKEY
   ELEMS
   GRAMMARREF

   TableUpb2

--------------------------------------------------------------------------------

'var' LHS_List: LHSKEYS

'type' LHSKEYS
   keys(LHSKEYS, LHSKEY)
   nil

'table' LHSKEY
   (Lhs: LHS, RulePrelude: ACTIONBLOCK, Clauses: CLAUSEKEYS, Pos: INT,
   NontermNumber: INT -- xxxx
   )

'type' CLAUSEKEYS
   clausekeys(CLAUSEKEYS, CLAUSEKEY)
   nil

'table' CLAUSEKEY (
   Elems: ELEMS,
   GrammarRef: GRAMMARREF,
   Pos: INT,
   RuleAnnotation: RULEANNOTATION,
   Coordinate: POS,
   RuleHandle: INT, Number: INT, LhsPos: INT, NextClausePos: INT
   )

'type' GRAMMARREF
   members(MEMBERLIST)
   none

'type' ELEMS
   elems(ELEMS, ELEM)
   nil

'type' ELEM
   nonterm(IDENT, MEMBERANNOTATION, POS)
   token(INT)
   subphrase(SUBPHRASEKEY, MEMBERANNOTATION, POS)
   
'type' LHS
   nonterm(IDENT)
   subphrase(SUBPHRASEKEY)

--------------------------------------------------------------------------------

'var' term_base: INT
'var' start_user_grammar: INT

'action' INIT_ENCODE
'rule' INIT_ENCODE
   term_base <- 50000
   start_user_grammar <- 8
   LHS_List <- nil
   get_max_char(-> MAXCHAR)
   TABLEUPB2 <- MAXCHAR
   init_ana

'action' ENCODE
'rule' ENCODE

   NontermList -> L
   PC <- 1

   LHS_List -> LhsKeys
   calc_positions_LHSKEYS(LhsKeys)

   -- OpenOutput("yygrammar.c")
   PC -> N

   Put("extern int c_length;")
   Nl
   Put("int c_length = ")
   PutI(N-1)
   Put(";")
   Nl


   Put("extern int yygrammar[];") Nl
   Put("int yygrammar[] = {") Nl
   Put("0,") Nl

   -- xxx encode_root_rule
   FieldIndex <- 1
   write_code_LHSKEYS(LhsKeys)

   Put("0") Nl
   Put("};") Nl

   -- annotation

   Put("extern int yyannotation[];") Nl
   Put("int yyannotation[] = {") Nl
   Put("0,") Nl

   FieldIndex <- 1
   write_annotation_LHSKEYS(LhsKeys)
   Put("0") Nl
   Put("};") Nl

   -- coordinates

   Put("extern int yycoordinate[];") Nl
   Put("int yycoordinate[] = {") Nl
   Put("0,") Nl

   FieldIndex <- 1
   write_coordinates_LHSKEYS(LhsKeys)
   Put("0") Nl
   Put("};") Nl

   run_ana


   Put("/* only for BIGHASH (see art.c)") Nl
   Put("extern int DHITS[];") Nl
   Put("int DHITS[") PutI(N+1) Put("];") Nl
   Put("*/") Nl

   get_rulecount(-> Upb1)
   TABLEUPB2 -> Upb2
   Put("int TABLE[") PutI(Upb1+1) Put("][") PutI(Upb2+1) Put("];") Nl
   Put("init_dirsets() {") Nl
   write_dir_sets_LHSKEYS(LhsKeys)
   Put("}") Nl
   Nl
   Put("extern int yydirset();") Nl
   Put("int yydirset(i,j)") Nl
   Put("   int i,j;") Nl
   Put("{") Nl
   Put("   return TABLE[i][j];") Nl
   Put("}") Nl

   write_transparent

   write_printnames

'action' get_rulecount(-> INT)

--------------------------------------------------------------------------------

'var' CurLhs: LHSKEY
'var' CurClause: CLAUSEKEY

'action' START_RULE
   (IDENT, NONTERMKEY, INT, RULEKEY, ACTIONBLOCK, RULEANNOTATION, POS)
'rule' START_RULE(Id, NKey, N, RKey, Prelude, Annotation, Coordinate)
   RKey'RuleNumber -> R
   id_to_string(Id -> Str)
   start_rule (N -> RuleHandle)
   RKey'RuleHandle <- RuleHandle

   LhsKeyForNonterm(Id -> LhsKey)
   LhsKey'NontermNumber <- N
   CurLhs <- LhsKey
   ClauseKey :: CLAUSEKEY
   ClauseKey'Elems <- nil
   CurClause <- ClauseKey
   ClauseKey'RuleHandle <- RuleHandle

   ClauseKey'Number <- R

   RKey'Members -> Members
   ClauseKey'GrammarRef <- members(Members)
   ClauseKey'RuleAnnotation <- Annotation
   ClauseKey'Coordinate <- Coordinate

   LhsKey'RulePrelude <- Prelude
   LhsKey'Clauses -> Clauses
   LhsKey'Clauses <- clausekeys(Clauses,ClauseKey)

'action' END_RULE
'rule' END_RULE

'action' ADD_NONTERM_MEMBER(IDENT, INT, MEMBERANNOTATION, POS)
'rule' ADD_NONTERM_MEMBER(Id, N, Annotation, Coordinate)
   append_nonterm_member(N)

   CurClause -> ClauseKey
   ClauseKey'Elems -> Elems
   ClauseKey'Elems <-  elems(Elems, nonterm(Id, Annotation, Coordinate))

'action' ADD_TOKEN_MEMBER(INT)
'rule' ADD_TOKEN_MEMBER(N)
   append_token_member(N)

   CurClause -> ClauseKey
   ClauseKey'Elems -> Elems
   ClauseKey'Elems <-  elems(Elems, token(N))

'action' ADD_SUBPHRASE_REFERENCE(SUBPHRASEKEY, MEMBERANNOTATION, POS)
'rule' ADD_SUBPHRASE_REFERENCE(Key, Annotation, Pos)
   Key'SubphraseNumber -> N
   NumberOfNonterms(-> NNo)
   where(N+NNo -> SNo)
   append_nonterm_member(SNo)

   CurClause -> ClauseKey
   ClauseKey'Elems -> Elems
   ClauseKey'Elems <- elems(Elems, subphrase(Key, Annotation, Pos))

'action' START_ALTERNATIVE
      (SUBPHRASEKEY, ALTERNATIVEKEY, GRAMMARREF, RULEANNOTATION, POS)
'rule' START_ALTERNATIVE(SKey, AKey, GrammarRef, Annotation, Coordinate)
   SKey'SubphraseNumber -> SubphraseNumber
   NumberOfNonterms(-> NNont)
   where(SubphraseNumber+NNont -> SNo)
   AKey'AlternativeNumber -> N
   NumberOfRules(-> NRules)
   where(N+NRules -> ANo)
   start_rule(SNo -> RuleHandle)
   AKey'RuleHandle <- RuleHandle

   LhsKeyForSubphrase(SKey -> LhsKey)
   CurLhs <- LhsKey
   LhsKey'NontermNumber <- SNo
   ClauseKey :: CLAUSEKEY
   AKey'ClauseKey <- ClauseKey
   ClauseKey'Elems <- nil
   CurClause <- ClauseKey
   ClauseKey'RuleHandle <- RuleHandle
   ClauseKey'Number <- ANo

   ClauseKey'GrammarRef <- GrammarRef
   ClauseKey'RuleAnnotation <- Annotation
   ClauseKey'Coordinate <- Coordinate

   LhsKey'Clauses -> Clauses
   LhsKey'Clauses <- clausekeys(Clauses,ClauseKey)

'action' END_ALTERNATIVE
'rule' END_ALTERNATIVE

--------------------------------------------------------------------------------

--
-- Interface to Rule Analysis
--


-- Init

'action' init_ana

-- Grammar Definition

'action' start_rule (Lhs: INT -> RuleId: INT)
'action' append_nonterm_member(Member: INT)
'action' append_token_member(Member: INT)

-- Analysis

'action' run_ana
-- compute director set for each rule

-- Access Result

'action' get_dirset(RuleId: INT -> DirSet: SET)

-- sets:
'type' SET
'action' emit_set(SET)

--------------------------------------------------------------------------------

--
-- Emit Results
--

'action' OpenOutput(STRING)
'action' CloseOutput
'action' Put(STRING)
'action' PutI(INT)
'action' Nl

--------------------------------------------------------------------------------

'var' PC: INT
'var' LastClauseKey: CLAUSEKEY
'var' CurLhsPos: INT

'action' calc_positions_LHSKEYS(LHSKEYS)

   'rule' calc_positions_LHSKEYS(keys(Keys,Key))
      calc_positions_LHSKEYS(Keys)
      calc_positions_LHSKEY(Key)
   'rule' calc_positions_LHSKEYS(nil)

'action' calc_positions_LHSKEY(LHSKEY)

   'rule' calc_positions_LHSKEY(Key)
      Key'Clauses -> Clauses
      PC -> Pos
      Key'Pos <- Pos
      CurLhsPos <- Pos
      calc_positions_CLAUSEKEYS(Clauses)
      LastClauseKey -> LastClause
      LastClause'NextClausePos <- 0

'action' calc_positions_CLAUSEKEYS(CLAUSEKEYS)
   'rule' calc_positions_CLAUSEKEYS(clausekeys(Clauses, Clause))
      calc_positions_CLAUSEKEYS(Clauses)
      calc_positions_CLAUSEKEY(Clause)
   'rule' calc_positions_CLAUSEKEYS(nil)

'action' calc_positions_CLAUSEKEY(CLAUSEKEY)
   'rule' calc_positions_CLAUSEKEY(Key)
      PC -> Pos
      Key'Elems -> Elems
      Length(Elems -> N)
      where(Pos+N+3 -> NextPos)
      PC <- NextPos
      LastClauseKey <- Key
      Key'Pos <- Pos
      Key'NextClausePos <- NextPos
      CurLhsPos -> LhsPos
      Key'LhsPos <- LhsPos

'action' Length(ELEMS -> INT)
   'rule' Length(elems(Elems, Elem) -> N+1)
      Length(Elems -> N)
   'rule' Length(nil -> 0)

--------------------------------------------------------------------------------

'action' write_code_LHSKEYS(LHSKEYS)

   'rule' write_code_LHSKEYS(keys(Keys,Key))
      write_code_LHSKEYS(Keys)
      write_code_LHSKEY(Key)
   'rule' write_code_LHSKEYS(nil)

'action' write_code_LHSKEY(LHSKEY)

   'rule' write_code_LHSKEY(Key)
      Key'Clauses -> Clauses
      write_code_CLAUSEKEYS(Clauses)

'action' write_code_CLAUSEKEYS(CLAUSEKEYS)
   'rule' write_code_CLAUSEKEYS(clausekeys(Clauses, Clause))
      write_code_CLAUSEKEYS(Clauses)
      write_code_CLAUSEKEY(Clause)
   'rule' write_code_CLAUSEKEYS(nil)

'action' write_code_CLAUSEKEY(CLAUSEKEY)
   'rule' write_code_CLAUSEKEY(Key)
      Key'Elems -> Elems

      Key'NextClausePos -> Chain
      set_field(Chain)

      write_code_ELEMS(Elems)

      Key'LhsPos -> LhsPos
      set_field(-LhsPos)

      Key'Number -> RuleNumber
      set_field(RuleNumber)

'action' write_code_ELEMS(ELEMS)
   'rule' write_code_ELEMS(elems(Elems, Elem))
      write_code_ELEMS(Elems)
      write_code_ELEM(Elem)
   'rule' write_code_ELEMS(nil)

'action' write_code_ELEM(ELEM)
   'rule' write_code_ELEM(nonterm(Id,_,_))
      LhsKeyForNonterm(Id -> LhsKey)
      LhsKey'Pos -> Pos
      set_field(Pos)
   'rule' write_code_ELEM(token(N))
      term_base -> TERMBASE
      set_field(N+TERMBASE)
   'rule' write_code_ELEM(subphrase(SKey,_,_))
      LhsKeyForSubphrase(SKey -> LhsKey)
      LhsKey'Pos -> Pos
      set_field(Pos)

'var' FieldIndex: INT

'action' set_field(INT)
   'rule' set_field(N)
      FieldIndex -> X
      Put("/* ") PutI(X) Put(" */ ") PutI(N) Put(",") Nl
      FieldIndex <- X+1

--------------------------------------------------------------------------------

'action' write_annotation_LHSKEYS(LHSKEYS)

   'rule' write_annotation_LHSKEYS(keys(Keys,Key))
      write_annotation_LHSKEYS(Keys)
      write_annotation_LHSKEY(Key)
   'rule' write_annotation_LHSKEYS(nil)

'action' write_annotation_LHSKEY(LHSKEY)

   'rule' write_annotation_LHSKEY(Key)
      Key'Clauses -> Clauses
      write_annotation_CLAUSEKEYS(Clauses)

'action' write_annotation_CLAUSEKEYS(CLAUSEKEYS)
   'rule' write_annotation_CLAUSEKEYS(clausekeys(Clauses, Clause))
      write_annotation_CLAUSEKEYS(Clauses)
      write_annotation_CLAUSEKEY(Clause)
   'rule' write_annotation_CLAUSEKEYS(nil)

'action' write_annotation_CLAUSEKEY(CLAUSEKEY)
   'rule' write_annotation_CLAUSEKEY(Key)
      Key'Elems -> Elems

      Key'NextClausePos -> Chain
      set_field(Chain)

      write_annotation_ELEMS(Elems)

      Key'LhsPos -> LhsPos
      set_field(-LhsPos)

      Key'RuleAnnotation -> Annotation
      (|
	 where(Annotation -> prio(N))
         set_field(N)
      ||
	 where(Annotation -> undefruleanno)
	 set_field(-1)
      |)

'action' write_annotation_ELEMS(ELEMS)
   'rule' write_annotation_ELEMS(elems(Elems, Elem))
      write_annotation_ELEMS(Elems)
      write_annotation_ELEM(Elem)
   'rule' write_annotation_ELEMS(nil)

'action' write_annotation_ELEM(ELEM)
   'rule' write_annotation_ELEM(nonterm(Id, Annotation,_))
      (|
	 where(Annotation -> short)
	 set_field(1)
      ||
	 where(Annotation -> long)
	 set_field(2)
      ||
	 where(Annotation -> undefmemberanno)
	 set_field(0)
      ||
	 where(Annotation -> user(N))
	 set_field(-N)
      |)
   'rule' write_annotation_ELEM(token(N))
      term_base -> TERMBASE
      set_field(N+TERMBASE)
   'rule' write_annotation_ELEM(subphrase(SKey,Annotation,_))
      (|
	 where(Annotation -> short)
	 set_field(1)
      ||
	 where(Annotation -> long)
	 set_field(2)
      ||
	 where(Annotation -> undefmemberanno)
	 set_field(0)
      ||
	 where(Annotation -> user(N))
	 set_field(-N)
      |)

--------------------------------------------------------------------------------

'action' write_coordinates_LHSKEYS(LHSKEYS)

   'rule' write_coordinates_LHSKEYS(keys(Keys,Key))
      write_coordinates_LHSKEYS(Keys)
      write_coordinates_LHSKEY(Key)
   'rule' write_coordinates_LHSKEYS(nil)

'action' write_coordinates_LHSKEY(LHSKEY)

   'rule' write_coordinates_LHSKEY(Key)
      Key'Clauses -> Clauses
      write_coordinates_CLAUSEKEYS(Clauses)

'action' write_coordinates_CLAUSEKEYS(CLAUSEKEYS)
   'rule' write_coordinates_CLAUSEKEYS(clausekeys(Clauses, Clause))
      write_coordinates_CLAUSEKEYS(Clauses)
      write_coordinates_CLAUSEKEY(Clause)
   'rule' write_coordinates_CLAUSEKEYS(nil)

'action' write_coordinates_CLAUSEKEY(CLAUSEKEY)
   'rule' write_coordinates_CLAUSEKEY(Key)
      Key'Elems -> Elems

      Key'NextClausePos -> Chain
      set_field(9999)

      write_coordinates_ELEMS(Elems)

      Key'LhsPos -> LhsPos
      set_field(9999)

      Key'Coordinate -> Coordinate
      POS_to_INT(Coordinate -> N)
      set_field(N)

'action' write_coordinates_ELEMS(ELEMS)
   'rule' write_coordinates_ELEMS(elems(Elems, Elem))
      write_coordinates_ELEMS(Elems)
      write_coordinates_ELEM(Elem)
   'rule' write_coordinates_ELEMS(nil)

'action' write_coordinates_ELEM(ELEM)
   'rule' write_coordinates_ELEM(nonterm(Id, Annotation, Coordinate))
      POS_to_INT(Coordinate -> N)
      set_field(N)
   'rule' write_coordinates_ELEM(token(N))
      set_field(9999)
   'rule' write_coordinates_ELEM(subphrase(SKey, _, Coordinate))
      POS_to_INT(Coordinate -> N)
      set_field(N)

--------------------------------------------------------------------------------

'action' write_dir_sets_LHSKEYS(LHSKEYS)

   'rule' write_dir_sets_LHSKEYS(keys(Keys,Key))
      write_dir_sets_LHSKEYS(Keys)
      write_dir_sets_LHSKEY(Key)
   'rule' write_dir_sets_LHSKEYS(nil)

'action' write_dir_sets_LHSKEY(LHSKEY)

   'rule' write_dir_sets_LHSKEY(Key)
      Key'Clauses -> Clauses
      write_dir_sets_CLAUSEKEYS(Clauses)

'action' write_dir_sets_CLAUSEKEYS(CLAUSEKEYS)
   'rule' write_dir_sets_CLAUSEKEYS(clausekeys(Clauses, Clause))
      write_dir_sets_CLAUSEKEYS(Clauses)
      write_dir_sets_CLAUSEKEY(Clause)
   'rule' write_dir_sets_CLAUSEKEYS(nil)

'action' write_dir_sets_CLAUSEKEY(CLAUSEKEY)
   'rule' write_dir_sets_CLAUSEKEY(Key)
      Key'Number -> K
      Key'RuleHandle -> Handle
      get_dirset(Handle -> Set)
      write_set(K, Set)

--------------------------------------------------------------------------------
'action' write_transparent
'rule' write_transparent
   LHS_List -> LhsKeys
   Put("int yytransparent(n)") Nl
   Put("   int n;") Nl
   Put("{") Nl
   Put("   switch(n) {") Nl
   write_transparent_LHSKEYS(LhsKeys,1)
   Put("   }") Nl
   Put("}") Nl

'action' write_transparent_LHSKEYS(LHSKEYS, INT)

   'rule' write_transparent_LHSKEYS(keys(Keys,Key), N)
      write_transparent_LHSKEYS(Keys, N+1)
      write_transparent_LHSKEY(Key, N)
   'rule' write_transparent_LHSKEYS(nil, _)

'action' write_transparent_LHSKEY(LHSKEY, INT)

   'rule' write_transparent_LHSKEY(Key, N)
      Key'Lhs -> Lhs
      Key'Pos -> Pos

      Put("      case ")
      PutI(Pos)
      Put(": return ")
      Key'NontermNumber -> NN
      get_transparent(NN -> Val)
      PutI(Val)
      Put("; break;")
      Nl

'action' get_transparent(INT -> INT)

--------------------------------------------------------------------------------
'action' write_set(INT, SET)
--------------------------------------------------------------------------------

'action' encode_root_rule
'rule' encode_root_rule
    set_field(0)
    start_user_grammar -> STARTUSERGRAMMAR
    set_field(STARTUSERGRAMMAR)
    term_base -> TERMBASE
    set_field(TERMBASE)
    set_field(-1)
    set_field(0)

    set_field(1234)
    set_field(5678)

--------------------------------------------------------------------------------

'action' LhsKeyForNonterm(IDENT -> LHSKEY)

   'rule' LhsKeyForNonterm(Id -> K)
      LHS_List -> L
      lookup_Id(L, Id -> K)

'action' lookup_Id(LHSKEYS, IDENT -> LHSKEY)
   'rule' lookup_Id(keys(Keys, Key), Id -> K):
      (|
         Key'Lhs -> nonterm(Id0)
	 eq(Id, Id0)
	 where(Key -> K)
      ||
	 lookup_Id(Keys, Id -> K)
      |)
   'rule' lookup_Id(nil, Id -> K)
      K :: LHSKEY
      K'Lhs <- nonterm(Id)
      K'Clauses <- nil

      LHS_List -> List
      LHS_List <- keys(List, K)

--------------------------------------------------------------------------------

'action' LhsKeyForSubphrase(SUBPHRASEKEY -> LHSKEY)

   'rule' LhsKeyForSubphrase(Id -> K)
      LHS_List -> L
      lookup_Subphrase(L, Id -> K)

'action' lookup_Subphrase(LHSKEYS, SUBPHRASEKEY -> LHSKEY)
   'rule' lookup_Subphrase(keys(Keys, Key), Id -> K):
      (|
         Key'Lhs -> subphrase(Id0)
	 eq(Id, Id0)
	 where(Key -> K)
      ||
	 lookup_Subphrase(Keys, Id -> K)
      |)
   'rule' lookup_Subphrase(nil, Id -> K)
      K :: LHSKEY
      K'Lhs <- subphrase(Id)
      K'Clauses <- nil

      LHS_List -> List
      LHS_List <- keys(List, K)

--------------------------------------------------------------------------------

'action' write_printnames
'rule' write_printnames
   LHS_List -> LhsKeys
   Put("char * yyprintname(n)") Nl
   Put("   int n;") Nl
   Put("{") Nl
   term_base -> TERMBASE
   Put("   if (n <= ") PutI(TERMBASE)Put (")") Nl
   Put("      switch(n) {") Nl
   write_nonterms_LHSKEYS(LhsKeys)
   Put("   }") Nl


   Put("   else ") Nl
   Put("      switch(n-") PutI(TERMBASE) Put(") {") Nl
   lex_printnames
   Put("      }") Nl
   Put("   return \"special_character\";") Nl
   Put("}") Nl

'action' write_nonterms_LHSKEYS(LHSKEYS)

   'rule' write_nonterms_LHSKEYS(keys(Keys,Key))
      write_nonterms_LHSKEYS(Keys)
      write_nonterms_LHSKEY(Key)
   'rule' write_nonterms_LHSKEYS(nil)

'action' write_nonterms_LHSKEY(LHSKEY)

   'rule' write_nonterms_LHSKEY(Key)
      Key'Lhs -> Lhs
      Key'Pos -> Pos

      Put("         case ")
      PutI(Pos)
      Put(": return \"")
      (|
	 where(Lhs -> nonterm(Id))
	 id_to_string(Id -> Str)
	 Put(Str)
      ||
	 where(Lhs -> subphrase(Sub))
	 Put("Subphrase")
      |)
      Put("\"; break;")
      Nl

'action' POS_to_INT (POS -> INT)

'var' TABLEUPB2: INT

'action' TableUpb2(INT)

   'rule' TableUpb2(N)
      TABLEUPB2 -> Old
      [|
	 gt(N, Old)
	 TABLEUPB2 <- N
      |]
