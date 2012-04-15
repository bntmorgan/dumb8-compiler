#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "sym.h"

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
  sym->context_stack = malloc(SIZE_STEP * sizeof(int));
  if (sym->context_stack == NULL) {
    perror("Error while initializing context stack");
    free(sym->t);
    return -1;
  }
  sym->context_stack_size = SIZE_STEP;
  // Le premier index est a -1 : la pile est vide
  sym->context_stack_head = -1;
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
  sym->context_stack = realloc(sym->context_stack, sym->context_stack_size * sizeof(int));
  if (sym->context_stack == NULL) {
    return -1;
  }
  return 0;
}

int add_sym(struct t_sym *sym, char *name) {
  // On teste si après avoir incrémenté l'index on pointe sur un élément du tableau
  if ((sym->idx + 1) >= sym->size) {
    if (inc_sym(sym) != 0) {
      return -1;
    }
  }
  sym->t[sym->idx].name = name;
  sym->t[sym->idx].type = sym->current_type;
  sym->idx++;
  return 0;
}

void print_sym(struct t_sym *sym) {
  int i;
  printf("---------- TABLE DES SYMBOLES ----------\n");
  printf("| Taille : %27d |\n", sym->size);
  printf("| Index : %28d |\n", sym->idx);
  printf("| Type courant : %21d |\n", sym->current_type);
  printf("----------------------------------------\n");
  printf("| Variables déclarées :                |\n");
  printf("----------------------------------------\n");
  for(i = 0; i < sym->idx; i++) {
    printf("| Nom : %19s | type : %d |\n", sym->t[i].name, sym->t[i].type);
  }
  printf("----------------------------------------\n");
}

struct element* find_sym(struct t_sym *sym, char *name) {
  int i;
  for (i = 0; i < sym->idx; i++) {
    if (strcmp(name, sym->t[i].name) == 0) {
      return &(sym->t[i]);
    }
  }
  return NULL;
}

int get_sym_idx(struct t_sym *sym) {
  return sym->idx;
}

int sym_push(struct t_sym *sym) {
  printf("PUSH \n");
  if (sym->context_stack_head + 1 >= sym->context_stack_size) {
    inc_context_stack_sym(sym);
  }
  sym->context_stack_head++;
  sym->context_stack[sym->context_stack_head] = sym->idx;
  return 0;
}

int sym_pop(struct t_sym *sym) {
  printf("POP \n");
  if (sym->context_stack_head < 0) {
    return -1;
  }
  // Freeing the names
  int old_idx = sym->context_stack[sym->context_stack_head];
  int current_idx = sym->idx;
  for (; old_idx < current_idx; old_idx++) {
    free(sym->t[old_idx].name);
  }
  // Getting the old context
  sym->idx = sym->context_stack[sym->context_stack_head];
  sym->context_stack_head--;
  return 0;
}
