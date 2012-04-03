#include <stdio.h>
#include <stdlib.h>
#include "sym.h"

/**
 * Table des symboles
 */
struct element tsym[MAX_SYM] = {};

/**
 * Index de la tete courante de la table des symboles
 */
int tsym_idx = 0;

/**
 * variable indiquant le type courant
 */
int current_type = T_INT;

void add_sym(char *name) {
  tsym[tsym_idx].name = name;
  tsym[tsym_idx].type = current_type;
  tsym_idx++;
}

void print_sym() {
  int i;
  for(i = 0; i < tsym_idx; i++) {
    printf("nom %s type %d\n", tsym[i].name, tsym[i].type);
  }
}

int find_sym(char *name) {
  
}

int get_sym_idx() {
  return tsym_idx;
}
