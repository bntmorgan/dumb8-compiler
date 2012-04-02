%{
#include <stdlib.h>
#include <stdio.h>

void yyerror(char *s);

%}

%token tPRINTF tINT tCONST tMAIN tINTEGER tWORD tADD tSUB tDIV tSTAR tEQ tPARO tPARC tACCO tACCC tSEMICOLON tDOT tCOMMA tERROR

%start instructions

%%



instructions 	: instruction tSEMICOLON instructions {}
		| tSEMICOLON instructions {}
	     	| {}
	     	;

instruction	: tINT declarations {printf ("declaration \n");}
		| tWORD affectations {printf ("affectation \n");}
		| f_declaration {printf("declaration de fonction\n");}
		| f_call {printf("appel de fonction\n");}
		;

affectations 	: tEQ tWORD affectations {}
	     	| tEQ tWORD {}
	     	| tEQ tINTEGER {}
		| tEQ expr {printf("expression\n");}
	     	;

declarations : declaration tCOMMA declarations {}
	     | declaration {}
	     ; 

declaration : tWORD {}
	    | tWORD tEQ tINTEGER {}
	    ;

expr	: terme {}
	| tPARO expr tPARC {}
	| expr tADD expr {}
	| expr tSUB expr {}
	| expr tDIV expr {}
	| expr tSTAR expr {}
	;

terme	: tINTEGER {}
	| tWORD {/*Pas encore d'appel de fonction.*/}
	;

f_declaration	: tINT tWORD tPARO parameters_decl tPARC {}
		| tINT tWORD tPARO tPARC {}
		;

parameters_decl	: tINT tWORD tCOMMA parameters_decl {}
		| tINT tWORD {}
		;
parameters_call	: tWORD tCOMMA parameters_call {}
		| tINTEGER tCOMMA parameters_call {}
		| tWORD {}
		| tINTEGER {}
		;

f_call	: tWORD tPARO parameters_call tPARC {}
	| tWORD tPARO tPARC {}
	| 'KFC' tPARO tPARC {printf("tu pues !\n");}
	;

	/*f_definition	: f_declaration tACCO instructions tACCC {printf("declaration de fonction\n");}
		;*/


%%

void yyerror(char *s){
     fprintf(stderr, "Vous ne maîtrisez pas les concepts : %s\n", s);
}

int main(int argc, char **argv) {
    yyparse();
    return 0;  
}
