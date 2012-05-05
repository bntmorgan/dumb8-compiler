#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <stdarg.h>
#include "sym.h"

// Fichier ou compiler
extern FILE *file_out;

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

int create_sym(struct t_sym *sym) {
  memset(sym, 0, sizeof(struct t_sym));
  sym->size = SIZE_STEP;
  sym->current_type = T_INT;
  // Allocation de la table des symboles
  sym->t = malloc(SIZE_STEP * sizeof(struct t_sym));
  if(sym->t == NULL) {
    perror("Error while initializing symbol table");
    return -1;
  } 
  // Allocation / initialisation de la pile de contexte
  sym->context_stack = malloc(SIZE_STEP * sizeof(struct context));
  if (sym->context_stack == NULL) {
    perror("Error while initializing context stack");
    free(sym->t);
    return -1;
  }
  sym->context_stack_size = SIZE_STEP;
  // Le premier index est a -1 : la pile est vide
  sym->context_stack_head = -1;
  // On a rien compilé
  sym->program_counter = -1;
  // Première addresse d'une variable locale
  sym->local_address = 1;
  return 0;
}

void free_sym(struct t_sym *sym){
  free(sym->t);
  free(sym->context_stack);
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

struct element* add_sym(struct t_sym *sym, char *name) {
  // On teste si après avoir incrémenté l'index on pointe sur un élément du tableau
  if ((sym->idx + 1) >= sym->size) {
    if (inc_sym(sym) != 0) {
      return NULL;
    }
  }
  sym->t[sym->idx].name = name;
  sym->t[sym->idx].type = sym->current_type;
  // On indique que la variable n'est pas initialisée
  sym->t[sym->idx].address = 0;
  sym->t[sym->idx].initialized = 0;
  sym->idx++;
  return &(sym->t[sym->idx-1]);
}

void print_sym(struct t_sym *sym) {
  int i;
  printf("+--------------------- TABLE DES SYMBOLES -----------------------+\n");
  printf("| Taille : %53d |\n", sym->size);
  printf("| Index : %54d |\n", sym->idx);
  printf("+----------------------------------------------------------------+\n");
  printf("| Variables déclarées :                                          |\n");
  printf("+----------------------------------------------------------------+\n");
  for (i = 0; i < sym->idx; i++) {
    if (sym->t[i].type == T_INT) {
      printf("| Nom : %22s | type : %d | init : %d | adr : %3d |\n", sym->t[i].name, sym->t[i].type, sym->t[i].initialized, sym->t[i].address);
    }
  }
  printf("+----------------------------------------------------------------+\n");
  printf("| Fonctions déclarées :                                          |\n");
  printf("+----------------------------------------------------------------+\n");
  for (i = 0; i < sym->idx; i++) {
    if (sym->t[i].type == T_FUN) {
      printf("| Nom : %9s | nb arg : %d | type : %d | init : %d | adr : %3d |\n", sym->t[i].name, sym->t[i].nb_parameters, sym->t[i].type, sym->t[i].initialized, sym->t[i].address);
    }  
  }
  printf("+----------------------------------------------------------------+\n");
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
  int ret = -1;
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

int change_current_type(struct t_sym *sym, enum types t) {
  sym->current_type = t;
  return 0;
}

void compile(struct t_sym *sym, const char *format, ...) {
  va_list args;
  va_start (args, format);
  vfprintf(file_out, format, args);
  va_end(args);
  // Incrementation du compteur d'adresses du programme
  sym->program_counter++;
}
