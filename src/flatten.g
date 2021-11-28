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


'module' flatten
'use'
   bnf
   encode
   lexinfo
   actions

'export'
   grammarcode_rulelist

-------------------------------------------------------------------------------

-- 'var' CurSubphrase: SUBPHRASEKEY

'action' grammarcode_rulelist(RULELIST)
   'rule' grammarcode_rulelist(list(H,T)):
      grammarcode_rule(H)
      grammarcode_rulelist(T)
   'rule' grammarcode_rulelist(nil)

-- pass a rule to the "rule constructor interface" encode.g

-- in grammarcode... pass START_RULE ADD_NONTERMMEMBER, ADD_TOKEN_MEMBER,
-- and finally END_RULE
-- subphrases are passed as ADD_SUBPHRASE_REFERNCE
-- but the body of subphrases is skipped  here
-- if END_RULE has been passed then subphrasecode... handles the
-- bodies of subphrases.

'action' grammarcode_rule(RULE)

   'rule' grammarcode_rule(Rule: xxrule(L, R, RKey, Prelude, Annotation, Pos))
      HasMeaning (L -> nontermobj(N,NKey,_))
      START_RULE(L, NKey, N, RKey, Prelude, Annotation, Pos)
      NKey'Rules -> RulesForNonterm
      NKey'Rules <- rules(RulesForNonterm, Rule)
      grammarcode_memberlist(R)
      END_RULE
      subphrasecode_memberlist(R)
   'rule' grammarcode_rule(Rule: rule(L, RhsList, Prelude, Pos))
      where(RhsList -> list(Rhs, Tl))
      where(Rhs -> rhs(R, RKey, Annotation, RhsPos))

      HasMeaning (L -> nontermobj(N,NKey,_))
      START_RULE(L, NKey, N, RKey, Prelude, Annotation, RhsPos)
      NKey'Rules -> RulesForNonterm
      NKey'Rules <- rules(RulesForNonterm, Rule)
      grammarcode_memberlist(R)
      END_RULE
      subphrasecode_memberlist(R)

      grammarcode_rhslist(L, Prelude, Tl)

'action' grammarcode_rhslist(IDENT, ACTIONBLOCK, RHSLIST)
   'rule' grammarcode_rhslist(L, Prelude, list(Hd, Tl))
       grammarcode_rhs(L, Prelude, Hd)
       grammarcode_rhslist(L, Prelude, Tl)
   'rule' grammarcode_rhslist(L, Prelude, nil)
'action' grammarcode_rhs(IDENT, ACTIONBLOCK, RHS)
   'rule' grammarcode_rhs(L, Prelude, Rhs)
      where(Rhs -> rhs(R, RKey, Annotation, RhsPos))

      HasMeaning (L -> nontermobj(N,NKey,_))
      START_RULE(L, NKey, N, RKey, Prelude, Annotation, RhsPos)
      --xx NKey'Rules -> RulesForNonterm
      --xx NKey'Rules <- rules(RulesForNonterm, Rule)
      grammarcode_memberlist(R)
      END_RULE
      subphrasecode_memberlist(R)

'action' grammarcode_memberlist(MEMBERLIST)
   'rule' grammarcode_memberlist(list(H, T))
      grammarcode_member(H)
      grammarcode_memberlist(T)
   'rule' grammarcode_memberlist(nil)

'action' grammarcode_member(MEMBER)
   'rule' grammarcode_member(call(Id, Params, Annotation, Pos))
      (|
	 HasMeaning(Id -> Obj)
	 (|
	    where(Obj -> tokenobj(N,_))
            ADD_TOKEN_MEMBER(N)
	 ||
	    where(Obj -> nontermobj(N,NKey,_))
            ADD_NONTERM_MEMBER(Id, N, Annotation, Pos)
	 |)
      ||
	 ErrorI("'", Id, "' has not been declared", Pos)
      |)
   'rule' grammarcode_member(token(N))
      ADD_TOKEN_MEMBER(N)
   'rule' grammarcode_member(subphrase(Kind, L, Key, Annotation, Coordinate))
      ADD_SUBPHRASE_REFERENCE(Key, Annotation, Coordinate)
   'rule' grammarcode_member(sem(_))

--------------------------------------------------------------------------------

-- local to subphrasecode_alternativelist

'action' innercode_alternative(ALTERNATIVE, SUBPHRASEKIND, SUBPHRASEKEY)
   'rule' innercode_alternative
      (alternative(L, Key, Annotation, Pos), Kind, Subphrase)
      Key'AlternativeNumber -> N
      START_ALTERNATIVE(Subphrase, Key, members(L), Annotation, Pos)
      grammarcode_memberlist(L)
      innercode_recursive_call(Kind, Subphrase, Pos)
      END_ALTERNATIVE


-- local to from innercode_alternative

'action' innercode_recursive_call
   (SUBPHRASEKIND, SUBPHRASEKEY, POS)
   'rule' innercode_recursive_call(loop(MemberAnno), Subphrase, Coordinate)
      ADD_SUBPHRASE_REFERENCE(Subphrase, MemberAnno, Coordinate)
   'rule' innercode_recursive_call(_, _, _)

-- local to subphrasecode_alternativelist

'action' innercode_empty_rule
   (SUBPHRASEKIND, SUBPHRASEKEY, RULEANNOTATION, POS)
   'rule' innercode_empty_rule(Kind, Subphrase, Annotation, Pos)
      (|
	 (| where(Kind -> option)
	 || where(Kind -> loop)
	 |)
	 Key :: ALTERNATIVEKEY
	 FreshAlternativeNumber(-> N)
	 Key'AlternativeNumber <- N
	 START_ALTERNATIVE(Subphrase, Key, none, Annotation, Pos)
	 END_ALTERNATIVE
      ||
         -- skip
      |)

--------------------------------------------------------------------------------

-- subphrasecode... :
-- handle inner subphrases
-- for each subphrase 

'action' subphrasecode_memberlist(MEMBERLIST)
   'rule' subphrasecode_memberlist(list(H, T))
      subphrasecode_member(H)
      subphrasecode_memberlist(T)
   'rule' subphrasecode_memberlist(nil)

'action' subphrasecode_member(MEMBER)
   'rule' subphrasecode_member(call(Id,_,_,_))
   'rule' subphrasecode_member(token(N))
   'rule' subphrasecode_member(subphrase(Kind, L, SubphraseKey, Annotation, Coordinate))
      subphrasecode_alternativelist(L, Kind, SubphraseKey)
   'rule' subphrasecode_member(sem(_))

'action' subphrasecode_alternativelist
   (ALTERNATIVELIST, SUBPHRASEKIND, SUBPHRASEKEY)
   'rule' subphrasecode_alternativelist(list(H, T), Kind, SubphraseKey)
      innercode_alternative(H, Kind, SubphraseKey)
      subphrasecode_alternative(H)
      subphrasecode_alternativelist(T, Kind, SubphraseKey)
   'rule' subphrasecode_alternativelist(nil(Annotation, Pos), Kind, SubphraseKey)
      innercode_empty_rule(Kind, SubphraseKey, Annotation, Pos)

'action' subphrasecode_alternative(ALTERNATIVE)
'rule' subphrasecode_alternative(alternative(L, Key, Annotation, Pos))
   subphrasecode_memberlist(L)

--------------------------------------------------------------------------------
