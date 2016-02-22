/*
Copyright (C) 2012  Carla Sauvanaud
Copyright (C) 2012, 2016  Benoît Morgan

This file is part of dumb8-compiler.

dumb8-compiler is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

dumb8-compiler is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with dumb8-compiler.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "options.h"

// Fichier de sortie
FILE* file_out = NULL;
FILE* file_out_pass_2 = NULL;

// Sauvegarde de l'entrée standard
int stdin_fd = 0;

void do_options(int argc, char **argv) {
  int c;

  while ((c = getopt (argc, argv, "o:")) != -1) {
    switch (c) {
    case 'o':
      file_out_pass_2 = fopen(optarg, "w");
      if (file_out_pass_2 == NULL) {
        perror("Error while creating output file");
        exit(1);
      }
      break;
    case '?':
      if (optopt == 'o') {
        fprintf (stderr, "Option -%c requires an argument.\n", optopt);
      } else if (isprint (optopt)) {
        fprintf (stderr, "Unknown option `-%c'.\n", optopt);
      } else {
        fprintf (stderr, "Unknown option character `\\x%x'.\n", optopt);
      }
      exit(1);
    default:
      abort ();
    }
  }

  // Ouverture du fichier temporaire
  char *name = tempnam(NULL, TEMPNAME_PREFIX);
  file_out = fopen(name, "w+");
  if (file_out == NULL) {
    perror("Error while creating output file");
    exit(1);
  }
  free(name);

  // Pas de fichier donné : fichier par défaut "a.out.s"
  if (file_out_pass_2 == NULL) {
    file_out_pass_2 = fopen("a.out.s", "w");
    if (file_out == NULL) {
      perror("Error while creating output file");
      exit(1);
    }
  }

  // Gestion du fichier d'entrée à compiler
  if (optind < argc) {
    // On sauvegarde l'entrée standard
    stdin_fd = dup(STDIN_FILENO);
    // On ferme le vieux descripteur de fichier
    close(STDIN_FILENO);
    // On ouvre le nouveau fichier qui prendra STDIN_FILENO en descripteur
    if (open(argv[optind], O_RDONLY) == -1) {
      perror("Error while openning file to compile");
      exit(1);
    }
  } else {
    fprintf(stderr, "Cannot compile no file\n");
    exit(1);
  }
}

void close_files() {
  // Fermeture du fichier redirigé sur l'entrée standard
  close(STDIN_FILENO);
  // Récupération de l'entrée standard
  dup(stdin_fd);
  // Libération du descripteur de sauvegarde de l'entrée standard
  close(stdin_fd);
  // Fermeture du fichier de sortie de compilation
  fclose(file_out);
  fclose(file_out_pass_2);
}
