#include "yygrammar.h"

YYSTART ()
{
   switch(yyselect()) {
   case 10: {
      Root();
      get_lexval();
      } break;
   }
}

Root ()
{
   switch(yyselect()) {
   case 1: {
      Example1();
      } break;
   case 2: {
      Example2();
      } break;
   }
}

Example1 ()
{
   switch(yyselect()) {
   case 3: {
      A();
      } break;
   case 4: {
      B();
      } break;
   }
}

A ()
{
   switch(yyselect()) {
   case 5: {
      get_lexval();
      } break;
   }
}

B ()
{
   switch(yyselect()) {
   case 6: {
      get_lexval();
      } break;
   }
}

Example2 ()
{
   switch(yyselect()) {
   case 7: {
      X();
      X();
      } break;
   }
}

X ()
{
   switch(yyselect()) {
   case 8: {
      get_lexval();
      } break;
   case 9: {
      get_lexval();
      get_lexval();
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
int c_length = 43;
extern int yygrammar[];
int yygrammar[] = {
0,
/* 1 */ 0,
/* 2 */ 6,
/* 3 */ 50000,
/* 4 */ -1,
/* 5 */ 10,
/* 6 */ 10,
/* 7 */ 14,
/* 8 */ -6,
/* 9 */ 1,
/* 10 */ 0,
/* 11 */ 30,
/* 12 */ -6,
/* 13 */ 2,
/* 14 */ 18,
/* 15 */ 22,
/* 16 */ -14,
/* 17 */ 3,
/* 18 */ 0,
/* 19 */ 26,
/* 20 */ -14,
/* 21 */ 4,
/* 22 */ 0,
/* 23 */ 50120,
/* 24 */ -22,
/* 25 */ 5,
/* 26 */ 0,
/* 27 */ 50120,
/* 28 */ -26,
/* 29 */ 6,
/* 30 */ 0,
/* 31 */ 35,
/* 32 */ 35,
/* 33 */ -30,
/* 34 */ 7,
/* 35 */ 39,
/* 36 */ 50120,
/* 37 */ -35,
/* 38 */ 8,
/* 39 */ 0,
/* 40 */ 50120,
/* 41 */ 50120,
/* 42 */ -35,
/* 43 */ 9,
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
/* 7 */ 0,
/* 8 */ -6,
/* 9 */ -1,
/* 10 */ 0,
/* 11 */ 0,
/* 12 */ -6,
/* 13 */ -1,
/* 14 */ 18,
/* 15 */ 0,
/* 16 */ -14,
/* 17 */ -1,
/* 18 */ 0,
/* 19 */ 0,
/* 20 */ -14,
/* 21 */ -1,
/* 22 */ 0,
/* 23 */ 50120,
/* 24 */ -22,
/* 25 */ -1,
/* 26 */ 0,
/* 27 */ 50120,
/* 28 */ -26,
/* 29 */ -1,
/* 30 */ 0,
/* 31 */ 0,
/* 32 */ 0,
/* 33 */ -30,
/* 34 */ -1,
/* 35 */ 39,
/* 36 */ 50120,
/* 37 */ -35,
/* 38 */ -1,
/* 39 */ 0,
/* 40 */ 50120,
/* 41 */ 50120,
/* 42 */ -35,
/* 43 */ -1,
0
};
extern int yycoordinate[];
int yycoordinate[] = {
0,
/* 1 */ 9999,
/* 2 */ 3005,
/* 3 */ 9999,
/* 4 */ 9999,
/* 5 */ 3005,
/* 6 */ 9999,
/* 7 */ 4004,
/* 8 */ 9999,
/* 9 */ 4011,
/* 10 */ 9999,
/* 11 */ 6004,
/* 12 */ 9999,
/* 13 */ 6011,
/* 14 */ 9999,
/* 15 */ 10004,
/* 16 */ 9999,
/* 17 */ 10004,
/* 18 */ 9999,
/* 19 */ 12004,
/* 20 */ 9999,
/* 21 */ 12004,
/* 22 */ 9999,
/* 23 */ 9999,
/* 24 */ 9999,
/* 25 */ 16003,
/* 26 */ 9999,
/* 27 */ 9999,
/* 28 */ 9999,
/* 29 */ 20003,
/* 30 */ 9999,
/* 31 */ 24004,
/* 32 */ 24006,
/* 33 */ 9999,
/* 34 */ 24004,
/* 35 */ 9999,
/* 36 */ 9999,
/* 37 */ 9999,
/* 38 */ 28003,
/* 39 */ 9999,
/* 40 */ 9999,
/* 41 */ 9999,
/* 42 */ 9999,
/* 43 */ 30003,
0
};
/* only for BIGHASH (see art.c)
extern int DHITS[];
int DHITS[45];
*/
int TABLE[11][256];
init_dirsets() {
TABLE[10][120] = 1;
TABLE[1][120] = 1;
TABLE[2][120] = 1;
TABLE[3][120] = 1;
TABLE[4][120] = 1;
TABLE[5][120] = 1;
TABLE[6][120] = 1;
TABLE[7][120] = 1;
TABLE[8][120] = 1;
TABLE[9][120] = 1;
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
      case 1: return 0; break;
      case 6: return 0; break;
      case 14: return 0; break;
      case 22: return 0; break;
      case 26: return 0; break;
      case 30: return 0; break;
      case 35: return 0; break;
   }
}
char * yyprintname(n)
   int n;
{
   if (n <= 50000)
      switch(n) {
         case 1: return "YYSTART"; break;
         case 6: return "Root"; break;
         case 14: return "Example1"; break;
         case 22: return "A"; break;
         case 26: return "B"; break;
         case 30: return "Example2"; break;
         case 35: return "X"; break;
   }
   else 
      switch(n-50000) {
      }
   return "special_character";
}
