all : compiler

test_grammar : compiler test_grammar.c
	./compiler -o test_grammar.s test_grammar.c
	cp test_grammar.s ../asm_interpreter

test_expr : compiler test_grammar.c
	./compiler -o test_expr.s test_expr.c
	cp test_expr.s ../asm_interpreter

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
