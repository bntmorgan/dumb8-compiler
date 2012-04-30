%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "options.h"
#include "sym.h"
  
void yyerror(char *s);

// Table des symboles
struct t_sym sym;

%}

// Declaration des types utilisés
%union {
  int entier;
  char *chaine;
};

// Definition des types des tokens
%token <entier> tINTEGER
%token <chaine> tWORD

%token tINT tCONST tPRINTF tIF tELSE tWHILE tRETURN tSUP tINF tADD tSUB tDIV tSTAR tEQ tEQEQ tEXCL tPARO tPARC tACCO tACCC tSEMICOLON tDOT tCOMMA tERROR

%type <entier> expr parameters_decl parameters_call terme
%type <chaine> f_declaration

// Définition des associativités par ordre croissant de priorité
%right tEQ
%left tADD tSUB 
%left tSTAR tDIV
%nonassoc	tEQEQ  tINF tSUP
%right tELSE

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
		| tWORD affectations tSEMICOLON {
			printf ("affectation de variable\n");
			// Recherche du symbole associe au nom de variable dans la table des symboles
			//TODO Gerer un flux d'erreur si le symbole n'est pas dans la table
			struct element *elmt = find_sym(&sym, $1);
			compile(&sym, "POP eax\n");
			compile(&sym, "COP [ebp]-%d eax\n", elmt->address);
			// Le symbole est desormais initialise
			elmt->initialized = 1;

		}
		| f_declaration tSEMICOLON {printf("declaration de fonction\n");}
		| f_call tSEMICOLON {printf("appel de fonction\n");}
		| f_definition tSEMICOLON {printf("definition de fonction\n");}
		| printf tSEMICOLON {printf("affichage d'une variable\n");}
		| if {/* /!\ les if et les while sont des instructions qui ne finissent pas necessairement par un semicolon*/printf("if\n");}
		| while {printf("while\n");}
		;

affectations	: tEQ tWORD affectations {
			struct element *elmt = find_sym(&sym, $2);
			// Dans tous les cas, la derniere valeur de eax est la valeur d'affectation de la variable
			// Evite un pop de la valeur et un push de cette meme valeur
			compile(&sym, "COP [ebp]-%d eax\n", elmt->address);
			// Le symbole est desormais initialise
			elmt->initialized = 1;
		}
		| tEQ expr {
			// La valeur de l'expression a ete pushee lors de l'evaluation de expr
		}
		;

declarations : declaration tCOMMA declarations {}
	     | declaration {}
	     ; 

declaration : tWORD affectations {
                    // Ajout du symbole dans la table des symboles
                    struct element *elmt = add_sym(&sym, $1);
		    // On donne l'adresse à la variable locale
		    elmt->address = sym.local_address;
		    // Incrementation des adresses locales
		    sym.local_address++;
		    // On décale esp de 4 octets allocation de la variable
		    compile(&sym, "AFC eax #1\n");
		    compile(&sym, "SOU esp esp eax\n");
		    // Initialication de la variable
				compile(&sym, "POP eax\n");
				compile(&sym, "COP [ebp]-%d eax\n", elmt->address);
            } 
		| tWORD {
   	            // Ajout du symbole dans la table des symboles
                    struct element *elt = add_sym(&sym, $1);
		    // On donne l'adresse à la variable locale
		    elt->address = sym.local_address;
    		    // Incrementation des adresses locales
		    sym.local_address++;
		    // On décale esp de 4 octets allocation de la variable
		    compile(&sym, "AFC eax #1\n");
		    compile(&sym, "SOU esp esp eax\n");

	  }
	  ;

expr	: terme {}
	| expr {} tADD expr {
		// Pop ds ebx pour stocker l'expression de gauche (donc premiere sur la pile)
		compile(&sym, "POP ebx\n");
		// Pop ds eax pour stocker l'expression de droite
		compile(&sym, "POP eax\n");
		//Addition des deux registes et stock du resultat dans eax
		compile(&sym, "ADD eax eax ebx\n");
		compile(&sym, "PSH eax\n");
	} 
	| expr {} tSUB expr {
		compile(&sym, "POP ebx\n");
		compile(&sym, "POP eax\n");
		compile(&sym, "SOU eax eax ebx\n");
		compile(&sym, "PSH eax\n");	
	} 
	| expr {} tDIV expr {
		compile(&sym, "POP ebx\n");
		compile(&sym, "POP eax\n");
		compile(&sym, "DIV eax eax ebx\n");
		compile(&sym, "PSH eax\n");
	} 
	| expr {} tSTAR expr {
		compile(&sym, "POP ebx\n");
		compile(&sym, "POP eax\n");
		compile(&sym, "MUL eax eax ebx\n");
		compile(&sym, "PSH eax\n");
	} 
	| expr tEQEQ expr {
		compile(&sym, "POP ebx\n");
		compile(&sym, "POP eax\n");
		compile(&sym, "EQU eax eax ebx\n");
		compile(&sym, "PSH eax\n");
	}
	| expr tSUP expr {
		compile(&sym, "POP ebx\n");
		compile(&sym, "POP eax\n");
		compile(&sym, "SUP eax eax ebx\n");
		compile(&sym, "PSH eax\n");
	}
  | expr tINF expr {
		compile(&sym, "POP ebx\n");
		compile(&sym, "POP eax\n");
		compile(&sym, "INF eax eax ebx\n");
		compile(&sym, "PSH eax\n");
	}
	;

terme : tPARO expr tPARC {}
	| tINTEGER {
		compile(&sym, "AFC eax #%d\n",$1);
		compile(&sym, "PSH eax\n");
	}
	| tWORD {
		int adr = get_address(&sym, $1); 
		compile(&sym, "COP eax [ebp]-%d\n", adr);
		compile(&sym, "PSH eax\n");
	}
	;

f_declaration	: tINT tWORD tPARO parameters_decl tPARC {
			// Le type courant est T_INT par defaut
			// Changement du type courant de l'element a ajouter a la table
			change_current_type(&sym, T_FUN);
			struct element *element = add_sym(&sym, $2);
			element->nb_parameters = $4;
			// La fonction n'est ici pas encore initialisee
			element->initialized = 0;
			// Remise à T_INT du type courant
			change_current_type(&sym, T_INT);
			// La valeur retour est le nom de la fonction
			$$ = $2;
		}
		| tINT tWORD tPARO tPARC {
			// Changement du type courant de l'element a ajouter a la table
			change_current_type(&sym, T_FUN);
			struct element *element = add_sym(&sym, $2);
			element->nb_parameters = 0;
			// La fonction n'est ici pas encore initialisee
			element->initialized = 0;
			// Remise à T_INT du type courant
			change_current_type(&sym, T_INT);
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
		struct element * element = find_sym(&sym, $1);
		if (element != NULL) {
		        printf("Function %s -> %d\n", $1, element->nb_parameters);
			// Verification de l'initialisation de la fonction
			if (element->initialized == 0) {
			   	printf("Function %s is not initialized.\n", $1);			     
			// Verification du nombre d'argument
			} else if ((element->nb_parameters) > $3) {
				printf("Too many arguments in function : %s\n", $1);
			} else if ((element->nb_parameters) < $3) {
				printf("Too few arguments in function : %s\n", $1);
			} else {
				printf("Function call ok -> %s has %d parameters\n", $1, element->nb_parameters);
				// Appel de la fonction
				int adr = get_address(&sym, $1);
				// On teste si la fonction est bien initialisée
				if (adr == -1) {
				   	fprintf(stderr, "Error : uninitialized fonction\n");
				} else {
				     	compile(&sym, "CAL %d\n", adr);
				}
			}
		}
		else {
			printf("Function %s is not defined\n", $1);
		}
	}
	| tWORD tPARO tPARC {
		struct element *element = find_sym(&sym, $1);
		if (element != NULL) {
			// Verification de l'initialisation de la fonction
			if (element->initialized == 0)
				printf("Function %s is not initialized.\n", $1);

			// Verification du nombre d'argument
			if (element->nb_parameters > 0)
				printf("Too many arguments in function : %s\n", $1);
			else 
				printf("Function call ok -> %s has %d parameters\n", $1, 0);
		}
		else {
			printf("Function %s is not define\n", $1);
		}
	}	
	;

f_definition	: f_declaration 
		{
			// On stocke le contexte de symbole courant
		  	sym_push(&sym);
		  	// On doit redémarrer les adresses locales a 1
		  	sym.local_address = 1;
		  	// TODO adresse de la fonction
		  	struct element * element = find_sym(&sym, $1);
		  	// La fonction est desormais initialisee
		 	element->initialized = 1;
			// On donne l'addresse de la fonction
			element->address = sym.program_counter + 1;
                }
		f_body {
		        sym_pop(&sym);
		}
		;
		
f_body	: tACCO instructions tACCC {
		compile(&sym, "PSH ebp\n");
		compile(&sym, "COP ebp esp\n");
	}
	;

	/*return	: tRETURN expr {$$ = $2;}
	;*/

if	: tIF tPARO expr tPARC bloc_instructions {}
	| tIF tPARO expr tPARC instruction {/* Il faut au moins une instruction apres un if */}
	| tIF tPARO expr tPARC bloc_instructions else {/* Cas d'un if-else */}
	| tIF tPARO expr tPARC instruction else {}
	;

else	: tELSE bloc_instructions {}
	| tELSE instruction {
		/* Il faut au moins une instruction apres un else */
	}
	;

while	: tWHILE tPARO expr tPARC bloc_instructions {}
	| tWHILE tPARO expr tPARC instruction {}
	;
		
printf	: tPRINTF tPARO tWORD tPARC {
		compile(&sym, "PRI [ebp]-%d\n", get_address(&sym, $3));
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
  printf("Dernière addresse du programme : %d\n", sym.program_counter);
  free_sym(&sym);
  close_files();
  return 0;  
}
