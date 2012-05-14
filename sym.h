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
  T_INT = 0,
  T_FUN = 2
};

/**
 * Contexte
 */
struct context {
  int idx;
  int local_address;
};

/**
 * Element de la pile des adresses temporaires des if
 * Adresse temporaire = -1 si elle n'a pas été trouvée
 */
struct taddress {
  int address;
  int line;
};

/**
 * Element de la table des symboles
 */
struct element {
  char *name;
  int type;
  int address; // Adresse de la variable : ebp - x pour var (!! x positif), adresse pour fonction
  int initialized; // Drapeau de variable initialisée (1 si init, 0 sinon)
  int constant; // Drapeau de variable read-only
  int nb_parameters; // Nb de parametres d'une fonction
};

/**
 * Table des symboles
 */
struct t_sym {
  struct element *t;
  int idx;
  int size;
  int current_type;
  // Pile des index de contexte
  struct context *context_stack;
  int context_stack_head;
  int context_stack_size;
  // Adresse courante du programme
  int program_counter;
  // Adresse courante des variables locales
  int local_address;
  // Pile des adresses temporaires des if
  struct taddress *ta;
  int taddress_stack_size;
  int taddress_stack_head; // Tête de pile 
  int taddress_stack_real_head; // Premier élémént qui est a -1 en partant de la tête
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
 * @param sym la table des symboles
 * @param name Nom de variable dans la table des symboles
 * @return l'addresse de l'élément si tout se passe bien NULL si erreur d'allocation
 */
struct element* add_sym(struct t_sym *sym, char *name);

/**
 * Affiche la table des symboles
 *
 * @param sym la table des symboles
 */
void print_sym(struct t_sym *sym);

/**
 * Cherche un symbole dans la table des symboles et retourne NULL
 * s'il n'existe pas
 * Complexité O(n)
 * 
 * @param sym la table des symboles
 * @param name Nom de la variable dans la table des symboles
 * @return struct element ou NULL si elle n'y est pas
 */
struct element* find_sym(struct t_sym *sym, char *name);

/**
 * Empile l'index courant de la table des symboles
 *
 * @param sym la table des symboles
 * @return 0 si tout se passe bien -1 si erreur d'allocation
 */
int sym_push(struct t_sym *sym);

/**
 * Dépile l'index en tête de la pile d'index de la table des symboles
 * et le place en index courant
 *
 * @param sym la table des symboles
 * @return 0 si tout se passe bien -1 si erreur d'allocation
 */
int sym_pop(struct t_sym *sym);

/**
 * Retourne l'index courant de la table des symboles
 * ie la prochaine case de libre
 * 
 * @param sym la table des symboles
 * @return index
 */
int get_sym_idx(struct t_sym *sym);

/**
 * Cherche un symbole dans la table des symboles et retourne -1
 * s'il n'existe pas
 * 
 * @param sym la table des symboles
 * @param name Nom de la variable dans la table des symboles
 * @return int Adresse de la variable recherchee ou -1 si elle
 * n'est pas dans la table
 */
int get_address(struct t_sym *sym, char *name);

/**
 * Change le type de symbole courant pour le symbole t.
 *
 * @param t Nouveau type courant : T_INT ou T_FUN
 * @return 0 si le changement s'est bien deroule
 */
int change_current_type(struct t_sym *sym, enum types t);

/**
 * Ajoute une addresse temporaire dans la pile d'adresses temporaires
 * @param sym la table des symboles
 * @return 0 si tout se passe bien -1 si erreur d'allocation
 */
int taddress_push(struct t_sym *sym);

/**
 * Sette avc l'adresse la première addresse temporaire a -1 en tête de pile 
 * @param sym la table des symboles
 * @return 0 si tout se passe bien -1 si erreur
 */
int taddress_pop(struct t_sym *sym);
 
/**
 * Permet de savoir si une variable est read-only ou non.
 *
 * @param name Nom de la variable
 * @return 1 si la variable est une constante, 0 sinon
 */
int is_constant(struct t_sym *sym, char *name);

/**
 * Compile a line
 * 
 * @param symbol table
 * @param format printf format
 * @param Arguments a afficher
 */
void compile(struct t_sym *sym, const char *format, ...);

#endif//__SYM_H__
