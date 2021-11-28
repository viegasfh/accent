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


'module' bnf
'use'
   encode
   lexinfo
   verbose
   actions
   flatten

'export'
   IDENT
   RULEKEY
   id_to_string
   SUBPHRASEKEY
   ALTERNATIVEKEY
   ALTERNATIVE
   ALTERNATIVELIST
   RULELIST

   RULE

   RHSLIST
   RHS
   MEMBERLIST
   MEMBER

   FORMPARAMLIST
   FORMPARAM
   MODE

   ACTPARAMLIST
   ACTPARAM

   NONTERMKEY

   RULES
   NONTERMS
   NontermList
   HasMeaning
   OBJECT

   SUBPHRASEKIND

   MEMBERANNOTATION
   RULEANNOTATION

   ACTIONBLOCK

   NumberOfRules
   NumberOfNonterms

   Error
   ErrorI

   PreludeBlock

   -- for "flatten.g"
   FreshAlternativeNumber

   -- for "encode.g"
   get_max_char

   GentleFlag
   Bool

'root'
   init

   GentleOption
   PreludeOption
   token_decl_part
   rulelist(-> L)

   Process(L)

'action' Process(RULELIST)
'rule' Process(L)
   (|
      where(L -> list(xxrule(UserRoot,_,_,_,_,Pos),_))
   ||
      where(L -> list(rule(UserRoot,_,_,Pos),_))
   |)
   StartRule (UserRoot, Pos -> SR)
   HasMeaning(UserRoot -> nontermobj(_,_,Formals))
   [|
      where(Formals -> list)
      ErrorI("Startsymbol ('", UserRoot, "') can not have parameters", Pos)
   |]

   where(RULELIST'list(SR,L) -> L2)

   grammarcode_rulelist(L2)
   
   lexinfo -- (must precede ENCODE)

   OpenOutput("yygrammar.c")
   put_actions
   ENCODE

   CloseOutput
   -- put_grammar
   

'type' DEFAULTSPEC
   default
   nodefault

'var' DefaultSpec: DEFAULTSPEC

'type' ACTIONBLOCK
   action(STRING, POS)
   none

'var' PreludeBlock: ACTIONBLOCK

'nonterm' PreludeOption
   'rule' PreludeOption
       "%prelude"
       ActionBlock(-> Block)
       PreludeBlock <- Block
   'rule' PreludeOption
       PreludeBlock <- none

'action' StartRule(IDENT, POS -> RULE)
   'rule' StartRule(UserRoot, Pos -> StartRule)


      string_to_id("YYSTART" -> Id)

      where(MEMBERLIST'list(call(UserRoot, nil(Pos), undefmemberanno, Pos), list(token(0), nil))
	 -> Members)

      Key :: RULEKEY
      FreshRuleNumber(-> N)
      Key'RuleNumber <- N
      Key'Members <- Members
      define_nonterm(Id, nil, Pos)

      where(xxrule(Id, Members, Key, none, prio(0), Pos) -> StartRule)

'action' string_to_id(STRING -> IDENT)

--------------------------------------------------------------------------------

--
-- Abstract Syntax
-- 

'type' RULELIST
   list(RULE, RULELIST)
   nil

'type' RULE
   xxrule(IDENT, MEMBERLIST, RULEKEY, ACTIONBLOCK, RULEANNOTATION, POS)
   rule(IDENT, RHSLIST, ACTIONBLOCK, POS)

'type' RHSLIST
   list(RHS, RHSLIST)
   nil

'type' RHS
   rhs(MEMBERLIST, RULEKEY, RULEANNOTATION, POS)

'type' RULEANNOTATION
   prio(INT)
   undefruleanno

'type' MEMBERLIST
   list(MEMBER, MEMBERLIST)
   nil

'type' MEMBER
   call(IDENT, ACTPARAMLIST, MEMBERANNOTATION, POS)
   token(INT)
   subphrase
      (SUBPHRASEKIND, ALTERNATIVELIST, SUBPHRASEKEY, MEMBERANNOTATION, POS)
   sem(ACTIONBLOCK)

'type' MEMBERANNOTATION
   short
   long
   undefmemberanno
   user(INT)

'type' SUBPHRASEKIND
   option
   loop(MEMBERANNOTATION)
   alternatives

'type' ALTERNATIVELIST
   list(ALTERNATIVE, ALTERNATIVELIST)
   nil(RULEANNOTATION, POS)

'type' ALTERNATIVE
   alternative(MEMBERLIST, ALTERNATIVEKEY, RULEANNOTATION, POS)

'type' FORMPARAMLIST
   list(FORMPARAM, FORMPARAMLIST)
   nil

'type' FORMPARAM
   param(MODE, Type: IDENT, Name: IDENT, POS)

'type' MODE
   xxin
   out
   none

'type' ACTPARAMLIST
   list(ACTPARAM, ACTPARAMLIST, POS)
   nil(POS)

'type' ACTPARAM
   id(IDENT, POS)

--------------------------------------------------------------------------------

'table' RULEKEY
   (Members: MEMBERLIST, RuleNumber: INT, RuleHandle: INT)
'table' ALTERNATIVEKEY
   (Members: MEMBERLIST, AlternativeNumber: INT,
   ClauseKey: CLAUSEKEY,
   RuleHandle: INT/*, PosOfNextRule: INT*/)
'table' SUBPHRASEKEY (SubphraseNumber: INT)
'table' NONTERMKEY(Rules: RULES, PosOfNonterm: INT)

'type' RULES
   rules(ButLast: RULES, Last: RULE)
   nil

--------------------------------------------------------------------------------

--
-- Grammar
--
'var' UniqueRuleNumber: INT

'action' FreshRuleNumber (-> INT)
'rule' FreshRuleNumber(-> N+1)
   UniqueRuleNumber -> N
   UniqueRuleNumber <- N+1

'var' UniqueAlternativeNumber: INT

'action' FreshAlternativeNumber (-> INT)
'rule' FreshAlternativeNumber(-> N+1)
   UniqueAlternativeNumber -> N
   UniqueAlternativeNumber <- N+1

'var' UniqueSubphraseNumber: INT

'action' FreshSubphraseNumber (-> INT)
'rule' FreshSubphraseNumber(-> N+1)
   UniqueSubphraseNumber -> N
   UniqueSubphraseNumber <- N+1

'nonterm' init
'rule' init
   init_tokenlist
   init_lexinfo
   NontermList <- nil
   INIT_ENCODE
   UniqueNontermNumber <- 0
   UniqueRuleNumber <- 0
   UniqueSubphraseNumber <- 0
   UniqueAlternativeNumber <- 0
   DefaultSpec <- default

'nonterm' token_decl_part
   'rule' token_decl_part
      "%token"
      token_decl_list
      ";"
   'rule' token_decl_part

'nonterm' token_decl_list
   'rule' token_decl_list:
      token_decl ","
      token_decl_list
   'rule' token_decl_list
      token_decl

'nonterm' token_decl
   'rule' token_decl:
      Ident(-> I) @(-> P)
      FreshTokenNumber(-> N)
      TableUpb2(N)
      string_to_id ("YYSTYPE" -> Yystype)
      string_to_id ("Dummy" -> Dummy)
      where(FORMPARAMLIST'list (param(out, Yystype, Dummy, P), nil) -> L)
      define_token(I, L, N, P)
      enter_token(I, N)
      TokenCount -> K
      [|
	 gt(N, K)
	 TokenCount <- N
      |]

'action' FreshTokenNumber(-> INT)
   'rule' FreshTokenNumber(-> N)
      NextTokenNumber -> N
      NextTokenNumber <- N+1


'nonterm' rulelist(-> RULELIST)
   'rule' rulelist(-> list(H,T)): rule(-> H) rulelist(-> T)
   'rule' rulelist(-> list(H,nil)): rule(-> H)
   'rule' rulelist(-> L): defaultspec rulelist(-> L)

'nonterm' defaultspec
   'rule' defaultspec:
      "%default"
      DefaultSpec <- default
   'rule' defaultspec:
      "%nodefault"
      DefaultSpec <- nodefault

'nonterm' rule(-> RULE)

   'rule' rule (-> rule(I, RhsList, Prelude, Pos))
      Ident(-> I) FormalParameters(-> L)
      ":"
      FirstAlternativeIndex
      @(-> Pos)
      RulePrelude(-> Prelude)
      rhslist(-> RhsList)
      ";"
      define_nonterm(I, L, Pos)

'nonterm' FirstAlternativeIndex
   'rule' FirstAlternativeIndex
      AlternativeIndex <- 0

'nonterm' rhslist(-> RHSLIST)
   'rule' rhslist(-> list(Hd, Tl))
      rhs(-> Hd) "|" rhslist(-> Tl)
   'rule' rhslist(-> list(Hd, nil))
      rhs(-> Hd)

'nonterm' rhs(-> RHS)
   'rule' rhs(-> rhs(R, Key, Annotation, Pos))
      @(-> Pos)
      memberlist(-> R)
      RuleAnnotation(-> Annotation)
      Key :: RULEKEY
      FreshRuleNumber(-> N)
      Key'RuleNumber <- N
      Key'Members <- R

'nonterm' RulePrelude(-> ACTIONBLOCK)
   'rule' RulePrelude(-> Block)
      "%prelude"
      ActionBlock(-> Block)
   'rule' RulePrelude(-> none)

'nonterm' RuleAnnotation(-> RULEANNOTATION)
   'rule' RuleAnnotation(-> prio(N))
      "%prio" Number(-> N)
      NextAlternativeIndex
   'rule' RuleAnnotation(-> prio(-(N+1)))
      "%disfilter" Number(-> N)
      NextAlternativeIndex
   'rule' RuleAnnotation(-> Anno)
      NextAlternativeIndex
      (|
         DefaultSpec -> nodefault
         where(undefruleanno -> Anno)
      ||
         AlternativeIndex -> N
         where(prio(N) -> Anno)
      |)

'action' NextAlternativeIndex
   'rule' NextAlternativeIndex
       AlternativeIndex -> N
       AlternativeIndex <- N+1

'nonterm' memberlist(-> MEMBERLIST)
   'rule' memberlist(-> list(H, T))
      member(-> H) memberlist(-> T)
   'rule' memberlist(-> nil)

'nonterm' member(-> MEMBER)
   'rule' member(-> call(I, L, Annotation, Pos))
      MemberAnnotation(-> Annotation)
      Ident(-> I) @(-> Pos)
      ActualParameters(-> L)

   'rule' member(-> token(I))
      Char(-> I)
   'rule' member(-> subphrase(option, L, Key, Annotation, Pos))
      MemberAnnotation(-> Annotation)
      "(" @(-> Pos) optloop_alternativelist0(-> L) ")?"
      Key :: SUBPHRASEKEY
      FreshSubphraseNumber(-> N)
      Key'SubphraseNumber <- N
   'rule' member(-> subphrase(loop(MemberAnno), L, Key, Annotation, Pos))
      MemberAnnotation(-> Annotation)
      "("
      @(-> Pos) optloop_alternativelist0(-> L)
      LoopAnno(-> MemberAnno)
      ")*"
      Key :: SUBPHRASEKEY
      FreshSubphraseNumber(-> N)
      Key'SubphraseNumber <- N
   'rule' member(-> subphrase(alternatives, L, Key, Annotation, Pos))
      MemberAnnotation(-> Annotation)
      "(" @(-> Pos) alternativelist0(-> L) ")"
      Key :: SUBPHRASEKEY
      FreshSubphraseNumber(-> N)
      Key'SubphraseNumber <- N
   'rule' member(-> sem(Block))
      ActionBlock(-> Block)

'nonterm' LoopAnno(-> MEMBERANNOTATION)
   'rule' LoopAnno(-> Anno)
       "%tail"
       MemberAnnotation(-> Anno)
   'rule' LoopAnno(-> Anno)
      (|
         DefaultSpec -> nodefault
         where(undefmemberanno -> Anno)
      ||
         where(short -> Anno)
      |)

'nonterm' MemberAnnotation(-> MEMBERANNOTATION)
   'rule' MemberAnnotation(-> short)
      "%short"
   'rule' MemberAnnotation(-> long)
      "%long"
   'rule' MemberAnnotation(-> user(N))
      "%confilter" Number(-> N)
   'rule' MemberAnnotation(-> Anno)
      (|
         DefaultSpec -> nodefault
         where(undefmemberanno -> Anno)
      ||
         where(short -> Anno)
      |)

'nonterm' FormalParameters(-> FORMPARAMLIST)
   'rule' FormalParameters(-> L):
      "<" FormalParameterList(-> L) ">"
   'rule' FormalParameters(-> L):
      "<" FormalOutParameters(-> L) ">"
   'rule' FormalParameters(-> L):
      "<" FormalInParameters(-> IL) ">"
      convert_to_in_parameters(IL -> L)
   'rule' FormalParameters(-> L):
      "<" FormalInParameters(-> IL0)
          FormalOutParameters(-> OL)
      ">"
      convert_to_in_parameters(IL0 -> IL)
      append_parameter_lists(IL, OL -> L)
   'rule' FormalParameters(-> nil):

'nonterm' FormalInParameters(-> FORMPARAMLIST)
   'rule' FormalInParameters(-> L):
      "%in" FormalParameterList(-> L)

'nonterm' FormalOutParameters(-> FORMPARAMLIST)
   'rule' FormalOutParameters(-> L):
      "%out" FormalParameterList(-> L)

'nonterm' FormalParameterList(-> FORMPARAMLIST)
   'rule' FormalParameterList(-> list(H, T))
      FormalParameter(-> H) "," FormalParameterList(-> T)
   'rule' FormalParameterList(-> list(H, nil))
      FormalParameter(-> H)

'nonterm' FormalParameter(-> FORMPARAM)
   'rule' FormalParameter(-> param(out, Type, Name, Pos))
      Ident(-> Type)
      Ident(-> Name)
      @(-> Pos)
   'rule' FormalParameter(-> param(out, Type, Name, Pos))
      Ident(-> Name)
      @(-> Pos)
      string_to_id("YYSTYPE" -> Type)

'nonterm' ActualParameters(-> ACTPARAMLIST)
   'rule' ActualParameters(-> L):
      "<" ActualParameterList(-> L) ">"
   'rule' ActualParameters(-> nil(Pos)):
      @(-> Pos)

'nonterm' ActualParameterList(-> ACTPARAMLIST)
   'rule' ActualParameterList(-> list(H, T, Pos))
      ActualParameter(-> H) @(-> Pos) "," ActualParameterList(-> T)
   'rule' ActualParameterList(-> list(H, nil(Pos), Pos))
      ActualParameter(-> H) @(-> Pos)

'nonterm' ActualParameter(-> ACTPARAM)
   'rule' ActualParameter(-> id(Id, Pos))
      Ident(-> Id) @(-> Pos)

'var' AlternativeIndex: INT

'nonterm' optloop_alternativelist0(-> ALTERNATIVELIST)
   'rule' optloop_alternativelist0(-> L)
      SetAlternativeIndex(-> N)
      optloop_alternativelist(-> L)
      AlternativeIndex <- N

'nonterm' alternativelist0(-> ALTERNATIVELIST)
   'rule' alternativelist0(-> L)
      SetAlternativeIndex(-> N)
      alternativelist(-> L)
      AlternativeIndex <- N

'nonterm' SetAlternativeIndex(-> INT)
   'rule' SetAlternativeIndex(-> N)
      AlternativeIndex -> N
      AlternativeIndex <- 0

'nonterm' optloop_alternativelist(-> ALTERNATIVELIST)
   'rule' optloop_alternativelist(-> list(H, T))
      alternative(-> H) "|" optloop_alternativelist(-> T)
   'rule' optloop_alternativelist(-> list(H, nil(Anno, Pos)))
      alternative(-> H)
      @(-> Pos)
      (|
         DefaultSpec -> nodefault
         where(undefruleanno -> Anno)
      ||
         AlternativeIndex -> N
         where(prio(N+1) -> Anno)
      |)
   'rule' optloop_alternativelist(-> list(H, nil(Anno, Pos)))
      alternative(-> H)
      "%zero"
      @(-> Pos)
      RuleAnnotation(-> Anno)

'nonterm' alternativelist(-> ALTERNATIVELIST)
   'rule' alternativelist(-> list(H, T))
      alternative(-> H) "|" alternativelist(-> T)
   'rule' alternativelist(-> list(H, nil(Anno, Pos)))
      alternative(-> H)
      @(-> Pos)
      (|
         DefaultSpec -> nodefault
         where(undefruleanno -> Anno)
      ||
         AlternativeIndex -> N
         where(prio(N+1) -> Anno)
      |)

'nonterm' alternative(-> ALTERNATIVE)
   'rule' alternative(-> alternative(L, Key, Annotation, Pos))
      @(-> Pos)
      memberlist(-> L)
      RuleAnnotation(-> Annotation)
      Key :: ALTERNATIVEKEY
      FreshAlternativeNumber(-> N)
      Key'AlternativeNumber <- N
      Key'Members <- L

'nonterm' ActionBlock(-> ACTIONBLOCK)
   'rule' ActionBlock(-> action(Str, Pos))
      @(-> Pos)
      CodeBlock(-> Str)

'token' Ident(-> IDENT)
'token' Char(-> INT)
'token' Number(-> INT)
'token' CodeBlock(-> STRING)

-------------------------------------------------------------------------------

'var' NontermList: NONTERMS
'type' NONTERMS
   nonterms(NONTERMS, NONTERMKEY)
   nil

'type' OBJECT
   tokenobj(INT, FORMPARAMLIST)
   nontermobj(INT, NONTERMKEY, FORMPARAMLIST)

'var' UniqueNontermNumber: INT

'action' define_token (IDENT, FORMPARAMLIST, INT, POS)
   'rule' define_token (Id, Params, N, Pos)
      (|
	 HasMeaning (Id -> Obj)
	 ErrorI("'", Id, "' already defined", Pos)
      ||
	 DefMeaning (Id, tokenobj(N, Params))
      |)

'action' define_nonterm (IDENT, FORMPARAMLIST, POS)
   'rule' define_nonterm(Id, FormalParams, Pos)
      (|
	 HasMeaning (Id -> Obj)
	 (|
	     where(Obj -> tokenobj)
	     ErrorI("nonterminal '", Id, "' already defined as token", Pos)
	 ||
	     ErrorI("nonterminal '", Id, "' defined by more than one rule", Pos)
	 |)
      ||
	 UniqueNontermNumber -> N
	 UniqueNontermNumber <- N+1
	 NKey :: NONTERMKEY
	 NKey'Rules <- nil
	 DefMeaning (Id, nontermobj(N+1, NKey, FormalParams))
	 NontermList -> L
	 NontermList <- nonterms(L, NKey)
      |)

--
-- Idents
--

'type' IDENT
'condition' HasMeaning(IDENT -> OBJECT)
'action' DefMeaning(IDENT, OBJECT)
'action' id_to_string(IDENT -> STRING)

--------------------------------------------------------------------------------

--
-- Token List
--

'var' TokenList: TOKENLIST
'var' TokenCount: INT
'var' NextTokenNumber: INT

'type' TOKENLIST
   list (TOKENENTRY, TOKENLIST)
   nil

'type' TOKENENTRY
   token(STRING, INT)

'action' init_tokenlist
'rule' init_tokenlist
   TokenList <- nil
   TokenCount <- 0
   get_max_char(-> MAXCHAR)
   NextTokenNumber <- MAXCHAR+1

'action' get_max_char(-> INT)

'action' TokenNumberToString(INT -> STRING)
'rule' TokenNumberToString(N -> S)
   TokenList -> L
   lookup_tokenstring(L, N -> S)

'action' lookup_tokenstring(TOKENLIST, INT -> STRING)
'rule' lookup_tokenstring(list(token(S0, N0), Tl), N -> S)
   (|
      eq(N0, N)
      where(S0 -> S)
   ||
      lookup_tokenstring(Tl, N -> S)
   |)

--------------------------------------------------------------------------------

'action' NumberOfRules(-> INT)
'rule' NumberOfRules(-> N)
   UniqueRuleNumber -> N

'action' NumberOfNonterms(-> INT)
'rule' NumberOfNonterms(-> N)
   UniqueNontermNumber -> N

--------------------------------------------------------------------------------

'action' convert_to_in_parameters(FORMPARAMLIST -> FORMPARAMLIST)
   'rule' convert_to_in_parameters(list(param(_,T,N,P), T1) 
   -> list(param(xxin,T,N,P), T2)):
      convert_to_in_parameters(T1 -> T2)
   'rule' convert_to_in_parameters(nil -> nil) 

'action' append_parameter_lists
   (FORMPARAMLIST, FORMPARAMLIST -> FORMPARAMLIST)
'rule' append_parameter_lists(list(H, T), L -> list(H, TL)):
   append_parameter_lists(T, L -> TL)
'rule' append_parameter_lists(nil, L -> L)

'action' Error (STRING, POS)
'action' ErrorI (STRING, IDENT, STRING, POS)

--------------------------------------------------------------------------------

'type' Bool
   yes
   no

'nonterm' GentleOption
'rule' GentleOption
   "%gentle"
   GentleFlag <- yes
'rule' GentleOption
   GentleFlag <- no

'var' GentleFlag: Bool

--------------------------------------------------------------------------------
