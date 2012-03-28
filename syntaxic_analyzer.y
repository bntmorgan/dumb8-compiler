%{
#include <stdlib.h>
#include <stdio.h>

void yyerror(char *s);

%}

%token tPRINTF tINT tCONST tMAIN tINTEGER tWORD tADD tSUB tDIV tSTAR tEQ tPARO tPARC tSEMICOLON tDOT tCOMMA tERROR

%start instructions
%%

instructions : instruction tSEMICOLON instructions {}
	     | tSEMICOLON instructions {}
	     | {}
	     ;

instruction   : tINT declarations {printf ("declaration \n");}
	      | tWORD affectations {printf ("affectation \n");};
	      ;

affectations : tEQ tWORD affectations
	     | tEQ tWORD
	     | tEQ tINTEGER
	     ;

declarations : declaration tCOMMA declarations {}
	     | declaration {}
	     ; 

declaration : tWORD {}
	    | tWORD tEQ tINTEGER {}
	    ;


%%

void yyerror(char *s){
     fprintf(stderr, "Vous ne maîtrisez pas les concepts : %s\n", s);
}

int main(int argc, char **argv) {
    yyparse();
    return 0;  
}
