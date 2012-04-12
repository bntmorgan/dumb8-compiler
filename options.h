#ifndef __OPTIONS_H__
#define __OPTIONS_H__

/**
 * Fichier de sortie
 *
 * Si on ne spécifie pas de fichier avec l'option o 
 * a.out.s sera choisi
 */
extern FILE* file_out;

/**
 * Traite les options du compilateur
 *
 * @param argc Nombre d'argument y compris le nom de l'exécutable
 * @param argv Tableau des arguments
 */
void do_options(int argc, char **argv);

#endif//__OPTIONS_H__
