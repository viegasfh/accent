#include "yygrammar.h"

YYSTART ()
{
   switch(yyselect()) {
   case 14: {
      root();
      get_lexval();
      } break;
   }
}

root ()
{
   switch(yyselect()) {
   case 1: {
      expression();
      } break;
   case 2: {
      null();
      } break;
   }
}

null ()
{
   switch(yyselect()) {
   case 3: {
      } break;
   }
}

expression ()
{
   YYSTYPE n;
   switch(yyselect()) {
   case 4: {
      term(&n);
#line 11 "spec.acc"
 printf("%d\n", n); 
# line 42 "yygrammar.c"
      } break;
   }
}

term (n)
   YYSTYPE *n;
{
   YYSTYPE x;
   YYSTYPE y;
   switch(yyselect()) {
   case 5: {
      term(&x);
      get_lexval();
      factor(&y);
#line 15 "spec.acc"
 *n = x+y; 
# line 59 "yygrammar.c"
      } break;
   case 6: {
      term(&x);
      get_lexval();
      factor(&y);
#line 16 "spec.acc"
 *n = x-y; 
# line 67 "yygrammar.c"
      } break;
   case 7: {
      factor(n);
      } break;
   }
}

factor (n)
   YYSTYPE *n;
{
   YYSTYPE x;
   YYSTYPE y;
   switch(yyselect()) {
   case 8: {
      factor(&x);
      get_lexval();
      primary(&y);
#line 21 "spec.acc"
 *n = x*y; 
# line 87 "yygrammar.c"
      } break;
   case 9: {
      factor(&x);
      get_lexval();
      primary(&y);
#line 22 "spec.acc"
 *n = x/y; 
# line 95 "yygrammar.c"
      } break;
   case 10: {
      primary(n);
      } break;
   }
}

primary (n)
   YYSTYPE *n;
{
   YYSTYPE x;
   switch(yyselect()) {
   case 11: {
      get_lexval();
      *n = yylval;
      } break;
   case 12: {
      get_lexval();
      term(n);
      get_lexval();
      } break;
   case 13: {
      get_lexval();
      primary(&x);
#line 29 "spec.acc"
 *n = -x;
# line 122 "yygrammar.c"
      } break;
   }
}

extern YYSTYPE yylval;
YYSTYPE yylval;
extern long yypos;
long yypos = 1;
/* GentleFlag = no */

typedef struct LEXELEMSTRUCT {
   YYSTYPE val;
   long pos;
   long sym;
   char * text;
   struct LEXELEMSTRUCT *next;
} LEXELEM;
   
LEXELEM *first_lexelem, *cur_lexelem;

init_lexelem()
{
   cur_lexelem = first_lexelem;
}

first_lexval () {
   LEXELEM *p;
   p = (LEXELEM *)malloc(sizeof(LEXELEM));
   if (! p) yymallocerror();
   p->val = yylval;
   p->pos = yypos;
   p->next = 0;
   cur_lexelem = p;
   first_lexelem = p;
}

next_lexval() {
   LEXELEM *p;
   p = (LEXELEM *)malloc(sizeof(LEXELEM));
   if (! p) yymallocerror();
   cur_lexelem-> next = p;
   p->val = yylval;
   p->pos = yypos;
   p->next = 0;
   cur_lexelem = p;
}

get_lexval() {
   extern int FREE_LEXELEMS;
   LEXELEM *p;
   yylval = cur_lexelem->val;
   yypos = cur_lexelem->pos;
   p = cur_lexelem;
   cur_lexelem = cur_lexelem->next;
   free(p);
}

extern int c_length;
int c_length = 67;
extern int yygrammar[];
int yygrammar[] = {
0,
/* 1 */ 0,
/* 2 */ 6,
/* 3 */ 50000,
/* 4 */ -1,
/* 5 */ 14,
/* 6 */ 10,
/* 7 */ 17,
/* 8 */ -6,
/* 9 */ 1,
/* 10 */ 0,
/* 11 */ 14,
/* 12 */ -6,
/* 13 */ 2,
/* 14 */ 0,
/* 15 */ -14,
/* 16 */ 3,
/* 17 */ 0,
/* 18 */ 21,
/* 19 */ -17,
/* 20 */ 4,
/* 21 */ 27,
/* 22 */ 21,
/* 23 */ 50043,
/* 24 */ 37,
/* 25 */ -21,
/* 26 */ 5,
/* 27 */ 33,
/* 28 */ 21,
/* 29 */ 50045,
/* 30 */ 37,
/* 31 */ -21,
/* 32 */ 6,
/* 33 */ 0,
/* 34 */ 37,
/* 35 */ -21,
/* 36 */ 7,
/* 37 */ 43,
/* 38 */ 37,
/* 39 */ 50042,
/* 40 */ 53,
/* 41 */ -37,
/* 42 */ 8,
/* 43 */ 49,
/* 44 */ 37,
/* 45 */ 50047,
/* 46 */ 53,
/* 47 */ -37,
/* 48 */ 9,
/* 49 */ 0,
/* 50 */ 53,
/* 51 */ -37,
/* 52 */ 10,
/* 53 */ 57,
/* 54 */ 50256,
/* 55 */ -53,
/* 56 */ 11,
/* 57 */ 63,
/* 58 */ 50040,
/* 59 */ 21,
/* 60 */ 50041,
/* 61 */ -53,
/* 62 */ 12,
/* 63 */ 0,
/* 64 */ 50045,
/* 65 */ 53,
/* 66 */ -53,
/* 67 */ 13,
0
};
extern int yyannotation[];
int yyannotation[] = {
0,
/* 1 */ 0,
/* 2 */ 0,
/* 3 */ 50000,
/* 4 */ -1,
/* 5 */ 0,
/* 6 */ 10,
/* 7 */ 1,
/* 8 */ -6,
/* 9 */ 1,
/* 10 */ 0,
/* 11 */ 1,
/* 12 */ -6,
/* 13 */ 2,
/* 14 */ 0,
/* 15 */ -14,
/* 16 */ 1,
/* 17 */ 0,
/* 18 */ 1,
/* 19 */ -17,
/* 20 */ 1,
/* 21 */ 27,
/* 22 */ 1,
/* 23 */ 50043,
/* 24 */ 1,
/* 25 */ -21,
/* 26 */ 1,
/* 27 */ 33,
/* 28 */ 1,
/* 29 */ 50045,
/* 30 */ 1,
/* 31 */ -21,
/* 32 */ 2,
/* 33 */ 0,
/* 34 */ 1,
/* 35 */ -21,
/* 36 */ 3,
/* 37 */ 43,
/* 38 */ 1,
/* 39 */ 50042,
/* 40 */ 1,
/* 41 */ -37,
/* 42 */ 1,
/* 43 */ 49,
/* 44 */ 1,
/* 45 */ 50047,
/* 46 */ 1,
/* 47 */ -37,
/* 48 */ 2,
/* 49 */ 0,
/* 50 */ 1,
/* 51 */ -37,
/* 52 */ 3,
/* 53 */ 57,
/* 54 */ 50256,
/* 55 */ -53,
/* 56 */ 1,
/* 57 */ 63,
/* 58 */ 50040,
/* 59 */ 1,
/* 60 */ 50041,
/* 61 */ -53,
/* 62 */ 2,
/* 63 */ 0,
/* 64 */ 50045,
/* 65 */ 1,
/* 66 */ -53,
/* 67 */ 3,
0
};
extern int yycoordinate[];
int yycoordinate[] = {
0,
/* 1 */ 9999,
/* 2 */ 2006,
/* 3 */ 9999,
/* 4 */ 9999,
/* 5 */ 2006,
/* 6 */ 9999,
/* 7 */ 3004,
/* 8 */ 9999,
/* 9 */ 3013,
/* 10 */ 9999,
/* 11 */ 4004,
/* 12 */ 9999,
/* 13 */ 4007,
/* 14 */ 9999,
/* 15 */ 9999,
/* 16 */ 8001,
/* 17 */ 9999,
/* 18 */ 11003,
/* 19 */ 9999,
/* 20 */ 11006,
/* 21 */ 9999,
/* 22 */ 15003,
/* 23 */ 9999,
/* 24 */ 15015,
/* 25 */ 9999,
/* 26 */ 15006,
/* 27 */ 9999,
/* 28 */ 16003,
/* 29 */ 9999,
/* 30 */ 16015,
/* 31 */ 9999,
/* 32 */ 16006,
/* 33 */ 9999,
/* 34 */ 17003,
/* 35 */ 9999,
/* 36 */ 17008,
/* 37 */ 9999,
/* 38 */ 21003,
/* 39 */ 9999,
/* 40 */ 21017,
/* 41 */ 9999,
/* 42 */ 21008,
/* 43 */ 9999,
/* 44 */ 22003,
/* 45 */ 9999,
/* 46 */ 22017,
/* 47 */ 9999,
/* 48 */ 22008,
/* 49 */ 9999,
/* 50 */ 23003,
/* 51 */ 9999,
/* 52 */ 23009,
/* 53 */ 9999,
/* 54 */ 9999,
/* 55 */ 9999,
/* 56 */ 27008,
/* 57 */ 9999,
/* 58 */ 9999,
/* 59 */ 28007,
/* 60 */ 9999,
/* 61 */ 9999,
/* 62 */ 28003,
/* 63 */ 9999,
/* 64 */ 9999,
/* 65 */ 29007,
/* 66 */ 9999,
/* 67 */ 29003,
0
};
/* only for BIGHASH (see art.c)
extern int DHITS[];
int DHITS[69];
*/
int TABLE[15][256];
init_dirsets() {
TABLE[14][0] = 1;
TABLE[14][256] = 1;
TABLE[14][40] = 1;
TABLE[14][45] = 1;
TABLE[1][45] = 1;
TABLE[1][40] = 1;
TABLE[1][256] = 1;
TABLE[2][0] = 1;
TABLE[3][0] = 1;
TABLE[4][256] = 1;
TABLE[4][40] = 1;
TABLE[4][45] = 1;
TABLE[5][256] = 1;
TABLE[5][40] = 1;
TABLE[5][45] = 1;
TABLE[6][256] = 1;
TABLE[6][40] = 1;
TABLE[6][45] = 1;
TABLE[7][45] = 1;
TABLE[7][40] = 1;
TABLE[7][256] = 1;
TABLE[8][45] = 1;
TABLE[8][40] = 1;
TABLE[8][256] = 1;
TABLE[9][45] = 1;
TABLE[9][40] = 1;
TABLE[9][256] = 1;
TABLE[10][256] = 1;
TABLE[10][40] = 1;
TABLE[10][45] = 1;
TABLE[11][256] = 1;
TABLE[12][40] = 1;
TABLE[13][45] = 1;
}

extern int yydirset();
int yydirset(i,j)
   int i,j;
{
   return TABLE[i][j];
}
int yytransparent(n)
   int n;
{
   switch(n) {
      case 1: return 1; break;
      case 6: return 1; break;
      case 14: return 1; break;
      case 17: return 0; break;
      case 21: return 0; break;
      case 37: return 0; break;
      case 53: return 0; break;
   }
}
char * yyprintname(n)
   int n;
{
   if (n <= 50000)
      switch(n) {
         case 1: return "YYSTART"; break;
         case 6: return "root"; break;
         case 14: return "null"; break;
         case 17: return "expression"; break;
         case 21: return "term"; break;
         case 37: return "factor"; break;
         case 53: return "primary"; break;
   }
   else 
      switch(n-50000) {
         case 256: return "NUMBER"; break;
      }
   return "special_character";
}
