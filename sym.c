#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "sym.h"

/**
 * Incrémente la taille de la table des symboles
 *
 * @param sym la table des symboles
 */
void inc_sym(struct t_sym *sym);

void create_sym(struct t_sym *sym) {
  memset(sym, 0, sizeof(struct t_sym));
  sym->size = SIZE_STEP;
  sym->current_type = T_INT;
  sym->t = malloc(SIZE_STEP * sizeof(struct t_sym));
  if(sym->t == NULL) {
    perror("Error while initializing symbol table");
  }
}

void free_sym(struct t_sym *sym){
  free(sym->t);
}

void inc_sym(struct t_sym *sym) {
  printf("INCREMENTATION\n");
  sym->size *= 2;
  // Augmente la taille de la table des symbole de deux fois la taille courante
  sym->t = realloc(sym->t, sym->size * sizeof(struct t_sym));
}

void add_sym(struct t_sym *sym, char *name) {
  // On teste si après avoir incrémenté l'index on pointe sur un élément du tableau
  if((sym->idx + 1) >= sym->size) {
    inc_sym(sym);
  }
  sym->t[sym->idx].name = name;
  sym->t[sym->idx].type = sym->current_type;
  sym->idx++;
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
