%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "options.h"
#include "sym.h"
  
void yyerror(char *s);

// Table des symboles
struct t_sym sym;

// Adresse courante du programme
int program_counter = 0;

%}

// Declaration des types utilisés
%union {
  int entier;
  char *chaine;
};

// Definition des types des tokens
%token <entier> tINTEGER
%token <chaine> tWORD

%token tINT tCONST tPRINTF tIF tELSE tWHILE tRETURN tSUP tINF tADD tSUB tDIV tSTAR tEQ tEXCL tPARO tPARC tACCO tACCC tSEMICOLON tDOT tCOMMA tERROR

// Axiome
%start instructions

// Declaration du type des non terminaux qui ne sont pas des entiers
// %type <nom_de_type> non_terminal

%%

instructions 	: instruction instructions {}
	 	| bloc_instructions instructions {}
		| tSEMICOLON instructions {}
		| tSEMICOLON bloc_instructions {}
	     	| {}
	     	;

bloc_instructions	: tACCO {sym_push(&sym);} instructions tACCC {sym_pop(&sym);}
			;

instruction	: tINT declarations tSEMICOLON {printf ("declaration de variable\n");}
		| tWORD affectations tSEMICOLON {printf ("affectation de variable\n");}
		| f_declaration tSEMICOLON {printf("declaration de fonction\n");}
		| f_call tSEMICOLON {printf("appel de fonction\n");}
		| f_definition tSEMICOLON {printf("definition de fonction\n");}
		| printf tSEMICOLON {printf("Affichage d'une variable\n");}
		| if {/* /!\ les if et les while sont des instructions qui ne finissent pas necessairement par un semicolon*/printf("if\n");}
		| while {printf("while\n");}
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
                    // On utilise l'adresse courante tsym_idx dans la table des symboles
                    fprintf(file_out,"COP %d %d\n", get_sym_idx(&sym), $3);
                    add_sym(&sym, $1);
            } 
            | tWORD {
	            add_sym(&sym, $1);
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
	| tWORD {}
	| f_call {/* Verifier la concordance des types */}
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

f_definition	: f_declaration bloc_instructions {}
		;

if	: tIF test bloc_instructions {}
	| tIF test instruction {/* Il faut au moins une instruction apres un if */}
	| tIF test bloc_instructions else {/* Cas d'un if-else */}
	| tIF test instruction else {}
	;

else	: tELSE bloc_instructions {}
	| tELSE instruction {/* Il faut au moins une instruction apres un else */}
	| tELSE if {/* Cas du else if */}
	;

while	: tWHILE test bloc_instructions {}
	| tWHILE test instruction {}
	;

test	: tPARO condition tPARC {}
	| tEXCL tPARO condition tPARC {}
	;

condition	: expr {}
		| expr tEQ tEQ expr {}
		| expr tEXCL tEQ expr {}
		| expr tSUP expr {}
		| expr tINF expr {}
		;

printf	: tPRINTF tPARO tWORD tPARC {
		printf("PRI %d\n", get_address(&sym,$3));
	}
	;
%%

void yyerror(char *s) {
  fprintf(stderr, "Vous ne maîtrisez pas les concepts : %s\n", s);
}

int main(int argc, char **argv) {
  // Initialisation de la table des symboles
  create_sym(&sym);
  do_options(argc, argv);
  yyparse();
  print_sym(&sym);
  free_sym(&sym);
  close_files();
  return 0;  
}
