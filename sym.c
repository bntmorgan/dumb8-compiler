#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <stdarg.h>
#include "sym.h"

// Fichier ou compiler
extern FILE *file_out;
extern FILE *file_out_pass_2;

/**
 * Incrémente la taille de la table des symboles
 *
 * @param sym la table des symboles
 * @return 0 si tout se passe bien -1 si erreur d'allocation
 */
int inc_sym(struct t_sym *sym);

/**
 * Incrémente la taille de la pile de contexte
 * 
 * @param sym la table des symboles
 * @return 0 si tout se passe bien -1 si erreur d'allocation
 */
int inc_context_stack_sym(struct t_sym *sym);

void create_sym(struct t_sym *sym) {
  memset(sym, 0, sizeof(struct t_sym));
  sym->size = SIZE_STEP;
  // Allocation de la table des symboles
  sym->t = malloc(SIZE_STEP * sizeof(struct t_sym));
  if(sym->t == NULL) {
    perror("Error while initializing symbol table");
    exit(EXIT_FAILURE);
  } 
  // Allocation / initialisation de la pile de contexte
  sym->context_stack = malloc(SIZE_STEP * sizeof(struct context));
  if (sym->context_stack == NULL) {
    perror("Error while initializing context stack");
    exit(EXIT_FAILURE);
  }
  // Allocation / initialisation de la pile d'adresses temporaires
  sym->ta = malloc(SIZE_STEP * sizeof(struct taddress));
  if (sym->ta == NULL) {
    perror("Error while initializing temp address stack");
    exit(EXIT_FAILURE);
  }
  sym->context_stack_size = SIZE_STEP;
  // Le premier index est a -1 : la pile est vide
  sym->context_stack_head = -1;
  // On a rien compilé
  sym->program_counter = -1;
  // Première addresse d'une variable locale
  sym->local_address = 1;
  // Taille de la pile d'adresses temporaires
  sym->taddress_stack_size = SIZE_STEP;
  // Tête de la pile d'adresses temporaires
  sym->taddress_stack_head = -1;
  // Vrai tête de pile, premier élément qui est à -1 en partant de la tête
  sym->taddress_stack_real_head = -1;
}

void free_sym(struct t_sym *sym){
  free(sym->t);
  free(sym->context_stack);
  free(sym->ta);
}

int inc_sym(struct t_sym *sym) {
  sym->size *= 2;
  // Augmente la taille de la table des symbole de deux fois la taille courante
  sym->t = realloc(sym->t, sym->size * sizeof(struct t_sym));
  if (sym->t == NULL) {
    return -1;
  }
  return 0;
}

int inc_context_stack_sym(struct t_sym *sym) {
  sym->context_stack_size *= 2;
  // Augmente la taille de la pile des contextes de deux fois la taille courante
  sym->context_stack = realloc(sym->context_stack, sym->context_stack_size * sizeof(struct context));
  if (sym->context_stack == NULL) {
    return -1;
  }
  return 0;
}

int inc_taddress_stack(struct t_sym *sym) {
  sym->taddress_stack_size *= 2;
  // Augmente la taille de la pile des contextes de deux fois la taille courante
  sym->ta = realloc(sym->ta, sym->taddress_stack_size * sizeof(struct taddress));
  if (sym->ta == NULL) {
    return -1;
  }
  return 0;
}

struct element* add_sym(struct t_sym *sym, char *name, int type) {
  // On teste si après avoir incrémenté l'index on pointe sur un élément du tableau
  if ((sym->idx + 1) >= sym->size) {
    if (inc_sym(sym) != 0) {
      return NULL;
    }
  }
  sym->t[sym->idx].name = name;
  sym->t[sym->idx].type = type;
  // On indique que la variable n'est pas initialisée
  sym->t[sym->idx].address = 0;
  sym->t[sym->idx].initialized = 0;
  sym->idx++;
  return &(sym->t[sym->idx-1]);
}

void print_sym(struct t_sym *sym) {
  int i;
  printf("+------------------------ TABLE DES SYMBOLES --------------------------+\n");
  printf("| Taille : %59d |\n", sym->size);
  printf("| Index : %60d |\n", sym->idx);
  printf("+----------------------------------------------------------------------+\n");
  printf("| Variables déclarées :                                                |\n");
  printf("+----------------------------------------------------------------------+\n");
  for (i = 0; i < sym->idx; i++) {
    if (sym->t[i].type == T_INT) {
      printf("| Nom : %16s | const : %d | type : %d | init : %d | adr : %3d |\n", sym->t[i].name, sym->t[i].constant, sym->t[i].type, sym->t[i].initialized, sym->t[i].address);
    }
  }
  printf("+----------------------------------------------------------------------+\n");
  printf("| Fonctions déclarées :                                                |\n");
  printf("+----------------------------------------------------------------------+\n");
  for (i = 0; i < sym->idx; i++) {
    if (sym->t[i].type == T_FUN) {
      printf("| Nom : %15s | nb arg : %d | type : %d | init : %d | adr : %3d |\n", sym->t[i].name, sym->t[i].nb_parameters, sym->t[i].type, sym->t[i].initialized, sym->t[i].address);
    }  
  }
  printf("+----------------------------------------------------------------------+\n");
  printf("| Adresses temporaires :                                               |\n");
  printf("+----------------------------------------------------------------------+\n");
  for (i = 0; i <= sym->taddress_stack_head; i++) {
    printf("| Ligne : %4d | Adresse : %4d                                        |\n", sym->ta[i].line + 1, sym->ta[i].address);
  }
  printf("+----------------------------------------------------------------------+\n");
}

struct element* find_sym(struct t_sym *sym, char *name) {
  int i;
  // On cherche de la tête de pile vers le bas pour avoir les 
  // dernières variables instanciées
  for (i = sym->idx - 1; i >= 0; i--) {
    if (strcmp(name, sym->t[i].name) == 0) {
      return &(sym->t[i]);
    }
  }
  return NULL;
}

int get_sym_idx(struct t_sym *sym) {
  return sym->idx;
}

int get_address(struct t_sym *sym, char *name) {
  int ret = NB_MAX_ADR;
  int i;
  /*La recherche debute a la fin de la table pour retourner en priorité 
   variables propres à un bloc*/
  for (i = sym->idx-1; i >= 0; i--) {
    if (strcmp(name, sym->t[i].name) == 0) {
      // récupération de l'adresse de la variable
      ret = sym->t[i].address;
      break;
    }
  }
  return ret;
}

int sym_push(struct t_sym *sym) {
  if (sym->context_stack_head + 1 >= sym->context_stack_size) {
    inc_context_stack_sym(sym);
  }
  sym->context_stack_head++;
  sym->context_stack[sym->context_stack_head].idx = sym->idx;
  sym->context_stack[sym->context_stack_head].local_address = sym->local_address;
  return 0;
}

int sym_pop(struct t_sym *sym) {
  if (sym->context_stack_head < 0) {
    return -1;
  }
  // Libération des noms
  int old_idx = sym->context_stack[sym->context_stack_head].idx;
  int current_idx = sym->idx;
  for (; old_idx < current_idx; old_idx++) {
    free(sym->t[old_idx].name);
  }
  // Récupération du contexte précédent
  sym->idx = sym->context_stack[sym->context_stack_head].idx;
  sym->local_address = sym->context_stack[sym->context_stack_head].local_address;
  sym->context_stack_head--;
  return 0;
}

int taddress_push(struct t_sym *sym) {
  if (sym->taddress_stack_head + 1 >= sym->taddress_stack_size) {
    inc_taddress_stack(sym);
  }
  sym->taddress_stack_head++;
  sym->taddress_stack_real_head = sym->taddress_stack_head;

  sym->ta[sym->taddress_stack_head].address = -1;
  sym->ta[sym->taddress_stack_head].line = sym->program_counter;
  return 0;
}

int taddress_pop(struct t_sym *sym) {
  if (sym->taddress_stack_real_head < 0) {
    return -1;
  }
  sym->ta[sym->taddress_stack_real_head].address = sym->program_counter + 1; // On saute a la prochaine addresse !
  // Recherche du prochain head a -1
  int i = sym->taddress_stack_real_head - 1;
  while (i > -1) {
    if (sym->ta[i].address == -1){
      sym->taddress_stack_real_head = i;
      break;
    }
    i--;
  }
  return 0;
}

int is_constant(struct t_sym *sym, char *name) {
  struct element *elmt = find_sym(sym, name);
  if (elmt == NULL) {
    return -1;
  }
  return elmt->constant;
}

void compile(struct t_sym *sym, const char *format, ...) {
  va_list args;
  va_start (args, format);
  vfprintf(file_out, format, args);
  va_end(args);
  // Incrementation du compteur d'adresses du programme
  sym->program_counter++;
}

void second_pass(struct t_sym *sym) {
  int i = 0;
  struct element * elmt;
  // On revient au debut du fichier pour traiter les addresses temporaires
  fseek(file_out, 0, SEEK_SET);
  // On boucle sur toutes les lignes
  while (1) {
    char *line = malloc(sizeof(char)*30);
    char *lus = fgets(line, 30, file_out);
    // Si on a fini
    if (lus == NULL) {
      break;
    }
    // On teste si la ligne contient une adresse temporaire
    // liée à un if
    char *r = strstr(line, "temp_addr");
    if (r != NULL) {
      // On affiche l'instruction
      *r = '\0';
      fprintf(file_out_pass_2, "%s", line);
      fprintf(file_out_pass_2, "%d\n", sym->ta[i].address);
      i++;
    } else if ((r = strstr(line, "f_addr")) != NULL) {
      // Test si adresse temporaire liée à une déclaration de fonction en décalé du prototype
      char *eol = strstr(line, "\n");
      *eol = '\0';
      elmt = find_sym(sym, (r+7));
      *r = '\0';
      if (elmt->address != -1) {
        fprintf(file_out_pass_2, "%s", line);
        fprintf(file_out_pass_2, "%d\n", elmt->address);
      } else {
        perror("Error : function uninitialized");
        exit(EXIT_FAILURE);
      }
    } else {
      fprintf(file_out_pass_2, "%s", line);
    }
    free(line);
  }
}

