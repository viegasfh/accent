`compilertools.net, Technical Report, 2000`\

ENTIRE, A Generic Parser for the Entire Class of Context-free Grammars
======================================================================

*Friedrich Wilhelm Schröer*\
Fraunhofer Institute for Computer Architecture and Software Technology\
`f.w.schroeer@first.fraunhofer.de`

ENTIRE is a generic parser that can analize source text according to the
rules of any context-free grammar. The grammar and the semantic actions
have to be provided by a companion tool, e.g. the ACCENT compiler
compiler \[1\]. The user should study the documentation for that tool
but is not required to be familiar with the ENTIRE parsing technology.
However, we provide a short overview. The technical details are
documented inside the source file, which is freely available.

### Introduction

Parsing usually begins with processing the start symbol of the grammar.

A nonterminal can be processed as follows. One selects an alternative
and processes it from left to right.

If at the current position inside the alternative there is a token, one
compares this with the current input token. If they match the input
token is eaten and the working point inside the rule is advanced to the
next member.

If at the current position there is a nonterminal, this nonterminal is
processed and then the working point is advanced after the symbol.

When at a given point during passing more than one alternative can be
applied, there are several approaches:

-   *Exhaustive parsing* follows all possibilities in parallel. (This
    approach can deal with all grammars)
-   *Predictive parsing* inspects the next input token and requires that
    this uniquely discriminates one alternative. (This approach can deal
    with a restrictive class of grammars, LL(1) grammars)

There is also an approach that inspects the next input token and follows
a group of alternatives. Such groups are build at parser generation time
and collect alternatives that can be followed in parallel by the same
sequence of parser actions. (This approach can deal with a larger but
still restrictive class of grammars, it is used by Yacc.)

Our approach combines exhaustive and predictive passing. Exhaustive
parsing is used to achieve generality. Predictive parsing is used to
improve efficency.

### Exhaustive Parsing

We use *Earley\'s Algorithm* \[2\] for exhaustive parsing.

Whereas in Accent a nonterminal is defined by one rule with several
alternatives

       N : A_1 | ... | A_n

for this discussion it is more convenient to define a nonterminal by
several rules

       N : A_1
       ...
       N : A_n

Assume that

       N : M_1 ... M_i ... M_n

is such a rule. When such a rule is processed we use a \"dot\" (denoted
by \"`*`\") to indicate the actual position inside the rule. For
example, in

       N : M_1 ... * M_i ... M_n

the next symbol being to be processed is `M_i`. Such a \"dotted rule\"
is called an *item*.

An item has also a \"back-pointer\" to find items that triggered the
actual one (I do not discuss this here).

Earley \[2\] proposes to attach a dynamically computed look ahead
strings to items. Since we use static look ahead set computation we do
not use this component.

The algorithm constructs an item list for each input token.

The *kernel* of the item list for a particular input token is
constructed by a step called the *scanner*.

-   **Scanner**

    If `'t'` is the current input token then all items of the previous
    list that have the form

           M : ... * 't' ...

    are placed into the next item list where the dot is advanced behind
    the token

           M : ... 't' * ...

    This indicates that \'t\' has been recognized and the symbol
    following it has to be processed.

The rest of the item list is constructed by by the *closure* of the
kernel. The closure is obtained by applying the *predictor* and
*completer* steps until no new item can be added.

-   **Predictor**

    If the dot appears in front of a nonterm, the \"predictor\" is
    invoked. It inserts items that start the processing of the member.

    If the item has the form

           M : ... * N ...

    and there is a rule

           N : Alpha

    then an item

           N : * Alpha

    is inserted.

<!-- -->

-   **Completer**

    If the dot appears at the end of a rule, the \"completer\" is
    invoked. It takes the item that caused the processing of this rule
    and puts the dot after the corresponding nonterminal.

    If the item has the form

           N : ... *

    and this item was initially triggered by an item

           M : ... * N ...

    then an item

           M : ... N * ...

    is added, indicating that the member `N` has been processed.

Processing starts with the item

      YYSTART : * S YYEOF

where `S` is the start symbol of the grammar. The closure of this item
determines the initial item list.

### Predictive Parsing

Predictive parsing has been described by *Lewis* and *Stearns* \[3\].

In this approach, for each alternative of a nonterminal a set of
*director tokens* is computed at compiler generation time. This set
contains all tokens that are legal tokens when we start to process the
nonterminal. These are given by (1) those tokens that can start the
alternative and (2), if the alternative can produce the empty string,
the tokens that can follow a phrase for the nonterminal.

For example, consider this simple grammar

       S : N 'x' ;
       N : A | B ;
       A : 'a' ;
       B : ;

For the alternative

       N : A ;

the set of director tokens is given by `'a'`, because this is the (only)
token that is valid for this alternative.

For the alternative

       N : B ;

the set is given by `'x'`: `B` can produce the empty string so we can
\"look through\" `N` in the rule for `S` and see the `'x'` that follows
`N` in the rule for `S`.

When parsing a text we begin with the start symbol `S` and hence have to
recognize an `N`. Assume that we are confronted with an `'a'`. In this
case we would choose the first alternative for `N`, because `'a'` is in
its director set. If we are confronted with an `'x'`, we would choose
the second alternative, because `'x'` is in its director set.

In general, if a choice must be made which alternative has to be used to
parse a phrase for a particular nonterminal, the first token of the rest
of the input is inspected. If it appears in the director set the
corresponding alternative is selected.

In order that this works one has to postulate that the director sets of
the alternatives of a nonterminal are mutually disjoint (otherwise it
would not be clear what alternative should be selected).

This restricts the class of grammars that can be processed with this
approach.

Predictive parsers are often implemented by *recursive descent*.

Here one writes a procedure for each nonterminal that inspects the
current input token and uses it to select an alternative. It then
processes the members of this alternative.

For example, the nonterminal `N` from the above grammar could be
implemented in this way:

       procedure N()

          if current_token in { 'a' } then
         A();
          else if current_token in { 'x' } then
         B();
          else
         Error();

Such a procedure can be used to add semantic processing to parsing. Just
include the code at arbitrary places inside the code for the
alternatives. This is possible, because there is no backtracking or
processing of several rules in parallel. It would not work with
exhaustive parsing.

### Combined Parsing

Accent combines exhaustive and predictive parsing.

Exhaustive parsing is implemented as described above. We cannot use
predictive parsing directly because it would narrow the class of
grammars that we want to process.

We cannot use director sets to deterministically select an alternative,
but we can use them to exclude an alternative that would not be viable.

For example, if the input

       a x

is parsed using the grammar above, the item

       S : * N 'x'

would cause the predictor to generate the item

       N : * A

But it would also generate

       N : * B

which in turn would trigger

       B : *

This item would then cause the completer to create

       N : B *

and then

       S : N * 'x'

This item cannot be continued because the input starts with `'a'`.

The director set of the alternative

       N : B

contains only the element `'x'`. Because the current input token is
`'a'` this alternative is not viable.

Predictive parsing requires that the director sets uniquely determines
one alternative. In Accent, if the current token is in the director set
of more than one alternative, all these alternatives are processed.
Alternatives with a director set that does not contain the current token
are excluded.

Accent also uses recursive descent to execute semantic actions. This
cannot be done during parsing because several rules can be processed in
parallel. Hence there is a second pass. The generated procedures look
like those presented above, they do not inspect the director set but use
the result of the parsing to select an alternative.

### Structure Information

Accent parsers do not compute derivation trees after building the item
sequence but attach structure information directly to items.

There is a \"sub-pointer\" that refers to the \"subtree item\" of the
current item. If the item has the form

       M : alpha N * beta

the \"sub-pointer\" refers to an item of the form

       N : gamma *

i.e. the item that concluded the processing of `N`.

A \"left-pointer\" is used as a reference to \"preceding items\". If the
item has the form

       M : alpha N * beta

then the \"left-pointer\" refers to an item

       M : alpha * N beta

i.e. the item that triggered the processing of `N`.

This information can be used to detect and resolve ambiguities at the
earliest point.

[References]{#references}
=========================

\[1\]

Schröer, F.W.:\
*ACCENT, A Compiler Compiler for the Entire Class of Context-free
Languages*\
compilertools.net, Technical Report, 2000

\[2\]

Earley, J.:\
*An Efficient Context-Free Parsing Algorithm*\
Communications of the ACM\
Volume 13, Number 2, February 1970, pp. 94-102\

\[3\]

Lewis, P. M. II, Staerns, R. E.:\
*Syntax directed transduction*\
Journal of the ACM\
Volume 15, Number 3, 1986, pp. 464-488\
