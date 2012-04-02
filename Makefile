all : compiler

test : compiler test_grammar.c
	cat test_grammar.c | ./compiler 

yacc : syntaxic_analyzer.y
	yacc -d -o syntaxic_analyzer.c syntaxic_analyzer.y

lex : lexical_analyzer.lex
	lex -o lexical_analyzer.c lexical_analyzer.lex

compiler : yacc lex 
	gcc -g -Wall -o compiler lexical_analyzer.c syntaxic_analyzer.c -ll -ly
