all : compiler

test_aux : compiler test_aux.c
	./compiler -o test_aux.s test_aux.c
	cp test_aux.s ../asm_interpreter

test_grammar : compiler test_grammar.c
	./compiler -o test_grammar.s test_grammar.c
	cp test_grammar.s ../asm_interpreter

test_const : compiler test_const.c
	./compiler -o test_const.s test_const.c
	cp test_const.s ../asm_interpreter

test_expr : compiler test_grammar.c
	./compiler -o test_expr.s test_expr.c
	cp test_expr.s ../asm_interpreter

test_function : compiler test_function.c
	./compiler -o test_function.s test_function.c
	cp test_function.s ../asm_interpreter

test_main : compiler test_main.c
	./compiler -o test_main.s test_main.c
	cp test_main.s ../asm_interpreter

fibo : compiler fibo.c
	./compiler -o fibo.s fibo.c
	cp fibo.s ../asm_interpreter

test_if : compiler test_if.c
	./compiler -o test_if.s test_if.c
	cp test_if.s ../asm_interpreter

test_while : compiler test_while.c
	./compiler -o test_while.s test_while.c
	cp test_while.s ../asm_interpreter

test_recursive : compiler test_recursive.c
	./compiler -o test_recursive.s test_recursive.c
	cp test_recursive.s ../asm_interpreter

yacc : syntaxic_analyzer.y
	yacc -d -o syntaxic_analyzer.c syntaxic_analyzer.y -v

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
