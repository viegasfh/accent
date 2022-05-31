`compilertools.net, Technical Report, 2000, Second Edition 2006`

# ACCENT, A Compiler Compiler for the Entire Class of Context-free Grammars

*Friedrich Wilhelm Schröer*<br/>
Fraunhofer Institute for Computer Architecture and Software Technology<br/>
`f.w.schroeer@first.fraunhofer.de`

## Introduction

### Compiler Compilers

Compiler compilers like Yacc or Accent are used to generate language
processors (such as compilers, translators, or interpreters) from
high-level descriptions. You specify the grammar of your language, and
the compiler compiler creates a program that processes input text
written in your language. This program hierarchically decomposes the
input text into phrases. For each kind of phrase you can attach semantic
actions to your grammar which are elaborated when the corresponding
phrase is processed.

### Yacc and Other Compiler Compilers

Compiler compilers like Yacc are based on the LALR approach. This
results in very efficient parsers and covers a large range of grammars.
But unfortunately a user has to be familiar with this technique when his
or her grammar does not fulfill its restrictions. When confronted with
"shift/reduce" or "reduce/reduce" conflicts (that indicate a
violation of the LALR property) the user has to adapt the grammar. This
often requires an insight into the working of the parser and in many
cases complicates the description of the language.

Other systems use LL parsing. Conflicts that are reported by an LL
generator have a more intuitive interpretation than LALR conflicts. On
the other hand, these systems are even more restrictive. For example,
the natural grammar for arithmetic expressions cannot be used because
the approach cannot deal with left-recursive rules.

In both cases the design of the grammar is influenced by the parser
implementation technique.

This can be avoided with Accent.

### The Accent Compiler Compiler

Accent does not rely on specific subclasses of context-free grammars. A
user does not have to be familiar with parsing technology.

Accent can be used like Yacc. It also cooperates with Lex. The
specification language of Accent is similar to that of Yacc, but Accent
uses symbolic names for attributes instead of Yacc's error-prone
numbers. It allows you to write your grammar in the
Extended-Backus-Naur-Form, in which you can specify repetition, choices,
and optional parts without introducing special rules for this purpose.
In Accent, semantic actions can be inserted anywhere, there are no
restrictions caused by the parser implementation.

Accent even allows ambiguous grammars. Ambiguities are resolved
automatically following a default strategy or according to annotations
specified by the user.

# How to Describe Languages

### Grammars

The user describes the language by providing a grammar. Such a grammar
is given by rules.

A rule describes how to build a particular construct of the language.
This is done by listing one or more alternatives how to build the
construct from constituents.

For example, if we define a programming language, we can express the
fact that a `program` is constructed from a `declaration_part` and a
`statement_part` by the rule

       program : declaration_part statement_part ;

A rule has a left hand side that names the construct defined by the
rule. A colon ("`:`") separates the left hand side from the right hand
side. The right hand side specifies how to build the construct. A
semicolon ("`;`") terminates the rule.

The name on the left hand side is called a nonterminal. A nonterminal
may be used in right hand sides to specify constituents. The possible
representations defined by a nonterminial are called the phrases of the
nonterminal.

The rule above says that phrases for `program` are composed from a
phrase for `declaration_part` followed by a phrase for `statement_part`.

A rule may provide more than one alternative. Here is a specification of
the nonterminal `statement`:

       statement :
          variable '=' expression
       |  IF expression THEN statement ELSE statement
       |  WHILE expression DO statement
       |  BEGIN statement_seq END
       ;

It describes four alternatives how to construct a statement.
Alternatives are separated by a bar ("`|`").

The nonterminal that is defined by the first rule of the grammar is
called the start symbol. The phrases of the start symbol constitute the
language defined by the grammar.

Grammars of this kind are called context-free grammars. Accent can
process all context-free grammars without restriction.

### Lexical Elements

Nonterminal symbols are defined by rules. There are also elementary
items called terminal symbols or tokens.

They may be given literally, if they are represented by a single
character. For example, the `'='` element in the first alternative for
`statement` stands for the character "`=`".

They may also be referred by a symbolic name such as `IF` in the second
alternative for `statement`. In our language an `IF` symbol could be
represented by the two character string "`if`". Such a mapping from
strings to tokens is not defined by the Accent specification. In Accent,
one just introduces symbolic names that are used for terminal symbols.

For example,

       %token IF, THEN, ELSE, WHILE, DO, BEGIN, END;

introduces names for the tokens in the rule for `statement`.

The declaration precedes the first rule of the grammar.

The actual representation is given by rules for a further tool: The
generator Lex can be used to create a lexical analyzer that partitions
the input text into tokens. A specification for Lex is a list of lexical
rules.

A lexical rule states a pattern (a regular expression) that matches the
token and an action that is carried out when the token is recognized.
Here is are two example rules:

       "="  { return '='; }
       "if" { return IF;  }

If "`=`" is recognized then the code of the character `'='` is
returned as an indicator. If "`if`" is recognized then the value of
the constant `IF` is returned.

A token may have a more complex structure. An example is the token
`NUMBER` which represents a sequence of digits. This can be specified by
a Lex rule like this:

    [0-9]+ { return NUMBER; }

A string that matches the pattern `[0-9]+` (i.e. a sequence of digits)
is indicated as a `NUMBER`.

The lexical analyzer (described in the Lex specification) structures the
input into a sequence of tokens. The syntactical analyzer (described in
the Accent specification) hierarchically structures this sequence into
phrases.

An item is specified as token if it has a fixed representation such as
"`=`" or "`if`" or if it can be defined by a simple expression such
as the pattern for `NUMBER`. In many cases tokens are those items that
can be separated by additional white space. A Lex rule can specify to
skip white space so that it can be ignored in the syntactical grammar.

The Lex rule

       " " { /* skip blank */ }

skips blanks by not returning a token indicator.

### A Grammar for Expressions

We now present a simple but complete example: a grammar for expressions
like

       10+20*30

Here is the Accent specification:

       01  %token NUMBER;
       02  
       03  expression :
       04    term
       05  ;
       06  
       07  term :
       08    term '+' factor
       10  | term '-' factor
       11  | factor
       12  ;
       13  
       14  factor :
       15    factor '*' primary
       16  | factor '/' primary
       17  | primary
       18  ;
       19  
       20  primary :
       21    NUMBER
       22  | '(' term ')'
       23  | '-' primary
       24  ;

These rules not only define what constitutes a valid expression but also
give it structure. The different nonterminals reflect the binding
strength of the operators. The operators of a factor ("`*`" and
"`/`") have a stronger binding than the operators of a term ("`+`"
and "`-`") because `factor` is a constituent of a `term` (a `term`
appearing inside a `factor` must be enclosed in parentheses).

For example, the input

       10+20*30

is structured as follows:

       expression
       |
       +-term
         |
         +-term
         | |
         | +- factor
         |    |
         |    +-primary
         |      |
         |      +-NUMBER
         |
         +-'+'
         |
         +-factor
           |
           +-factor
           | |
           | +-primary
           |   |
           |   +-NUMBER
           |
           +-'*'
           |
           +-primary
         |
             +-NUMBER

or more precisely (this representation, generated with Accent, specifies
which alternative has been chosen and lists in curly braces the
constituents):

       expression alternative at line 4, col 6 of grammar {
         term alternative at line 8, col 6 of grammar {
           term alternative at line 10, col 8 of grammar {
             factor alternative at line 16, col 9 of grammar {
               primary alternative at line 20, col 8 of grammar {
                 NUMBER
               }
             }
           }
           '+'
           factor alternative at line 14, col 8 of grammar {
             factor alternative at line 16, col 9 of grammar {
               primary alternative at line 20, col 8 of grammar {
                 NUMBER
               }
             }
             '*'
             primary alternative at line 20, col 8 of grammar {
               NUMBER
             }
           }
         }
       }

The tree above indicates that

       10+20*30

is structured as

       10+(20*30)

and not as

       (10+20)*30

Here is the Lex specification for the expression grammar:

       %{
       #include "yygrammar.h"
       %}
       %%
       "+"    { return '+'; }
       "-"    { return '-'; }
       "*"    { return '*'; }
       "/"    { return '/'; }
       [0-9]+ { return NUMBER; }
       " "    { /* skip blank */ }
       \n     { /* skip newline */ }
       .      { yyerror("illegal token"); }

(The file `yygrammar.h`, which is included in the header of the Lex
specification, is generated by Accent and contains the definition of the
constant `NUMBER`.)

## How to Assign Meaning

### Semantic Actions

From the above grammar Accent generates a program that analyzes its
input syntactically: it rejects all texts that do not conform to the
grammar.

In order to process the input semantically we have to specify semantic
actions. These actions may be embedded into the grammar at arbitrary
positions. They are executed when the particular alternative is
processed. The members of a selected alternative are processed from left
to right.

A semantic action is arbitrary C code inclosed in curly braces. The text
(without the braces) is copied verbatim into the generated program.

Here is an example

       N:
          { printf("1\n"); } A { printf("2\n"); } B { printf("3\n"); }
       |  { printf("x\n"); } C { printf("y\n"); }
       ;

       A: 'a' { printf("inside A\n"}; };
       B: 'b' { printf("inside B\n"}; };
       C: 'c' { printf("inside C\n"}; };

For the input

       a b

the generated program produces the output

       1
       inside A
       2
       inside B
       3

For each nonterminal Accent generates a tree walker function. Here is
the code generated for `N` (slightly edited and without `#line` pragmas
for C preprocessor):

       N ()
       {
          switch(yyselect()) {
          case 1:
         {
            printf("1\n"); 
            A();
            printf("2\n"); 
            B();
            printf("3\n"); 
         }
         break;
          case 2:
         {
            printf("x\n"); 
            C();
            printf("y\n"); 
         }
         break;
          }
       }

### Attributes of Nonterminals

Like functions in C, nonterminal can have parameters. Parameters may be
of mode `in` or `out`. `in` parameters are used to pass information from
the context to a particular nonterminal (often called inherited
attributes). `out` parameters pass information from a nonterminal to its
context (often called synthesized attributes). At the left hand side of
rule the name of the nonterminal is followed by a signature that
specifies mode, type, and name of parameters. The signature is enclosed
in the braces "`<`" and "`>`".

For example

       N < %in int context, %out int result > : ... ;

`N` has an input parameter `context` and an output parameter `result`,
both are of type `int`.

If a nonterminal appears on the right hand side, actual parameters
follow the nonterminal name, enclosed in "`<`" and "`>`".

For example

       N<actual_context, actual_result>

Parameters can be accessed inside semantic actions. The values of input
parameters must be defined inside semantic actions or be the output of
other members.

For example

       demo :
          { actual_context = 10; }
          N<actual_context, actual_result>
          { printf("%d\n", actual_result); }
       ;

An alternative for a nonterminal must define its output parameters,
either by using them as output parameters for members or by assigning a
value inside a semantic action. If an output parameter of the left hand
side (a formal output parameter) is used inside a semantic action, it
must be dereferenced with the "`*`" operator (output parameters are
passed by reference to the generated tree walker function).

For example

       N<%in int context, %out int result> : { *result = context+1; } ;

An elaboration of `demo` prints `11`.

Here are the generated functions:

    demo ()
    {
       int actual_context;
       int actual_result;

       switch(yyselect()) {
       case 1:
          {
         actual_context = 10; 
         N(actual_context, &actual_result);
         printf("%d\n", actual_result); 
          }
          break;
       }
    }

    N (context, result)
       int context;
       int *result;
    {
       switch(yyselect()) {
       case 2:
          {
             *result = context+1; 
          }
          break;
       }
    }

As you see, identifiers that appear as parameters of nonterminals are
automatically declared.

Formal parameters, if present, are specified in the form

       < %in parameter_specifications %out parameter_specifications >

where either the `%in` group or the `%out` group may be omitted.

The most frequent case, where we have only output parameters, can simply
be written without a mode indicator:

       < parameter_specifications >

`parameter_specifications` is a list of the form

       Type_1 Name_1 , ... , Type_n Name_n

The type may be omitted. In this case the special type `YYSTYPE` is
assumed. This may be defined by the user as a macro. If there is no user
specific definition `YYSTYPE` stands for `long`.

Hence in most cases a left hand side of a rule simply looks like this:

       Block<b> : ... 

### Attributes of Tokens

All items declared as tokens have an output parameter of type `YYSTYPE`.
If a token is used on the right hand side of a rule, an actual parameter
may be specified to access the attribute value of the token which is
computed by the scanner.

For example

        Value :
           NUMBER<n> { printf("%d\n", n); }
        ;  

Here `n` represents the numeric value of `NUMBER`. It can be used in the
semantic action.

The attribute value of a token must be computed in the semantic action
of the Lex rule for the token. It must be assigned to the special
variable `yylval` which is of type `YYSTYPE`.

For example if we want to access the value of a `NUMBER` the
corresponding Lex could be

       [0-9]+ { yylval = atoi(yytext); return NUMBER; }

The special variable `yytext` holds the string that matched the pattern.
The C function `atoi` converts it into a integer.

### Global Prelude

If `YYSTYPE` is defined by the user, it should be declared in an
`include` file, because it is used in the grammar as well as in the Lex
specification.

`#include` statements can be placed in the global prelude part at the
beginning of the grammar file. Text which is enclosed by

       %prelude {

and

       }

is copied verbatim into the generated program.

For example

       %prelude {
       #include "yystype.h"
       }

### Rule Prelude

Identifiers that are used as attributes need not be declared. One may
use semantic actions to declare additional variables (the curly braces
surrounding a semantic do not appear in the generated code).

For example

       demo :
          {int i = 0;} alternative_1 ;
       |  alternative_2
       ;

Such variables are local to the alternative. `i` is visible in the
sematic action of `alternative_1` but not in those of `alternative_2`

Variables that are visible to all alternatives (but local to the rule)
can be declare in rule prelude which has the same form as the global
prelude but appears before the alternative list of a rule.

For example

       demo :
          %prelude {int i = 0;}
          alternative_1
       |  alternative_2
       ;

`i` is visible in the sematic actions of both alternatives.

The rule prelude can also be used to provide code that should be execute
as initialization for all alternatives.

### A Calculator

We are now ready to turn the expression grammar into a calculator.

For this purpose nonterminals get an output parameter that holds the
numerical value of the phrase represented by the nonterminal. This value
is compute from the numerical values of the constituents.

For example, in the left hand side

       term<n> :

`term` gets an attribute `n`.

In the right hand side

         term<x> '+' factor<y> { *n = x+y; }

the nonterminal `term` gets an attribute `x` and the nonterminal
`factor` gets an attribute `y`. The attribute of the left hand side is
the computed as the sum of `x` and `y`.

Here is the complete grammar:

       %token NUMBER;

       expression :
         term<n> { printf("%d\n", n); }
       ;

       term<n> :
         term<x> '+' factor<y> { *n = x+y; }
       | term<x> '-' factor<y> { *n = x-y; }
       | factor<n>
       ;

       factor<n> :
         factor<x> '*' primary<y> { *n = x*y; }
       | factor<x> '/' primary<y> { *n = x/y; }
       | primary<n>
       ;

       primary<n> :
         NUMBER<n>
       | '(' term<n> ')'
       | '-' primary<x> { *n = -x; }
       ;

## How to Resolve Ambiguities

Accent can process all context-free grammars without any restrictions;
this also includes ambiguous grammars.

A grammar is said to be ambiguous if there are cases where the same text
can be processed in different ways. This sections describes how Accent
resolves such ambiguities and how the user can control this by
annotations.

We distinguish two classes of ambiguities that we call *disjunctive* and
*conjunctive* ambiguities.

### Disjunctive Ambiguities

In case of disjunctive ambiguities the same piece of text can be
processed by different alternative of the same nonterminal.

For example, consider:

    M:
       A
    |
       B
    ;

    A:
       "x" { printf("a\n"); }
    ;

    B:
       "x" { printf("b\n"); }
    ;

The input "`x`" can either produce the output "`a`" or the output
"`b`". This is because both alternatives for `M` (`A` and `B`) can be
applied. If more than one alternative can be applied, Accent selects the
last one. I.e., in the example `B` is selected and "`b` is printed.

The user can control the selection of alternatives by providing
annotations. Each alternatives has a certain priority. In case of
conflicts an alternative with a higher priority is selected. The default
priority of an alternative is its number if we count the alternatives
starting with 1. A priority can be explicitely defined by an annotaion

        %prio N

at the end of the alternative. `N` is the priority of the alternative.

For example, in

    M:
       A %prio 2
    |
       B %prio 1
    ;

the first alternative gets a higher priority than the second one and
will be selected in cases of conflicts.

### Conjunctive Ambiguities

In case of disjunctive ambiguities the same piece of text can be split
in differents ways to match the members of a single alternative.

For example, consider:

    M:
       A B
    ;

    A:
       'x' { printf("short A\n"); }
    |
       'x' 'x' { printf("long A\n"); }
    ;
    B:
       'x' { printf("short B\n"); }
    |
       'x' 'x' { printf("long B\n"); }
    ;

The input `x x x` can be split in two different ways to match the right
hand side of `M`: a single `x` recognized as `A` followed by a pair of
`x`'s recognized as `B`, or a pair of `x`'s recognized as `A` followed
by a single `x` recognized as `B`. In the first case the output is

       short A
       long B

in the second case it is

       long A
       short B

Accent resolves such an ambiguity by preferring the short version of the
last member (here `B` that contributes to such a conflict. Hence the
second interpretation is chosen.

However, the user can select a different choice: A `%short` or a `%long`
annotation can precede the member.

The definition

    M:
       A %short B
    ;

results in

       long A
       short B

whereas the definition

    M:
       A %short B
    ;

results in

       short A
       long B

### Ambiguity Handling without Defaults

Default ambiguity handling can be switched off by the option

        %nodefault

preceeding a group of rules. This option remains in effect until the end
of the grammar or until an option

        %default

preceedes a group of rules that again is processed with default
ambiguity handling.

If default ambiguity handling is switched off, an ambigouos input that
is not covered by annotations causes a run time message that explains
the different interpretations and gives advice how to to resolve the
ambiguity.

A companion tool, the *Amber* Ambiguity Checker, analizes the grammar
statically.

## How to Abbreviate Specifications

### Extended Backus Naur Form

So far we have only considered grammars where members of alternatives
are nonterminal and terminal symbols. A formalism of this kind was used
in the Algol 60 report and named after the editors of that document:
Backus Naur Form.

Accent also supports a notation that is known as Extended Backus Naur
Form. In this formalism one can write structured members to specify
local alternatives and optional and repetitive elements.

### Local Alternatives

A member of the form

       ( alt_1 | ... | alt_n )

can be used to specify alternative representations of a member without
introducing a new nonterminal.

For example, instead of

       signed_number :
          sign NUMBER
       ;

       sign :
          '+'
       |  '-'
       ;

one can write

       signed_number :
          ( '+' | '-' ) NUMBER
       ;

Semantic actions may be inserted. The actions of the selected
alternative are executed.

For example,

       signed_number<r> :
          { int s; }
          ( '+' { s = +1; } | '-' { s = -1; } ) NUMBER<n>
          { *r = s*n; }
       ;

### Optional Elements

A member can also have the form

       ( M_1 ... M_n )?

in which case the enclosed items `M_1`, \... , `M_n` may appear in the
input or not.

For example,

       integer :
          ( sign )? NUMBER
       ;

specifies specifies that `integer` is a `NUMBER` preceded by an optional
`sign`.

So both

       123

and

       + 123

are valid phrases for `integer`.

More than one alternative may be specified between "`(`" and "`)?`":

       ( alt_1 | ... | alt_n )?

For example,

       
        integer :
           ( '+' | '-' )? NUMBER
        ;

specifies that an `integer` is a `NUMBER` that is optionally preceded by
either a "`+`" or a "`-`".

In case of semantic actions, proper initialization is required, because
none of the alternative may be processed:

       integer<r> :
          { int s = +1; }
          ( '+' | '-' { s = -1; } )? NUMBER<n>
          { *r = s*n; }
       ;

### Repetitive Elements

A further form of a member is

       ( M_1 ... M_n )*

in which case the enclosed items `M_1`, \... , `M_n` may be repeated an
arbitrary number of times (including zero).

For example,

       number_list :
          NUMBER  ( ',' NUMBER )*
       ;

specifies that a `number_list` is given by at least one `NUMBER` which
is followed by arbitrary number of comma-separated `NUMBER`s.

Semantic action inside repetions are executed as often as there are
instances.

For example,

       number_list :
          NUMBER<sum>  ( ',' NUMBER<next> { sum += next;} )*
          { printf("%d\n", sum); }
       ;

adds all the numbers and prints their sum.

Again, several alternatives may specified:

       ( alt_1 | ... | alt_n )*

For example,

       statements :
          ( simple_statement | structured_statement )*
       ;

`statements` matches an arbitrary number of statements, each of which
may be a `simple_statement` or a `structured_statement`.

## How to Prepare the Lexer

### The Scanner Function

The representation of terminal symbols (tokens) is not defined by the
*Accent* specification. An *Accent* parser cooperates with a lexical
scanner that converts the source text into a sequence of tokens. This
scanner is implemented by a function `yylex()` that reads the next token
and returns a value representing the kind of the token.

### The Kind of a Token

The kind of a token is indicated by a number.

A terminal symbol denoted by a literal in the *Accent* specification,
e.g. `'+'`, is represented by the numerical value of the character. So
`yylex()` returns this value if it has recognized this literal:

       return '+';

A terminal symbol denoted by a symbolic name declared in the token
declaration part of the *Accent* specification, e.g. `NUMBER`, is
represented by a constant with a symbolic name that is the same as the
token name. So `yylex` returns this constant:

       return NUMBER;

The definition of the constants is generated by *Accent* and is
contained in the generated file `yygrammar.h`. Hence the file
introducing `yylex` should include this file.

       #include "yygrammar.h"

### The Attribute of a Token

Besides having a kind (e.g. `NUMBER`) a token can also be augmented with
a semantic attribute. The function `yylex` assigns this attribute value
to the variable `yylval`. For example

       yylval = atoi(yytext);

(here `yytext` is the actual token that has been recognized as a
`NUMBER`; the function `atoi()` converts this string into a numerical
value).

The variable `yylval` is declared in the generated file `yygrammar.c`.
An `external` declaration for this variable is provided in the generated
file `yygrammar.h`.

`yylval` is declared as of type `YYSTYPE`. This is defined by *Accent*
in the file `yygrammar.h` as a macro standing for `long`.

       #ifndef YYSTYPE
       #define YYSTYPE long
       #endif

The user can define his or her own type before including the file
`yygrammar.h`. For example, a file `yystype.h` may define

       typedef union {
          int intval;
          float floatval;
       } ATTRIBUTE;

       #define YYSTYPE ATTRIBUTE

Now the file defining `yylex()` imports two header files:

    #include "yystype.h"
    #include "yygrammar.h"

and defines the semantic attribute by:

       yylval.intval = atoi(yytext);

### The *Lex* Specification

The function `yylex` can be generated by the scanner generator *Lex* (or
the GNU implementation *Flex*).

A *Lex* specification gives rules that define for each token how it is
represented and how it is processed. A rule has the form

       pattern { action }

`pattern` is a regular expression that specifies the representation of
the token.

`action` is *C* code that specifies how the token is processed. This
code sets the attribute value and returns the kind of the token.

For example, here is a rule for the token `NUMBER`:

       [0-9]+ { yylval.intval = atoi(yytext); return NUMBER; }

The *Lex* specification starts with a definition section which can be
used to import header files and to declare variables. For example,

       %{
       #include "yystype.h"
       #include "yygrammar.h"
       %}
       %%

Here the section imports `yystype.h` to provide a user specific
definition of `YYSTYPE` and `yygrammar.h` that defines the token codes.
The `%%` separates this section from the rules part.

### The *Accent* Specification

In the *Accent* specification, tokens are introduced in the token
declaration part.

For example

       %token NUMBER;

introduces a token with name `NUMBER`.

Inside a rule the token can be used with a parameter, for example

       NUMBER<x>

This parameter can then be used in actions to access the attribute of
the token. It is of type `YYSTYPE`.

       Value : NUMBER<x> { printf("%d", x.intval); } ;

or simply

       Value : NUMBER<x> { printf("%d", x); } ;

if there is no user specific definition of `YYSTYPE`.

As opposed to the *Lex* specification the import of `yygrammar.h` does
not appear in the *Accent* specification. If the user specifies an own
type `YYSTYPE` this has to be done in global prelude part, e.g.

       %prelude {
       #include "yystype.h"
       }

### Tracking the Source Position

Like `yylval`, which holds the attribute of a token, there is a further
variable, `yypos`, thats holds the source position of the token.

`yypos` is declared in the *Accent* runtime as an `external` variable of
type `long`. Its initial value is `1`.

This variable can be set in rules of the *Lex* specification. For
example,

       \n     { yypos++; /* adjust linenumber and skip newline */ }

If the newline character is seen, `yypos` is incremented and so holds
the actual line number.

The variable `yypos` is managed in in such a way that it holds the
correct value when `yyerror` is invoked to report a syntax error
(although due to lookahead already the next token is read).

It has also a correct value when semantic actions are executed (note
that this is done after lexical analysis and parsing). Hence it can be
used inside semantic actions, for example

       value:
          NUMBER<n> { printf("value in line %d is %d\n", yypos, n); }
       ;

## How to Generate a Language Processor

### Installing Accent

Unpack the distribution file and go to directory `accent`. Run the file
`build` to compile *Accent*. Distributed `build` scripts run Windows
with Cygwin and under Linux. You may have to adapt them to your local
settings. The system and the generated software should not contain
platform dependencies.

Go to directory `exmplaccent` and type `build` to run a first example.

### Cooperation of Tools

+-----------------------------------------------------------------------+
|                                                                       |
|       spec.acc     spec.lex  auxil.c  art.o                           |
|        |            |         |        |                              |
|        |            |         |        |                              |
|        V            V         |        |                              |
|       +------+     +---+      |        |                              |
|       |ACCENT|     |LEX|      |        |                              |
|       +------+     +---+      |        |                              |
|        |            |         |        |                              |
|        |            |         |        |                              |
|        V            V         |        |                              |
|       yygrammar.h  lex.yy.c   |        |                              |
|       yygrammar.c   |         |        |                              |
|        |            |         |        |                              |
|        +------------+--+------+--------+                              |
|                        |                                              |
|                        V                                              |
|                       +--+                                            |
|                       |CC|                                            |
|                       +--+                                            |
|                        |                                              |
|                        |                                              |
|                        V                                              |
|                       calculator                                      |
+-----------------------------------------------------------------------+

### Accent

*Accent* is invoked with the command

       accent file

This reads the grammar in `file` and generates the output files
`yygrammar.h` and `yygrammar.c`.

`yygrammar.h` contains definitions of token codes and a definition of
the type `YYSTYPE` (which is only effective if there is no previous
definition specified by the user).

`yygrammar.c` contains the grammar encoding and a generated tree walker
that performs the semantic actions specified by the user.

Example:

       accent spec.acc

The file `exmplaccent/spec.acc` contains the *Accent* specification of a
simple desk calculator.

### Lex

The scanner should be generated with *Lex*. *Lex* is invoked by the
command

       lex file

which reads the specification in `file`, a table of regular expressions
and corresponding actions, and generates a file `yy.lex.c`. This file
contains the function `yylex()`, the lexical analyzer which is invoked
by the parser.

Example:

       lex spec.lex

The file `exmplaccent/spec.lex` contains the *Lex* specification for the
desk calculator.

### Auxiliary Functions

The user has to prepare some auxiliary functions:

There should be a `main()` function that invokes the parser function
`yyparse()`.

`yyerror(char *msg)` is invoked by the parser when an error is detected.
It should print the text `msg` and perhaps the current line number.

The scanner needs a function `yywrap()` (it can be used to switch to a
further input file). In its simplest form it just returns `1`
(indicating no further input file).

In our example, the file `exmplaccent/auxil.c` defines these functions.

### Generic Parser

To create a functioning compiler one also has to supply the *Entire*, a
generic parser module. It is provided together with *Accent*.

### Compiling and Linking

The *C* compiler is used to compile the sources and create the object
program.

Example:

    cc -o calculator yygrammar.c lex.yy.c auxil.c $ENTIRE

(where `$ENTIRE` refers to the *Entire* parser).

The file `exmplaccent/build` contains a shell script to produce and run
the desk calculator.

Invoking the optimizer during compilation increases parser speed by a
factor of two. For the GNU C compiler you should specify `-O3` as an
option when compiling the Accent runtime and the generated program.

## Appendix: The Accent Grammar Notation

### Conventions

The *Accent* Grammar Notation is described by rules of the form

       N :
          M11 M12 ...
       |  M21 M22 ...
          ...
       ;

which state that a phrase for N is composed from phrases for M11 and M12
and \... or from phrases for M21 and M22 \... , etc.

Terminal symbols are enclosed in double quotes, e.g. `"%out"`.

In addition, the terminal symbol `identifier` denotes a sequence of one
or more letters, digits, and underscores ("`_`"), starting with a
letter.

The terminal symbol `number` denotes a sequence of one or more digits.

The terminal symbol `character_constant` denotes a character constant as
in the *C* language.

The terminal symbol `c_code` represents arbitrary *C* code (comments in
this code must be closed and curly braces much match).

### Grammar

------------------------------------------------------------------------

    grammar :
       global_prelude_part token_declaration_part rule_part
    ;

------------------------------------------------------------------------

The *Accent* Grammar Notation is the set of phrases for the symbol
`grammar`.

### Global Prelude

------------------------------------------------------------------------

    global_prelude_part :
       global_prelude
    |  empty
    ;

    global_prelude :
       "%prelude" block
    ;

    block :
       "{" c_code "}"
    ;

    empty :
    ;

------------------------------------------------------------------------

The optional `global_prelude_part` serves to introduce user defined
functions, global variables, and types. The text enclosed in curly
braces is inserted verbatim at the beginning of the generated program
file.

### Token Declarations

------------------------------------------------------------------------

    token_declaration_part :
       "%token" token_declaration_list ";"
    |  empty
    ;

    token_declaration_list :
       token_declaration "," token_declaration_list
    |  token_declaration
    ;

    token_declaration :
       identifier
    ;

------------------------------------------------------------------------

The optional `token_declaration_part` introduces symbolic names for
terminal symbols (tokens). A name must not appear more than once in the
list.

These names may be used as members of grammatical rules. The actual
representation of the corresponding terminal symbols must be defined by
lexical rules that are not part of the *Accent* specification.

As opposed to nonterminal symbols, terminal symbols are declared without
parameters. Nevertheless they have an implicit output parameter of type
`YYSTYPE` which (if used) must be defined in the corresponding lexical
rule.

### Rules

------------------------------------------------------------------------

    rule_part :
       rule_list
    ;

    rule_list :
       rule_list_element rule_list
    |  rule_list_element
    ;

    rule_list_element :
       rule
    |  default_spec
    ;

    rule :
       left_hand_side ":" right_hand_side ";"
    ;

    default_spec :
       "%default"
    |  "%nodefault"
    ;

------------------------------------------------------------------------

A nonterminal is defined by a rule that lists one or more alternatives
how to construct a phrase of the nonterminal.

The first rule specifies the start symbol of the grammar. The language
defined by the grammar is given by the phrases of the start symbol.

A group of rules may preceded by a specification of the form %default or
%nodefault (if the first rule is not preceded by such a specification
%default is assumed). %default specifies that for the following rules
default ambiguity annotations should be assumed, if %nodefault is
specified then there are no default ambiguity annotations.

### Left Hand Side of a Rule

------------------------------------------------------------------------

    left_hand_side :
       nonterminal formal_parameter_spec
    ;

    nonterminal :
       identifier
    ;

------------------------------------------------------------------------

The `left_hand_side` of a rule introduces the nonterminal that is
defined by the rule. It also specifies parameters of the nonterminal,
they represent the semantic attributes of the nonterminal.

The value of these parameters must be defined by semantic actions in the
alternatives of the body of the rule. When the nonterminal is used as a
member in the body of a rule, actual parameters are attached. Using
theses parameters, the attributes of the corresponding nonterminal can
be accessed.

------------------------------------------------------------------------

    formal_parameter_spec :
       empty
    |  "<" parameter_spec_list ">"
    |  "<" "%in" parameter_spec_list ">"
    |  "<" "%out" parameter_spec_list ">"
    |  "<" "%in" parameter_spec_list "%out" parameter_spec_list ">"
    ;

    parameter_spec_list :
       parameter_spec "," parameter_spec_list
    |  parameter_spec
    ;

------------------------------------------------------------------------

Parameters may be of mode `in` or mode `out`. If no mode is specified,
all parameters are of mode `out`. Otherwise, parameters are of mode `in`
if they appear in a list preceded by `%in`; they are of mode `out` if
the list is preceded by `%out`.

An `in` parameter (inherited attribute) passes a value from the
application of a nonterminal to the right hand side defining the symbol.
It is used to pass context information to a rule.

An `out` parameter (synthesized attribute) passes a value from the right
hand side defining a symbol to the application of the symbol. It is used
to pass the semantic value of a rule to the context.

------------------------------------------------------------------------

    parameter_spec :
       parameter_type_opt parameter_name
    ;

    parameter_type_opt :
       parameter_type
    |  empty
    ;

    parameter_type :
       identifier
    ;

    parameter_name :
       identifier
    ;

------------------------------------------------------------------------

A parameter specification may be written in the form *type* *name* in
which case *type* is the type of the parameter *name*. If the *type* is
missing, the parameter is of type `YYSTYPE` (which is also the type of
tokens). `YYSTYPE` is equivalent to `long` if not defined by the user.

The start symbol of the grammar must have no parameter.

### Right Hand Side of a Rule

------------------------------------------------------------------------

    right_hand_side :
       local_prelude_option alternative_list
    ;

    local_prelude_option :
       local_prelude
    |  empty
    ;

    local_prelude :
       "%prelude" block
    ;

------------------------------------------------------------------------

The right hand side of a rule specifies a list of alternatives. This
list may be preceded by a prelude that introduces common declarations
and initialisation statement in *C*. In the generated program the
content of `block` (without the enclosing parentheses) precedes the code
generated for the alternatives of the rule. The items declared in the
prelude are visible within all alternatives.

### Alternatives

------------------------------------------------------------------------

    alternative_list :
       alternative "|" alternative_list
    |  alternative
    ;

    alternative :
       member_list alternative_annotation_option
    ;

    member_list :
       member member_list
    |  empty
    ;

    alternative_annotation_option :
       alternative_annotation
    |  empty
    ;

    alternative_annotation :
       "%prio" number
    |   "%disfilter" number
    ;

------------------------------------------------------------------------

The alternatives appearing on the right hand side of a rule specify how
to construct a phrase for the nonterminal of the left hand side. An
alternative is a sequence of members. These members may be nonterminal
symbols, token symbols, or literals (terminal symbols that appear
verbatim in the grammar). The right hand side may be written as an
regular expression constructed by grouping, option, and repetition. At
all places semantic actions may be inserted.

If two alternatives of a nonterminal can produce the same string
("disjunctive ambiguity") then both alternatives must be postfixed by
an annotation of the form

       %prio N

`N` defines the priority of the alternative. The alternative with the
higher priority is selected.

If the the annotion is missing and the %default specification is in
effect, then

       %prio N

is implicitely assumed, where N is the number of the alternative.

A disjunctive ambiguity can also be resolved algorithmicly by specifying

       %disfilter N1

and

       %disfilter N2

as annotations of conflicting alternatives. In case of conflicting items
I1 and I2, the function call

       disfilter(N1, N2, I1, I2)

must resolve the ambiguity.

### Members

------------------------------------------------------------------------

    member :
       member_annotation_option item
    ;

    member_annotation_option :
       member_annotation
    |  empty
    ;

    member_annotation :
       "%short"
    |  "%long"
    |   "%confilter" number
    ;

    item :
       symbol
    |  literal
    |  grouping
    |  option
    |  repetition
    |  semantic_action
    ;

------------------------------------------------------------------------

If the same alternative can produce can produce the same string in more
than one way because members of that alternative can cover substrings of
that string of different length ("disjunctive ambiguity"), the
rightmost of these members must be prefixed with an annotation of the
form

       %short

or

       %long

If the member is prefixed by "`%short`" (resp. "`%long`") the
variant that produces the short (resp. long) substring is selected.

If the the annotion is missing and the %default specification is in
effect, then

       %short

is implicitely assumed.

A conjunctive alternative can also be resolved algorithmicly by
specifying

       %confilter N

as a member annotation. In case of conflicting items I1 and I2, the
function call

       confilter(N, I1, I2)

must resolve the ambiguity.

### Simple Members

------------------------------------------------------------------------

    symbol :
       symbol_name actual_parameters_option
    ;

    symbol_name :
       identifier
    ;

------------------------------------------------------------------------

The symbol name must be declared as a nonterminal (by specifying a rule
for the identifier) or as a token (by listing the identifier in the
token declaration part).

------------------------------------------------------------------------

    actual_parameters_option :
       actual_parameters
    |  empty
    ;

    actual_parameters :
       "<" actual_parameter_list ">"
    ;

    actual_parameters_list :
       actual_parameter "," actual_parameter_list
    |  actual_parameter
    ;

    actual_parameter :
       identifier
    ;

------------------------------------------------------------------------

For each formal parameter of the symbol there must be a corresponding
actual parameter. A parameter must be an identifier.

In the generated *C* code, this identifier is declared as a variable of
the type of the corresponding formal parameter. The same parameter name
may be used at different places but then the type of the positions must
be identical.

------------------------------------------------------------------------

    literal :
       character_constant
    ;

------------------------------------------------------------------------

Besides being declared as a token, a terminal symbol can also appear
verbatim as a member of rule.

### Structured Members

------------------------------------------------------------------------

    grouping :
       "(" alternative_list ")"
    ;
    option :
       "(" alternative_list zero_annotation_option ")?"
    ;

    repetition :
       "(" alternative_list zero_annotation_option ")*"
    ;
    zero_annotation_option :
       zero_annotation
    | empty
    ;

    zero_annotation :
       "%zero" alternative_annotation_option
    ;

------------------------------------------------------------------------

A construct

       ( alt_1 prio_1 | ... | alt_n prio_n )

is aequivalent to

       Subphrase

is defined as in

       Subphrase:
          alt_1 prio_1
       |
          ...
       |
          alt_n prio_n
       ;

A construct

       ( alt_1 prio_1 | ... | alt_n prio_n )?

is aequivalent to

       Subphrase

is defined as in

       Subphrase:
          alt_1 prio_1
       |
          ...
       |
          alt_n prio_n
       |
          prio_n+1
       ;

where the default value of `prio_n+1` is `%prio n+1`.

`prio_n+1` can be defined explicitely as in

       ( alt_1 prio_1 | ... | alt_n prio_n %zero prio_n+1 )?

A construct

       ( alt_1 prio_1 | ... | alt_n prio_n )*

is aequivalent to

       Subphrase

is defined as in

       Subphrase:
          alt_1 subphrase_anno Subphrase prio_1
       |
          ...
       |
          alt_n subphrase_anno Subphrase prio_n
       |
          prio_n+1
       ;

where the default value of `prio_n+1` is `%prio n+1` and the default
value of `subphrase_anno` is `%short`.

`prio_n+1` and `subphrase_anno` can be defined explicitely as in

       ( alt_1 prio_1 | ... | alt_n prio_n %zero prio_n+1 %tail subphrase_anno )*

### Semantic Actions

------------------------------------------------------------------------

    semantic_action :
       block
    ;

------------------------------------------------------------------------

Semantic actions may be inserted as members of alternatives. They do not
influence the parsing process.

Semantic actions can contain arbitrary *C* code enclosed in curly
braces. This code is executed in a second phase after the parsing
process. The semantic actions of selected alternatives are executed from
left to right in the given order.

Output parameters of preceding symbols may be accessed in the semantic
action. Input parameters of following symbols must be defined.

Parameters are accessed by specifying their names. The name of the
output parameters of the left hand side must be preceded by a
dereferencing operator ('`*`').

In the generated program the curly braces enclosing the action do not
appear in the generated program (hence a semantic action at the
beginning of an alternative may contain declarations of variables that
local to the alternative).
