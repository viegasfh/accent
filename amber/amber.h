/* amber.c */
#ifndef _AMBER_H
#define _AMBER_H
extern int yydirset();

void yymallocerror(void);
int disfilter(int n1, int n2, int p1, int p2);
int confilter(int n, int p1, int p2);
int yyselect(void);
void progress_report(int n);
void print_sourcetext(int n);
void run(void);
void check_all_nonterms(void);
void check_nonterm(char *name);
void process_argv(int argc, char **argv);
int get_number(int i, int argc, char *str);
void fill_group(int lwb, int upb, int select_all, int perc, int max);
void argerr(int n, char *arg, char *msg);
void err(char *msg);
#endif
