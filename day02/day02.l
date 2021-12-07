/* Advent of Code 2021, day 2, flex file */

%{
# include "day02.tab.h"
%}

%%
"forward" { return FWD; }
"up"      { return UP; }
"down"    { return DOWN; }
[0-9]+	{ yylval = atoi(yytext); return NUMBER; }
%%
