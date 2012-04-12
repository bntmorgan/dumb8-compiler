#ifndef __SYM_H__
#define __SYM_H__

/**
 * Taille max de la table des symboles
 */
#define SIZE_STEP 32

/**
 * Les types de la table des symboles
 */
enum types {
  T_INT
};

/**
 * Element de la table des symboles
 */
struct element {
  char *name;
  int type;
};

/**
 * Table des symboles
 */
struct t_sym {
  struct element *t;
  int idx;
  int size;
  int current_type;
};

/**
 * Cree la table des symboles
 *
 * @param sym la table des symboles à initialiser
 */
void create_sym(struct t_sym *sym);

/**
 * Detruis la table des symboles
 *
 * @param sym la table des symboles à détruire
 */
void free_sym(struct t_sym *sym);

/**
 * Ajoute une variable dans la table des symboles
 *
 * @param name Nom de variable dans la table des symboles
 */
void add_sym(struct t_sym *sym, char *name);

/**
 * Affiche la table des symboles
 */
void print_sym(struct t_sym *sym);

/**
 * Cherche un symbole dans la table des symboles et retourne NULL
 * s'il n'existe pas
 * Complexité O(n)
 * 
 * @param name Nom de la variable dans la table des symboles
 * @return struct element ou NULL si elle n'y est pas
 */
struct element* find_sym(struct t_sym *sym, char *name);

/**
 * Retourne l'index courant de la table des symboles
 * 
 * @return index
 */
int get_sym_idx(struct t_sym *sym);

#endif//__SYM_H__
