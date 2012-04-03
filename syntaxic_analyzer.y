%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "sym.h"
  
void yyerror(char *s);
  
%}

//declaration des types utilisés
%union {
  int entier;
  char *chaine;
};

//definition des types des tokens
%token <entier> tINTEGER
%token <chaine> tWORD

%token tPRINTF tINT tCONST tMAIN tADD tSUB tDIV tSTAR tEQ tPARO tPARC tACCO tACCC tSEMICOLON tDOT tCOMMA tERROR

//axiome
%start instructions

//declaration du type des non terminaux qui ne sont pas des entiers
//%type <nom_de_type> non_terminal

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

declaration : tWORD tEQ tINTEGER {
                    //on utilise l'adresse courante tsym_idx dans la table des symboles
                    printf("COP %d %d\n", get_sym_idx(), $3);
                    add_sym($1);
            } 
            | tWORD {
                    add_sym($1);
	    }
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
	;

/*f_definition	: f_declaration tACCO instructions tACCC {printf("declaration de fonction\n");}
		;*/


%%

void yyerror(char *s) {
  fprintf(stderr, "Vous ne maîtrisez pas les concepts : %s\n", s);
}

int main(int argc, char **argv) {
  yyparse();
  print_sym();
  return 0;  
}
