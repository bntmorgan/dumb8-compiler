%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "options.h"
#include "sym.h"
#define NB_MAX_PARAM 20

extern int line;
  
void yyerror(char *s);

// Table des symboles
struct t_sym sym;
/* Liste des arguments d'une fonction et son index
 * Les variables étant toutes des int, la liste ne contient que des noms de variables
*/
char * param_list[NB_MAX_PARAM];
int param_index = 0;

%}

%error-verbose

// Declaration des types utilisés
%union {
  int entier;
  char *chaine;
};

// Definition des types des tokens
%token <entier> tINTEGER
%token <chaine> tWORD

%token tINT tCONST tPRINTF tIF tELSE tWHILE tRETURN tSUP tINF tADD tSUB tDIV tSTAR tEQ tEQEQ tEXCL tPARO tPARC tACCO tACCC tSEMICOLON tDOT tCOMMA tERROR

%type <entier> expr param_proto param_call terme
%type <chaine> f_declaration f_prototype declaration declarations

// Définition des associativités par ordre croissant de priorité
%right tEQ
%left tADD tSUB 
%left tSTAR tDIV
%nonassoc tEQEQ tINF tSUP

%nonassoc LOWER_THAN_ELSE
%nonassoc tELSE

// Axiome
%start instructions_top

%%

instructions_top : instruction instructions_top {}
                 | bloc_instructions instructions_top {}
		 | f_definition instructions_top {}
                 | f_declaration tSEMICOLON instructions_top {}
                 | instruction {}
                 | bloc_instructions {}
		 | f_definition {}
                 | f_declaration tSEMICOLON {}
                 ;

instructions 	: instruction instructions {}
	 	| bloc_instructions instructions {}
		| instruction {}
	 	| bloc_instructions {}
	     	;

bloc_instructions	: tACCO {sym_push(&sym);} instructions tACCC {sym_pop(&sym);}
			| tACCO tACCC
                        ;

instruction	: tINT declarations tSEMICOLON {
	    		printf ("declaration de variable\n");
		}
                | tCONST tINT declarations tSEMICOLON {
	    		printf ("declaration d'une constante\n");
			// Le nom de la variable déclarée est renvoyée par le non-terminal 'declarations'
                        struct element *elmt = find_sym(&sym, $3);
                        if (elmt == NULL) {
				//Cas impossible mais on ne sait jamais...
				fprintf(stderr, "Error : variable undeclared.\n");
                        } else {
                                elmt->constant = 1;
                        }       
		}
		| tWORD affectations tSEMICOLON {
			printf ("affectation de variable\n");
			// Recherche du symbole associe au nom de variable dans la table des symboles
			struct element *elmt = find_sym(&sym, $1);
			if (elmt == NULL) {
				fprintf(stderr, "Error : '%s' undeclared (first use in this function).\n", $1);
			} else if (elmt->constant == 1) {
				// Affectée ou pas, une constante ne peut être modifiée
                                fprintf(stderr, "Error : assignment of read-only variable ‘%s'.\n", $1);
				// Si la variable est une constante on ne l'affecte pas avec la valeur de eax
				// TODO : choix -> break ou pas ?
				compile(&sym, "POP eax\n");
                        }
			else {
				compile(&sym, "POP eax\n");
				compile(&sym, "COP [ebp]-%d eax\n", elmt->address);
				// Le symbole est desormais initialise
				elmt->initialized = 1;
			}
		}
		| f_call tSEMICOLON {
			printf("appel de fonction\n");
		}
		| printf tSEMICOLON {
			printf("affichage d'une variable\n");
		}
                | if {
			printf("if\n");
		} 
		| while {
			printf("while\n");
		}
                | tSEMICOLON
		;

affectations	: tEQ tWORD affectations {
			struct element *elmt = find_sym(&sym, $2);
			if (elmt == NULL) {
				fprintf(stderr, "Error : '%s' undeclared (first use in this function).\n", $2);
			}
			else {
				// Dans tous les cas, la derniere valeur de eax est la valeur d'affectation de la variable
				// Evite un pop de la valeur et un push de cette meme valeur
				compile(&sym, "COP [ebp]-%d eax\n", elmt->address);
				// Le symbole est desormais initialise
				elmt->initialized = 1;
			}
		}
		| tEQ expr {
			// La valeur de l'expression a ete pushee dans eax lors de l'evaluation de expr
		}
		;

declarations : declaration tCOMMA declarations {}
	     | declaration {}
	     ; 

declaration : tWORD affectations {
		struct element *elmt = find_sym(&sym, $1);
		// Si l'élément n'est pas déjà dans la table des symboles
		if (elmt == NULL) { 
	    	    // Ajout du symbole dans la table des symboles
                    elmt = add_sym(&sym, $1, T_INT);
		    // On donne l'adresse à la variable locale
		    elmt->address = sym.local_address;
		    elmt->initialized = 1;
		    // Incrementation des adresses locales
		    sym.local_address++;
		    // On récupère la valeur de la variable déclarée
		    compile(&sym, "POP eax\n");
		    // On décale esp de 4 octets allocation de la variable
		    compile(&sym, "AFC ebx #1\n");
		    compile(&sym, "SOU esp esp ebx\n");
		    // Initialication de la variable
		    compile(&sym, "COP [ebp]-%d eax\n", elmt->address);
		}
		else {
		    //TODO note: previous definition of ‘%s’ was here
		    fprintf(stderr, "Error : redefinition of '%s'\n", $1);
		}
		//Une déclaration renvoie le nom de la variable déclarée
		$$ = $1;
            } 
	    | tWORD {
		// Si l'élément n'est pas déjà dans la table des symboles
                struct element *elmt = find_sym(&sym, $1);
		if (elmt == NULL) { 
   	            // Ajout du symbole dans la table des symboles
                    elmt = add_sym(&sym, $1, T_INT);
		    // On donne l'adresse à la variable locale
		    elmt->address = sym.local_address;
    		    // Incrementation des adresses locales
		    sym.local_address++;
		    // On décale esp de 4 octets allocation de la variable
		    compile(&sym, "AFC ebx #1\n");
		    compile(&sym, "SOU esp esp ebx\n");
		}
		else {
		    //TODO note: previous definition of ‘%s’ was here
		    fprintf(stderr, "Error : redefinition of '%s'\n", $1);
	  	}
		$$ = $1;
	    }
	    ;

expr	: terme {}
	| expr tADD expr {
		// Pop ds ebx pour stocker l'expression de gauche (donc premiere sur la pile)
		compile(&sym, "POP ebx\n");
		// Pop ds eax pour stocker l'expression de droite
		compile(&sym, "POP eax\n");
		//Addition des deux registes et stock du resultat dans eax
		compile(&sym, "ADD eax eax ebx\n");
		compile(&sym, "PSH eax\n");
	} 
	| expr tSUB expr {
		compile(&sym, "POP ebx\n");
		compile(&sym, "POP eax\n");
		compile(&sym, "SOU eax eax ebx\n");
		compile(&sym, "PSH eax\n");	
	} 
	| expr tDIV expr {
		compile(&sym, "POP ebx\n");
		compile(&sym, "POP eax\n");
		compile(&sym, "DIV eax eax ebx\n");
		compile(&sym, "PSH eax\n");
	} 
	| expr tSTAR expr {
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
		struct element *elmt = find_sym(&sym, $1);
		if (elmt != NULL) { 
		    if (elmt->initialized != 0) {
		        int adr = get_address(&sym, $1); 
		        compile(&sym, "COP eax [ebp]-%d\n", adr);
		        compile(&sym, "PSH eax\n");
				} else {
						fprintf(stderr, "Error : uninitialized symbol '%s'\n", $1);
				}
		} else {
		    fprintf(stderr, "Error : '%s' undeclared (first use in this function).\n", $1);
		}
	}
	;

param_proto	: tINT tWORD tCOMMA param_proto {
			// Incrementation du compteur du nombre de parametres
			$$ = $4 + 1;
			// Ajout du paramètre dans la liste stockant temporairement les paramètres
			param_list[param_index] = $2;
			param_index++;
		}
		| tINT tWORD {
			$$ = 1;
			param_list[param_index] = $2;
			param_index++;
		}
		;

param_call	: terme tCOMMA param_call {
			// Incrementation du compteur du nombre de parametres
			$$ = $3 + 1;
		}
		| terme {$$ = 1;}
		;

f_declaration	: tINT tWORD tPARO param_proto tPARC {
			// Remise à zero de la liste de paramètres créés
			param_index = 0;
			
			struct element *element = find_sym(&sym, $2);
			// Si l'élément n'est pas déjà dans la table des symboles
			if (element == NULL) {
				element = add_sym(&sym, $2, T_FUN);
				element->nb_parameters = $4;
				// La fonction n'est ici pas encore initialisee
				element->initialized = 0;
				// La valeur retour est le nom de la fonction
				$$ = $2;
			} else if (element->nb_parameters != $4) {
				//TODO error: previous declaration of ‘f’ was here 
				fprintf(stderr, "Error : conflicting types for '%s'\n", $2);
			}
		}
		| tINT tWORD tPARO tPARC {
			struct element *element = find_sym(&sym, $2);
			// Si l'élément n'est pas déjà dans la table des symboles
			if (element == NULL) {
				struct element *element = add_sym(&sym, $2, T_FUN);
				element->nb_parameters = 0;
				// La fonction n'est ici pas encore initialisee
				element->initialized = 0;
				// La valeur retour est le nom de la fonction
				$$ = $2;
			} else if (element->nb_parameters != 0) {
					//TODO error: previous declaration of ‘f’ was here 
					fprintf(stderr, "Error : conflicting types for '%s'\n", $2);
			}
		}
		;

f_prototype	: tINT tWORD tPARO param_proto tPARC {
			// 1ere étape : Ajout de la fonction à la table des symboles
			// Le type courant est T_INT par defaut
			struct element *element = find_sym(&sym, $2);
			// Si l'élément n'est pas déjà dans la table des symboles
			if (element == NULL) {
				element = add_sym(&sym, $2, T_FUN);
				element->nb_parameters = $4;
				// La fonction n'est ici pas encore initialisee
				element->initialized = 0;
				// On donne l'addresse de la fonction
				element->address = sym.program_counter + 1;

			// Dans le cas d'une redefinition il suffit seulement de vérifier
			// le nb d'argument (car un seul type int et le nom n'importe pas)
			} else if (element->nb_parameters != $4) {
				//TODO error: previous declaration of ‘f’ was here 
				fprintf(stderr, "Error : conflicting types for '%s'\n", $2);
			}
		
			// On stocke le contexte de symbole courant
			// Celui-ci sera dépilé si ce prototype
			// ne sert pas à l'initialisation de la fonction
			sym_push(&sym);
			compile(&sym, "PSH ebp\n");
                        compile(&sym, "COP ebp esp\n");
			printf("Push lors de '%s' prototype.\n", $2);
			// On doit redémarrer les adresses locales à 1
			sym.local_address = 1;
	
			// 2eme étape : push de tous les paramètres
			struct element *elmt;
			int i;
			for (i=0 ; i < param_index; i++) {
			    // Création de l'élément associé au paramètre i
			    elmt = find_sym(&sym, param_list[i]);
			    // Si l'élément n'est pas déjà dans la table des symboles
			    // Cas d'un prototype de fonction avec 2 paramètres de même nom
			    if (elmt == NULL) { 
			        // Ajout du symbole dans la table des symboles
			        elmt = add_sym(&sym, param_list[i], T_INT);
		    	        // On donne l'adresse à la variable locale
		    	        elmt->address = sym.local_address;
		    	        // Incrementation des adresses locales
		    	        sym.local_address++;
		    	        // On décale esp de 4 octets allocation de la variable
		    	        compile(&sym, "AFC eax #1\n");
		    	        compile(&sym, "SOU esp esp eax\n");
			    } else if (elmt->nb_parameters != $4) {
			        fprintf(stderr, "Error : redefinition of '%s'\n", param_list[i]);
			        break;
			    }
			}
	      		// Remise à zero de la liste de paramètres créés
			param_index = 0;
			$$ = $2;
		}
		| tINT tWORD tPARO tPARC {
			struct element *element = find_sym(&sym, $2);
			// Si l'élément n'est pas déjà dans la table des symboles
			if (element == NULL) {
				element = add_sym(&sym, $2, T_FUN);
				element->nb_parameters = 0;
				// La fonction n'est ici pas encore initialisee
				element->initialized = 0;
				// On donne l'addresse de la fonction
				element->address = sym.program_counter + 1;
				
			} else if (element->nb_parameters != 0) {
				//TODO error: previous declaration of ‘f’ was here 
				fprintf(stderr, "Error : conflicting types for '%s'\n", $2);
			}
			
			sym_push(&sym);
			compile(&sym, "PSH ebp\n");
                        compile(&sym, "COP ebp esp\n");
			printf("Push lors de '%s' prototype.\n",$2);
			sym.local_address = 1;
			
			$$ = $2;
		}
		;
		
f_definition	: f_prototype {
		  	struct element *element = find_sym(&sym, $1);
		  	if (element == NULL) {
				fprintf(stderr, "Error : undefined symbol '%s'\n", $1);
			}
			else {
				// La fonction est desormais initialisee
		 		element->initialized = 1;
				
                	}
		}
		f_body {
		  struct element *elmt = find_sym(&sym, $1);
			if (elmt == NULL) {
				fprintf(stderr, "Error : undefined symbol '%s'\n", $1);
		  } else {
		    compile(&sym, "RET %d\n",elmt->nb_parameters);
		  }
			
			// On sort de la fonction donc on pop de la table des symboles
			sym_pop(&sym);
			printf("Pop apres body.\n");
		}
		;
		
f_body	: tACCO instructions tACCC {print_sym(&sym);}
	;
	
f_call	: tWORD tPARO param_call tPARC {
		struct element * element = find_sym(&sym, $1);
		if (element != NULL) {
			// Verification de l'initialisation de la fonction
			if (element->initialized == 0) {
			   	fprintf(stderr, "Error : function `%s` is not initialized.\n", $1);			     
			// Verification du nombre d'argument
			} else if ((element->nb_parameters) > $3) {
				fprintf(stderr, "Error : too few arguments to function '%s'\n", $1);
			} else if ((element->nb_parameters) < $3) {
				fprintf(stderr, "Error : too many arguments to function '%s'\n", $1);
			} else {
				printf("Function call ok -> %s has %d parameters\n", $1, element->nb_parameters);
				// Appel de la fonction
				int adr = get_address(&sym, $1);
				// On teste si la fonction est bien initialisée
				if (adr == -1) {
				   	fprintf(stderr, "Error : uninitialized function '%s'\n", $1);
				} else {
					// Appel de la fonction (i.e jump à adr)
				     	compile(&sym, "CAL %d\n", adr);
				}
			}
		} else {
			fprintf(stderr, "Error : undefined symbol '%s'\n", $1);
		}
	}
	| tWORD tPARO tPARC {
		struct element *element = find_sym(&sym, $1);
		if (element != NULL) {
			// Verification de l'initialisation de la fonction
			if (element->initialized == 0) {
				fprintf(stderr, "Error : uninitialized function '%s'\n", $1);
			}
			// Verification du nombre d'argument
			if (element->nb_parameters > 0) {
				fprintf(stderr, "Error : too many arguments to function '%s'\n", $1);
			} else { 
				printf("Function call ok -> %s has %d parameters\n", $1, 0);
				// Appel de la fonction
				int adr = get_address(&sym, $1);
				// On teste si la fonction est bien initialisée
				if (adr == -1) {
				   	fprintf(stderr, "Error : uninitialized function '%s'\n", $1);
				} else {
					// Appel de la fonction (i.e jump à adr)
				     	compile(&sym, "CAL %d\n", adr);
				}
			}
		}
		else {
			fprintf(stderr, "Error : undefined symbol '%s'\n", $1);
		}
	}	
	;

jmpif   : {
                // On récupère l'évalutaion de l'expression qui est en tête de pile
                compile(&sym, "POP eax\n");
                // On jumpe a l'adresse du else qu'on ne connais pas encore, pour l'instant -1
                compile(&sym, "JMF temp_addr\n");
                // On empile une addresse temporaire
                taddress_push(&sym);
        }
        ;

jmpelse : {
                // On connait l'addresse JMF du if de même niveau
                taddress_pop(&sym); 
                // On saute à l'adresse de la fin du else, après avoir réalisé le if
                compile(&sym, "JMP temp_addr\n");
                // On empile une addresse temporaire
                taddress_push(&sym);
        }

if	: tIF tPARO expr tPARC jmpif bloc_instructions %prec LOWER_THAN_ELSE {
                // On connait l'addresse JMF du if de même niveau
                taddress_pop(&sym); 
        } 
        | tIF tPARO expr tPARC jmpif instruction {
                // Il faut au moins une instruction apres un if
                // On connait l'addresse JMF du if de même niveau
                taddress_pop(&sym); 
        } %prec LOWER_THAN_ELSE 
	| tIF tPARO expr tPARC jmpif bloc_instructions else {}
        | tIF tPARO expr tPARC jmpif instruction else {/* Il faut au moins une instruction apres un if */}
	;

else	: tELSE jmpelse bloc_instructions {
                // On connait l'addresse JMF du if de même niveau
                taddress_pop(&sym); 
        }
	| tELSE jmpelse instruction {
		// Il faut au moins une instruction apres un else
                // On connait l'addresse JMF du if de même niveau
                taddress_pop(&sym); 
	}
	;

while	: tWHILE tPARO expr tPARC bloc_instructions {}
	| tWHILE tPARO expr tPARC instruction {}
	;
		
printf	: tPRINTF tPARO tWORD tPARC {
		int adr = get_address(&sym, $3); 
		if (adr == -1 ){
		  fprintf(stderr, "Error : '%s' undeclared (first use in this function).\n", $3);
		} else {
		  compile(&sym, "PRI [ebp]-%d\n", adr);
		}
	}
	;
%%

void yyerror(char *s) {
  fprintf(stderr, "Vous ne maîtrisez pas les concepts : %s at line %d\n", s, line);
}

int main(int argc, char **argv) {
  // Initialisation de la table des symboles
  create_sym(&sym);
  do_options(argc, argv);
  yyparse();

  // On compile l'appel au main
  struct element * element = find_sym(&sym, "main");
  if (element != NULL) {
    // Verification de l'initialisation de la fonction
    if (element->initialized == 0) {
      fprintf(stderr, "Error : function main is not initialized.\n");
      // Verification du nombre d'argument
    } else {
      // Appel de la fonction
      int adr = get_address(&sym, "main");
      // On teste si la fonction est bien initialisée
      if (adr == -1) {
        fprintf(stderr, "Error : uninitialized function main\n");
      } else {
        // Appel de la fonction (i.e jump à adr)
        compile(&sym, "CAL %d\n", adr);
      }
    }
  } else {
    fprintf(stderr, "Error : undefined symbol main\n");
  }

  print_sym(&sym);
  printf("Dernière addresse du programme : %d\n", sym.program_counter);

  second_pass(&sym);

  free_sym(&sym);
  close_files();
  return 0;  
}
