#ifndef __OPTIONS_H__
#define __OPTIONS_H__

#define TEMPNAME_PREFIX "lol"

/**
 * Fichier de sortie
 *
 * Si on ne spécifie pas de fichier avec l'option o 
 * a.out.s sera choisi
 */
extern FILE* file_out;
extern FILE* file_out_pass_2;

/**
 * Traite les options du compilateur
 *
 * @param argc Nombre d'argument y compris le nom de l'exécutable
 * @param argv Tableau des arguments
 */
void do_options(int argc, char **argv);

/**
 * Fermeture des fichiers et annulation de redirection de l'entrée standard
 */
void close_files();

#endif//__OPTIONS_H__
