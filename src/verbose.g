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


'module' verbose

'use'
   bnf
   encode

'export'
   put_grammar

   init_indentation
   indentation
   indent

'action' put_grammar
   'rule' put_grammar
      OpenOutput("gram.v")
      init_indentation
      LHS_List -> Keys
      put_rules_LHSKEYS(Keys)
      CloseOutput

'action'  put_rules_LHSKEYS(LHSKEYS)
   'rule' put_rules_LHSKEYS(keys(Keys, Key))
      put_rules_LHSKEYS(Keys)
      put_rules_LHSKEY(Key)
   'rule' put_rules_LHSKEYS(nil)

'action' put_rules_LHSKEY(LHSKEY)
   'rule' put_rules_LHSKEY(Key)

      Key'Lhs -> Lhs
      [|
         -- put LHS

	 where(Lhs -> nonterm(Id))
	 id_to_string(Id -> Str)
	 Put(Str)
	 Put(":")
	 Nl

         -- put RHS

         Key'Clauses -> Clauses
	 indentation(+1)
         put_rules_for_nonterm_CLAUSEKEYS(Clauses)
	 indentation(-1)
      |]

'action' put_rules_for_nonterm_CLAUSEKEYS(CLAUSEKEYS)
   'rule' put_rules_for_nonterm_CLAUSEKEYS(clausekeys(Keys, Key))
      put_rules_for_nonterm_CLAUSEKEYS(Keys)
      put_rules_for_nonterm_CLAUSEKEY(Key)
   'rule' put_rules_for_nonterm_CLAUSEKEYS(nil)

'action' put_rules_for_nonterm_CLAUSEKEY(CLAUSEKEY)
   'rule' put_rules_for_nonterm_CLAUSEKEY(ClauseKey)
      ClauseKey'GrammarRef -> members(Members)
      indent
      Put("<rule>")

      -- ClauseKey'RuleHandle -> RuleHandle
      -- Put("  [") PutI(RuleHandle) Put("]")

      ClauseKey'Pos -> Pos
      Put("  [") PutI(Pos) Put("]")
      Nl

      indentation(+1)
      put_rules_MEMBERLIST(Members)
      indentation(-1)

'action' put_rules_MEMBERLIST(MEMBERLIST)
   'rule' put_rules_MEMBERLIST(list(H, T))
      put_rules_MEMBER(H)
      put_rules_MEMBERLIST(T)
   'rule' put_rules_MEMBERLIST(nil)

'action' put_rules_MEMBER(MEMBER)
   'rule' put_rules_MEMBER(call(Id, _, _, _))
      id_to_string(Id -> Str)
      indent
      Put(Str)
      Nl
   'rule' put_rules_MEMBER(token(N))
      indent
      Put("token-")
      PutI(N)
      Nl
   'rule' put_rules_MEMBER(subphrase(option, Alternatives, Key, _, Coordinate))
      indent
      Put("<option>") Nl
      indentation(+1)
      put_rules_ALTERNATIVELIST(Alternatives)
      indentation(-1)
   'rule' put_rules_MEMBER(subphrase(loop, Alternatives, Key, _, Coordinate))
      indent
      Put("<loop>") Nl
      indentation(+1)
      put_rules_ALTERNATIVELIST(Alternatives)
      indentation(-1)
   'rule' put_rules_MEMBER
      (subphrase(alternatives, Alternatives, Key, _, Coordinate))
      indent
      Put("<group>") Nl
      indentation(+1)
      put_rules_ALTERNATIVELIST(Alternatives)
      indentation(-1)
   'rule' put_rules_MEMBER(sem(_))
   /*
   'rule' put_rules_MEMBER(X)
      print(X)
      */

'action' put_rules_ALTERNATIVELIST(ALTERNATIVELIST)
   'rule' put_rules_ALTERNATIVELIST(list(H, T))
      put_rules_ALTERNATIVE(H)
      put_rules_ALTERNATIVELIST(T)
   'rule' put_rules_ALTERNATIVELIST(nil)

'action' put_rules_ALTERNATIVE(ALTERNATIVE)
   'rule' put_rules_ALTERNATIVE
   (alternative(Members, AlternativeKey, _, Coordinate))
      indent
      Put("<alternative>")

      -- AlternativeKey'RuleHandle -> RuleHandle
      -- Put("  [") PutI(RuleHandle) Put("]")

      AlternativeKey'ClauseKey -> ClauseKey
      ClauseKey'Pos -> Pos
      Put("  [") PutI(Pos) Put("]")

      POS_to_INT(Coordinate -> N)
      Put("  [") PutI(N) Put("]")
      Nl

      indentation(+1)
      put_rules_MEMBERLIST(Members)
      indentation(-1)

--------------------------------------------------------------------------------

-- Indentation

'var' IndentationLevel: INT

'action' init_indentation
   'rule' init_indentation
      IndentationLevel <- 0

'action' indent
   'rule' indent
      IndentationLevel -> Level
      where(1 -> Count)
      <*
	 le(Count, Level)
	 Put("   ")
	 wherenext(Count+1 -> Count)
      *>

'action' indentation(INT)
   'rule' indentation(N)
      IndentationLevel -> Level
      IndentationLevel <- Level+N

'action' POS_to_INT(POS -> INT)
