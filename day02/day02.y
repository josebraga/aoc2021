/* Advent of Code 2021, day 2, bison file */

%{
#  include <stdio.h>

  long forward = 0;
  long original_depth = 0;
  long aim = 0;
  long depth = 0;
%}

/* declare tokens */
%token NUMBER
%token FWD UP DOWN

%%

entries: /* nothing */
| entries exp { }
;

exp:
FWD NUMBER    { forward += $2; depth += $2 * aim; }
| UP NUMBER   { original_depth -= $2; aim -= $2; }
| DOWN NUMBER { original_depth += $2; aim += $2; }
 ;

%%
main()
{
  yyparse();
  printf("Part 1:\t%d * %d = %d\n", forward, original_depth, forward * original_depth);
  printf("Part 2:\t%d * %d = %d\n", forward, depth, forward * depth);
}

yyerror(char *s)
{
  fprintf(stderr, "error: %s\n", s);
}
