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

%type <entier> expr terme condition parameters_decl parameters_call
%type <chaine> f_declaration

%left tADD tSUB
%left tSTAR tDIV

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
	;

f_declaration	: tINT tWORD tPARO parameters_decl tPARC {
			// Le type courant est T_INT par defaut
			// Changement du type courant de l'element a ajouter a la table
			change_current_type(&sym,T_FUN);
			struct element * element = add_sym(&sym, $2);
			element->nb_parameters = $4;
			// La fonction n'est ici pas encore initialisee
			element->initialized = 0;
			// Remise à T_INT du type courant
			change_current_type(&sym,T_INT);
			// La valeur retour est le nom de la fonction
			$$ = $2;
		}
		| tINT tWORD tPARO tPARC {
			// Changement du type courant de l'element a ajouter a la table
			change_current_type(&sym,T_FUN);
			struct element *element = add_sym(&sym, $2);
			element->nb_parameters = 0;
			// La fonction n'est ici pas encore initialisee
			element->initialized = 0;
			// Remise à T_INT du type courant
			change_current_type(&sym,T_INT);
			// La valeur retour est le nom de la fonction
			$$ = $2;
		}
		;

parameters_decl	: tINT tWORD tCOMMA parameters_decl {
			// Incrementation du compteur du nombre de parametres
			$$ = $4 +1;
		}
		| tINT tWORD {
			$$ = 1;
		}
		;

parameters_call	: tWORD tCOMMA parameters_call {
			// Incrementation du compteur du nombre de parametres
			$$ = $3 +1;
		}
		| tINTEGER tCOMMA parameters_call {
			// Incrementation du compteur du nombre de parametres
			$$ = $3 +1;
		}
		| tWORD { $$ = 1; }
		| tINTEGER {$$ = 1; }
		;

f_call	: tWORD tPARO parameters_call tPARC {
		struct element * element = find_sym(&sym,$1);
		if (element != NULL) {
				printf("Function %s -> %d\n",$1,element->nb_parameters);
			// Verification de l'initialisation de la fonction
			if (element->initialized == 0)
				printf("Function %s is not initialized.\n",$1);
				 
			// Verification du nombre d'argument
			if ((element->nb_parameters) > $3)
				printf("Too many arguments in function : %s\n",$1);
			else if ((element->nb_parameters) < $3)
				printf("Too few arguments in function : %s\n",$1);
			else 
				printf("Function call ok -> %s has %d parameters\n",$1,element->nb_parameters);
		}
		else {
			printf("Function %s is not define\n", $1);
		}
	}
	| tWORD tPARO tPARC {
		struct element * element = find_sym(&sym,$1);
		if (element != NULL) {
			// Verification de l'initialisation de la fonction
			if (element->initialized == 0)
				printf("Function %s is not initialized.\n",$1);

			// Verification du nombre d'argument
			if (element->nb_parameters > 0)
				printf("Too many arguments in function : %s\n",$1);
			else 
				printf("Function call ok -> %s has %d parameters\n",$1,0);
		}
		else {
			printf("Function %s is not define\n", $1);
		}
	}	
	;

f_definition	: f_declaration f_body {
			struct element * element = find_sym(&sym,$1);
			// La fonction est desormais initialisee
			element->initialized = 1;
		}
		;
		
f_body	: tACCO instructions tACCC {
		fprintf(file_out,"PUSH ebp");
		fprintf(file_out,"AFC ebp esp");

	}
	;

	/*return	: tRETURN expr {$$ = $2;}
	;*/

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
	;

condition	: expr {fprintf(file_out,"%s %d %d\n","EQ",$1,0);}
		| expr tEQ tEQ expr {fprintf(file_out,"%s %d %d\n","EQ",$1,$4);}
		| expr tSUP expr {fprintf(file_out,"%s %d %d\n", "SUP",$1,$3);}
		| expr tINF expr {fprintf(file_out,"%s %d %d\n", "INF",$1,$3);}
		;

printf	: tPRINTF tPARO tWORD tPARC {
		fprintf(file_out,"PRI %d\n", get_address(&sym,$3));
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
