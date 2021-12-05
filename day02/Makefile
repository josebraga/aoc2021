# part of the makefile
all:    day2

day2:	day2.l day2.y
	bison -d day2.y
	flex day2.l
	cc -o $@ day2.tab.c lex.yy.c -lfl

clean:
	rm -f day2 lex.yy.c *.tab.* *~
