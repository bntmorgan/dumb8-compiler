#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <ctype.h>
#include "options.h"

FILE* file_out = NULL;

void do_options(int argc, char **argv) {
  int c;

  while ((c = getopt (argc, argv, "n:")) != -1) {
    switch (c) {
    case 'o':
      file_out = fopen(optarg, "w");
      if (file_out == NULL) {
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
  
  // Pas de fichier donné : fichier par défaut "a.out.s"
  if (file_out == NULL) {
    file_out = fopen("a.out.s", "w");
    if (file_out == NULL) {
      perror("Error while creating output file");
      exit(1);
    }
  }

}
