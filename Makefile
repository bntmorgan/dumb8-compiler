all : compiler

test : compiler test_grammar.c
	./compiler -o test_grammar.s test_grammar.c

yacc : syntaxic_analyzer.y
	yacc -d -o syntaxic_analyzer.c syntaxic_analyzer.y

lex : lexical_analyzer.lex
	lex -o lexical_analyzer.c lexical_analyzer.lex

sym : sym.c
	gcc -c -g -Wall sym.c

options : options.c
	gcc -c -g -Wall options.c

compiler : yacc lex sym options
	gcc -g -Wall -o compiler lexical_analyzer.c syntaxic_analyzer.c sym.o options.o -ll -ly

clean : 
	rm *.o
