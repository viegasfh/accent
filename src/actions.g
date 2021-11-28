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


'module' actions

'use'
   bnf
   encode
   verbose
   code

'export'
   put_actions

'action' put_actions
   'rule' put_actions

      GrammarClass <- cfg
      -- GrammarClass <- ll1

      PreludeBlock -> Blk
      put_CodeBlock("", Blk, "")

      Put("#include \"yygrammar.h\"") Nl


      (|
	 GrammarClass -> cfg
      ||
	 Put("int yycursym;")
      |)
      init_indentation
      LabelCount <- 1
      LHS_List -> Keys
      -- put_fwd_decl_LHSKEYS(Keys)
      put_actions_LHSKEYS(Keys)

      fix_code

'var' GrammarClass: GRAMMARCLASS

'type' GRAMMARCLASS
   ll1
   cfg

---

/* forward decls (C++) 
'action'  put_fwd_decl_LHSKEYS(LHSKEYS)
   'rule' put_fwd_decl_LHSKEYS(keys(Keys, Key))
      put_fwd_decl_LHSKEYS(Keys)
      put_fwd_decl_LHSKEY(Key)
   'rule' put_fwd_decl_LHSKEYS(nil)

'action' put_fwd_decl_LHSKEY(LHSKEY)
   'rule' put_fwd_decl_LHSKEY(Key)

      Key'Lhs -> Lhs
      [|
         -- put LHS

	 where(Lhs -> nonterm(Id))
	 HasMeaning(Id -> nontermobj(_,_,FP))
	 Nl
	 id_to_string(Id -> Str)
	 Put(Str)
	 Put(" (")
	 handle_formal_params(FP)
	 Put(")")
	 Put(";")
	 Nl
      |]
      */
---

'action'  put_actions_LHSKEYS(LHSKEYS)
   'rule' put_actions_LHSKEYS(keys(Keys, Key))
      put_actions_LHSKEYS(Keys)
      put_actions_LHSKEY(Key)
   'rule' put_actions_LHSKEYS(nil)

'action' put_actions_LHSKEY(LHSKEY)
   'rule' put_actions_LHSKEY(Key)

      Key'Lhs -> Lhs
      [|
         -- put LHS

	 where(Lhs -> nonterm(Id))
	 HasMeaning(Id -> nontermobj(_,_,FP))
	 Nl
	 id_to_string(Id -> Str)
	 Put(Str)
	 Put(" (")
	 handle_formal_params_1(FP)
	 Put(")")
	 Nl
	 LocalNames <- nil
	 handle_formal_params_2(FP)

         -- put RHS

         Key'Clauses -> Clauses
	 Put("{") Nl
	 indentation(+1)

	 local_declarations(Clauses)

	 Key'RulePrelude -> Prelude
	 put_CodeBlock("", Prelude, "")

	 (|
	    GrammarClass -> cfg
	    indent
	    Put("switch(yyselect()) {")
	    Nl
	 ||
	    indent
	 |)
         put_actions_for_nonterm_CLAUSEKEYS(Clauses)
	 (|
	    GrammarClass -> cfg
	    indent
	    Put("}") Nl
	 ||
	    -- "indent" called already
	    Put("yysyntaxerror();")
	    Nl
	 |)
	 indentation(-1)
	 indent
	 Put("}") Nl
      |]

'action' put_actions_for_nonterm_CLAUSEKEYS(CLAUSEKEYS)
   'rule' put_actions_for_nonterm_CLAUSEKEYS(clausekeys(Keys, Key))
      put_actions_for_nonterm_CLAUSEKEYS(Keys)
      put_actions_for_nonterm_CLAUSEKEY(Key)
   'rule' put_actions_for_nonterm_CLAUSEKEYS(nil)

'action' put_actions_for_nonterm_CLAUSEKEY(CLAUSEKEY)
   'rule' put_actions_for_nonterm_CLAUSEKEY(ClauseKey)
      ClauseKey'GrammarRef -> members(Members)
      ClauseKey'Number -> Number
      (|
	 GrammarClass -> cfg
	 indent
	 Put("case ")
	 PutI(Number)
	 Put(": {")
	 Nl
      ||
	 -- "indent" called already
	 Put("if (TABLE[")
	 PutI(Number)
	 Put("][yycursym]) {")
	 Nl
      |)

      indentation(+1)
      put_actions_MEMBERLIST(Members)
      (|
	 GrammarClass -> cfg
         indent
         Put("} break;") Nl
         indentation(-1)
      ||
         indentation(-1)
	 indent
	 Put("} else ")
	 -- no Newline
      |)

'action' put_actions_MEMBERLIST(MEMBERLIST)
   'rule' put_actions_MEMBERLIST(list(H, T))
      put_actions_MEMBER(H)
      put_actions_MEMBERLIST(T)
   'rule' put_actions_MEMBERLIST(nil)

'action' put_actions_MEMBER(MEMBER)
   'rule' put_actions_MEMBER(call(Id, Params, _, Pos))
      id_to_string(Id -> Str)
      (|
	 HasMeaning(Id -> tokenobj(N, FParams))
	 (|
	    GrammarClass -> cfg
	    indent
	    Put("get_lexval();")
	    Nl
	 ||
	    indent
	    Put("yycheck(")
	    PutI(N)
	    Put(");")
	    Nl
	 |)

	 handle_token_params(Params, FParams, 1)
	 (|
	    GrammarClass -> cfg
	 ||
	    indent
	    Put("yycursym = yylex();")
	    Nl
	 |)
      ||
	 HasMeaning(Id -> nontermobj(_,_,Formals))
	 indent
	 Put(Str)
	 Put("(")
	 handle_actual_params(Params, Formals)
	 Put(");")
	 Nl
      |)
   'rule' put_actions_MEMBER(token(N))
      (|
	 GrammarClass -> cfg
	 -- xxx
	 indent
	 Put("get_lexval();")
	 Nl
      ||
	 indent
	 Put("yycheck(")
	 PutI(N)
	 Put(");")
	 Nl
	 indent
	 Put("yycursym = yylex();")
	 Nl
      |)

   'rule' put_actions_MEMBER
      (subphrase(option, Alternatives, Key, _, Coordinate))
      indent
      Put("switch (yyselect()) {")
      Nl
      put_actions_ALTERNATIVELIST(Alternatives)
      indent
      Put("default: ;")
      Nl
      indent
      Put("}")
      Nl
   'rule' put_actions_MEMBER(subphrase(loop, Alternatives, Key, _, Coordinate))
      UniqueLabel(-> L)
      indent
      Put("while (1) {")
      Nl
      indentation(+1)
      indent
      Put("switch (yyselect()) {")
      Nl
      put_actions_ALTERNATIVELIST(Alternatives)
      indent
      Put("default: goto yy")
      PutI(L)
      Put(";")
      Nl
      indent
      Put("}")
      Nl
      indentation(-1)
      indent
      Put("}")
      Nl
      indent
      Put("yy")
      PutI(L)
      Put(": ;")
      Nl
   'rule' put_actions_MEMBER
      (subphrase(alternatives, Alternatives, Key, _, Coordinate))
      indent
      Put("switch (yyselect()) {")
      Nl
      put_actions_ALTERNATIVELIST(Alternatives)
      indent
      Put("default: printf(\"???\\n\"); exit(1);") -- xx
      Nl
      indent
      Put("}")
      Nl
   'rule' put_actions_MEMBER(sem(Blk))
      -- put_CodeBlock("{", Blk, "}")
      put_CodeBlock("", Blk, "")

'action' put_actions_ALTERNATIVELIST(ALTERNATIVELIST)
   'rule' put_actions_ALTERNATIVELIST(list(H, T))
      put_actions_ALTERNATIVE(H)
      put_actions_ALTERNATIVELIST(T)
   'rule' put_actions_ALTERNATIVELIST(nil)

'action' put_actions_ALTERNATIVE(ALTERNATIVE)
   'rule' put_actions_ALTERNATIVE
   (alternative(Members, AlternativeKey, _, Coordinate))
      indent
      AlternativeKey'ClauseKey -> ClauseKey
      ClauseKey'Number -> Number
      Put("case ")
      PutI(Number)
      Put(": {")
      Nl

      -- AlternativeKey'RuleHandle -> RuleHandle
      -- Put("  [") PutI(RuleHandle) Put("]")

      -- AlternativeKey'ClauseKey -> ClauseKey
      -- ClauseKey'Pos -> Pos

      indentation(+1)
      put_actions_MEMBERLIST(Members)
      indent
      Put("} break;")
      Nl
      indentation(-1)

/* forward decls (C++)
'action' handle_formal_params(FORMPARAMLIST)
   'rule' handle_formal_params(list(H,T))
      handle_formal_param(H)
      [| where(T -> list) Put(", ") |]
      handle_formal_params(T)
   'rule' handle_formal_params(nil)

'action' handle_formal_param(FORMPARAM)
   'rule' handle_formal_param (param(Mode, Type, Name))
      id_to_string(Type -> TStr)
      Put(TStr)
      Put(" ")
      [|
         where(Mode -> out)
	 Put("*")
      |]
      id_to_string(Name -> NStr)
      Put(NStr)
*/
---
'action' handle_formal_params_1(FORMPARAMLIST)
-- write formal parameter list
-- check formal parameters fo uniqueness

   'rule' handle_formal_params_1(list(H,T))
      handle_formal_param_1(H)
      where(H -> param(_,_, Name, _))
      check_formal_param(Name, T)
      [| where(T -> list) Put(", ") |]
      handle_formal_params_1(T)
   'rule' handle_formal_params_1(nil)

'action' handle_formal_param_1(FORMPARAM)
   'rule' handle_formal_param_1 (param(Mode, Type, Name, Pos))
      id_to_string(Name -> NStr)
      Put(NStr)

'action' check_formal_param(IDENT, FORMPARAMLIST)

   'rule' check_formal_param(Name1, list(param(_, _, Name2, Pos), Tl)):
      [|
	 eq(Name1, Name2)
	 ErrorI("formal parameter '", Name1, "' declared more than once", Pos)
      |]
      check_formal_param(Name1, Tl)

   'rule' check_formal_param(_, nil)
---
'action' handle_formal_params_2(FORMPARAMLIST)
-- write declarations for formal parameters

   'rule' handle_formal_params_2(list(H,T))
      handle_formal_param_2(H)
      handle_formal_params_2(T)
   'rule' handle_formal_params_2(nil)

'action' handle_formal_param_2(FORMPARAM)
   'rule' handle_formal_param_2 (param(Mode, Type, Name, Pos))
      id_to_string(Type -> TStr)
      Put("   ")
      Put(TStr)
      Put(" ")
      [|
         where(Mode -> out)
	 Put("*")
      |]
      id_to_string(Name -> NStr)
      Put(NStr)
      Put(";")
      Nl

      define_local_name(Mode, Type, Name)
---

-- note: already checked when declaring locals

'action' handle_actual_params(ACTPARAMLIST, FORMPARAMLIST)
   'rule' handle_actual_params(list(H,T, _), list(H2,T2))
      handle_actual_param(H, H2)
      [| where(T -> list) Put(", ") |]
      handle_actual_params(T, T2)
   'rule' handle_actual_params(nil, nil)

'action' handle_actual_param(ACTPARAM, FORMPARAM)
   'rule' handle_actual_param (id(Id, _), param(FMode, FType, _, _))
      defined_locally(Id -> AMode, _)
      (|
	 where(FMode -> out)
         (|
	    where(AMode -> out)
	    -- is already *T
	 ||
	    Put("&")
	 |)
      ||
	 (|
	    where(AMode -> out)
	    -- is *T, dereference
	    Put("*")
	 ||
	    -- is already value
	 |)
      |)
      id_to_string(Id -> Str)
      Put(Str)
----

-- xx assumption: there is one formal output parameter of type YYSTYPE
'action' handle_token_params(ACTPARAMLIST, FORMPARAMLIST, INT)
   'rule' handle_token_params(list(H,T, _), list(H2,T2), N)
      handle_token_param(H, H2, N)
      -- xx handle_token_params(T, T2, N+1)
   'rule' handle_token_params(nil, _, _)

'action' handle_token_param(ACTPARAM, FORMPARAM, INT)
   'rule' handle_token_param (id(Id, _), param(FMode, FType, _, _), N)
      defined_locally(Id -> AMode, _)
      indent



      (|
	 where(FMode -> out)
         [|
	    where(AMode -> out)
	    Put("*")
	 |]
      ||
	 -- error xxx
      |)



      id_to_string(Id -> IdStr)
      Put(IdStr)
      Put(" = yylval;")
      Nl
----

'var' LabelCount: INT

'action' UniqueLabel(-> INT)
   'rule' UniqueLabel(-> N)
      LabelCount -> N
      LabelCount <- N+1


---

'action' local_declarations (CLAUSEKEYS)
'rule' local_declarations (CLAUSEKEYS)
   local_declarations_CLAUSEKEYS(CLAUSEKEYS)

'action' local_declarations_CLAUSEKEYS(CLAUSEKEYS)
   'rule' local_declarations_CLAUSEKEYS(clausekeys(Keys, Key))
      local_declarations_CLAUSEKEYS(Keys)
      local_declarations_CLAUSEKEY(Key)
   'rule' local_declarations_CLAUSEKEYS(nil)

'action' local_declarations_CLAUSEKEY(CLAUSEKEY)
   'rule' local_declarations_CLAUSEKEY(ClauseKey)
      ClauseKey'GrammarRef -> members(Members)
      local_declarations_sweep(Members)

'sweep' local_declarations_sweep(ANY)
   'rule' local_declarations_sweep(call(Id, ActParams, _, Pos))
      HasMeaning(Id -> Meaning)
      (|
         where(Meaning -> nontermobj(_, _, FormalParams))
         process_formal_and_actual_params(FormalParams, ActParams)
      ||
         where(Meaning -> tokenobj(_, FormalParams))
	 process_token_param(ActParams)
      |)

'action' process_formal_and_actual_params(FORMPARAMLIST, ACTPARAMLIST)
   'rule' process_formal_and_actual_params(list(FHd, FTl), list(AHd, ATl, Pos))
      process_formal_and_actual(FHd, AHd)
      process_formal_and_actual_params(FTl, ATl)
   'rule' process_formal_and_actual_params(nil, nil(_))
   'rule' process_formal_and_actual_params(nil, list(_, _, Pos))
      Error("too many actual parameters", Pos)
   'rule' process_formal_and_actual_params(list(_, _), nil(Pos))
      Error("too few actual parameters", Pos)

'action' process_formal_and_actual(FORMPARAM, ACTPARAM)
   'rule' process_formal_and_actual
   (param(FMode, FType, FName, _), id(AName, Pos))
      (|
         defined_locally(AName -> AMode, AType)
	 [|
	    ne(FType, AType)
	    ErrorI
	    ("'", AName, "' has inconsistent type", Pos)
	 |]
      ||
	 define_local_name(none, FType, AName)
	 Put("   ")
	 id_to_string(FType -> FTypeStr)
	 Put(FTypeStr)
	 Put(" ")
	 id_to_string(AName -> ANameStr)
	 Put(ANameStr)
	 Put(";")
	 Nl
      |)

'action' process_token_param(ACTPARAMLIST)
   'rule' process_token_param(list(id(AName, Pos), nil(_),_))
      string_to_id("YYSTYPE" -> FType)
      (|
         defined_locally(AName -> AMode, AType)
	 [|
	    ne(FType, AType)
	    ErrorI
	    ("'", AName, "' has inconsistent type", Pos)
	 |]
      ||
	 define_local_name(none, FType, AName)
	 Put("   ")
	 id_to_string(FType -> FTypeStr)
	 Put(FTypeStr)
	 Put(" ")
	 id_to_string(AName -> ANameStr)
	 Put(ANameStr)
	 Put(";")
	 Nl
      |)
   'rule' process_token_param(nil)
   'rule' process_token_param(list(id(Name, Pos), list(id(Name2, Pos2),Tl,_),_))
      Error("Too many parameters for token", Pos)

'var' LocalNames: DEFLIST

'type' DEFLIST
   list(DEF, DEFLIST)
   nil

'type' DEF
   def(MODE, Type: IDENT, Name: IDENT)

'action' define_local_name (MODE, IDENT, IDENT)
   'rule' define_local_name (Mode, Type, Name)
      LocalNames -> L
      LocalNames <- list(def(Mode, Type, Name), L)

'condition' defined_locally(IDENT -> MODE, IDENT)
   'rule' defined_locally(Name -> Mode, Type)
      LocalNames -> L
      defined_locally_h(L, Name -> Mode, Type)

'condition' defined_locally_h(DEFLIST, IDENT -> MODE, IDENT)
   'rule' defined_locally_h(list(def(M,T,N), Tail), Name -> Mode, Type)
      (|
	 eq(N, Name)
	 where(M -> Mode)
	 where(T -> Type)
      ||
	 defined_locally_h(Tail, Name -> Mode, Type)
      |)

---

'action' put_CodeBlock(STRING, ACTIONBLOCK, STRING)
   'rule' put_CodeBlock(Str1, action(BlkTxt, BlkPos), Str2)
      Put("#line ")
      POS_to_LineNumber(BlkPos -> N1)
      PutI(N1)
      GetSourceFileName(-> Name)
      Put(" \"")
      Put(Name)
      Put("\"")
      Nl
      Put(Str1)
      PutBlockText(BlkTxt)
      Put(Str2)
      Nl
      GetOutputLineCount(-> N2)
      Put("# line ")
      PutI(N2+2)
      Put(" \"yygrammar.c\"")
      Nl
   'rule' put_CodeBlock(_, none, _)

'action' PutBlockText(STRING)
'action' GetOutputLineCount(-> INT)

---

'action' GetSourceFileName(-> STRING)

'action' POS_to_LineNumber (POS -> INT)

'action' string_to_id (STRING -> IDENT)
