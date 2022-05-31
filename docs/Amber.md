`compilertools.net, Technical Report, 2001`\

AMBER, An Ambiguity Checker for Context-free Grammars
=====================================================

*Friedrich Wilhelm Schröer*\
Fraunhofer Institute for Computer Architecture and Software Technology\
`f.w.schroeer@first.fraunhofer.de`

Introduction
------------

General compiler tools such as ACCENT \[2\] allow the processing of any
context-free grammar. This includes ambiguous grammars, i.e. grammars
for which there are valid source texts that have more than one parse
tree. Because the semantics of the source text is determined by the
parse tree (the phrase structure) of the source text, such a text may
have assigned different meanings for different parse trees.

ACCENT allows the user to annote grammrs to resolve ambiguities. It also
offers a default strategy. Unless an ambiguity is resolved in this way,
it is detected at parsing time whether a given text is ambiguous.

AMBER can check a grammar statically. If ambiguities are detected, AMBER
gives hints how to resolve them by annotations.

In general it is undecidable whether a given grammar is ambiguous. But
if a given grammar is ambiguous this can be detected by enumerating and
checking the token strings of a language. If such an algorithm presents
a text with two different parsing trees we know that the grammar is
ambiguous. But if the grammar is unambiguous the algorithm may not
terminate.

AMBER is a tool that systematically generates example strings of a given
grammar and checks them for ambiguity. Because this is done using an
highly efficient algorithm it is realistic to check millions of such
examples in short time. Whenever two examples have a common prefix the
prefix is inspected only once.

Hence one has a good chance to detect a problem. Nevertheless, the user
should be aware of the fact that the search space in general is infinite
and that the number of examples grows exponentially with their length.
AMBER has a number of options to influence the search. For example, the
user can choose to inspect all examples up to a given length or a
randomly selected subset allowing examples of greater length in
reasonable time.

Preparation
-----------

AMBER is a fixed module that works for all grammars. The specific
grammar must be provided by a grammar module that is generated with
ACCENT. This grammar module is linked with the AMBER module resulting in
a checker for the specific grammar.

AMBER does not report ambiguities that are explicitely resolved by user
annotations. The grammar specification for ACCENT should use
`%nodefault` in order to switch off the default ambiguity resolution.

If `spec.acc` is a grammar in the ACCENT grammar language, then the
command

-   `accent spec.acc`

generates a grammar module `yygrammar.c`. This grammar module and the
AMBER module are then compiled and linked:

-   `gcc -o amber -O3 yygrammar.c amber.c`

This results in an executable program `amber`. The program can than be
used to check the given grammar. For example

-   `amber examples 1000000`

is used to check one million examples.

Usage
-----

AMBER is invoked by the command

-   `amber option ...`

where option is one of

-   `examples n`\
-   `length n`\
-   `percentage n`\
-   `limit n`\
-   `from n`\
-   `check symbol`\
-   `each`\
-   `iterate`\
-   `ellipsis`\
-   `source`\
-   `silent`\

At least `examples n` or `length n` must be specified to limit the
search space.

Options
-------

### `examples n`

Inspect `n` examples. An *example* is a path in the search tree from the
root to a point where search terminates because the actual token string
cannot be continued or where options limit the search depth. Note that
also prefixes of an example are checked. AMBER tries to balance the
number of examples at branches in the search tree. This may cause the
number of actually inspected example to differ slightly from `n`.

### `length n`

Inspect examples up to length `n`.

### `percentage n`

If a token string can be correctly continued with *k* different tokens,
consider only `n` percent of them.

### `limit n`

If a token string can be correctly continued with *k* different tokens,
consider only `n` of them. (This option can be combined with
`percentage`.)

### `from n`

This is used to form groups with different `percentage` and `limit`
values. From position `n` of the generated example up the next `from`
value (or the end of the example) use the values specified in the next
`percentage` and/or `limit` options.

Example

-   `amber length 10 from 3 limit 3 from 6 percentage 50 from 8`

From 1 up to 2 all tokens are considered. From 3 to 5 at most 3 tokens
are considered. From 6 to 7 50 percent of the tokens are considered.
From 8 to 10 again all possible tokens are considered.

### `ellipsis`

Consider nonterminals also as tokens, i.e. give tokens appearing after a
phrase for the nonterminal a better change to be considered. Increases
the probability to find longer examples of ambiguity.

### `check symbol`

Check only phrases for nonterminal `symbol`. This can be used to skip
irrelevant introductory tokens and hence increase the probability to
uncover a problem with the specified nonterminal.

### `each`

This options behaves like `check` applied to all nonterminals in
sequence (the value of the `examples` option applies separately to each
nonterminal).

### `iterate`

This options repeats the amber command again and again without resetting
the random number generator. It only makes sense when random search is
invoked using the `percentage` or `limit` option.

### `source`

Print the tokens of the actual example.

### `silent`

No progress information is displayed. This decreases the runtime
significantly.

Output
------

Ambiguity information is written onto *standard output*. If an ambiguity
is detected two different derivations for the particular nonterminal are
emitted. Each kind of ambiguity is reported only once. The program
explains how the ambiguity could be resolved by an annotation.

Progress information is displayed on *stderr*.

Algorithm
=========

AMBER is based on Earley\'s general parsing algorithm\[1\]. Earley\'s
recognizer is turned into a synthesizer and has been extended to detect
ambiguities on the fly. AMBER has been derived from ENTIRE \[3\].

The Recognizer
--------------

Earley\'s recognizer can be sketched as follows.

When a rule is processed we use a \"dot\" (denoted by \"`*`\") to
indicate the actual position inside the rule. For example, in

       N : M_1 ... * M_i ... M_n

the next symbol being to be processed is `M_i`. Such a \"dotted rule\"
is called an *item*.

An item has also a \"back-pointer\" to find items that triggered the
actual one (I do not discuss this here).

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

The Synthesizer
---------------

We turn Earley\'s recognizer into a synthesizer.

When the algorithm has processed *i* tokens it has constructed *i* item
lists that contain all information to parse all continuations of the
token list. The last item list has items of form

       M : ... * 't' ...

that will be processed by the Scanner to construct the kernel of the
next item list. All tokens `'t'` in those items are valid continuations
of the current token string.

We collect these in a list of valid tokens and treat each separately as
if it would have been the next source token and construct the next item
list. This is embedded into a recursive procedure that extends a given
token string of length *n* :

    extend (n)
    {
       if (search ends at n) return;

       l = list of valid tokens;

       for (each s in l)
       {
          let s be the next token;
          next_item_list();
          extend(n+1);
       }
    }

Using this approach, only valid token sequences are considered. Instead
of parsing each example separately and from the beginning, examples with
common prefixes are parsed together where the prefix is processed only
once.

References
----------

  ------- ------------------------------------------------------------------------------
  \[1\]   Earley, J.:\
          *An Efficient Context-Free Parsing Algorithm*\
          Communications of the ACM\
          Volume 13, Number 2, February 1970, pp. 94-102\

  \[2\]   Schröer, F.W.:\
          *ACCENT, A Compiler Compiler for the Entire Class of Context-free Grammars*\
          compilertools.net, Technical Report, 2000

  \[3\]   Schröer, F.W.:\
          *ENTIRE, A Generic Parser for the Entire Class of Context-free Grammars*\
          compilertools.net, Technical Report, 2000
  ------- ------------------------------------------------------------------------------
