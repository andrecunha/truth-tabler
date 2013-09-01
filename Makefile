CC=clang

all: lex synt formatters logic_tree colors
	${CC} -g -o tabler lex.yy.o tabler.tab.o logic_tree.o formatters.o colors.o

lex: tabler.l
	flex tabler.l
	${CC} -c lex.yy.c

synt: tabler.y
	bison -d tabler.y
	${CC} -c tabler.tab.c

formatters: formatters.c
	${CC} -c formatters.c

logic_tree: logic_tree.c
	${CC} -c logic_tree.c

colors: colors.c
	${CC} -c colors.c

release: lex synt formatters logic_tree colors
	${CC} -DNDEBUG -o tabler lex.yy.o tabler.tab.o logic_tree.o formatters.o colors.o
