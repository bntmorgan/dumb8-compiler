#ifndef __SYM_H__
#define __SYM_H__

/**
 * Taille max de la table des symboles
 */
#define MAX_SYM 4096

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
 * Ajoute une variable dans la table des symboles
 *
 * @param name Nom de variable dans la table des symboles
 */
void add_sym(char *name);

/**
 * Affiche la table des symboles
 */
void print_sym();

/**
 * Cherche un symbole dans la table des symboles et retourne -1 
 * s'il n'existe pas
 * Complexité O(n)
 * 
 * @param name Nom de la variable dans la table des symboles
 * @return Adresse ou -1 si elle n'y est pas
 */
int find_sym(char *name);

/**
 * Retourne l'index courant de la table des symboles
 * 
 * @return index
 */
int get_sym_idx();

#endif//__SYM_H__
