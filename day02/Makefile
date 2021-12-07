# part of the makefile
all:    day02

day02:	day02.l day02.y
	bison -d $@.y
	flex $@.l
	cc -o $@ $@.tab.c lex.yy.c -lfl

clean:
	rm -f day02 lex.yy.c *.tab.* *~
