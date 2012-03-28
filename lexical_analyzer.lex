%{
#include <stdlib.h>
#include <stdio.h>
#include "syntaxic_analyzer.h"
%}
 
DIGIT [0-9]
DECIMALNUM [0-9]+
EXPONETIAL {DECIMALNUM}e{DECIMALNUM}
INTEGER {DECIMALNUM}|{EXPONETIAL}
WHITESPACE [ \t]
WORD [a-zA-Z0-9_]+

%%


printf			{return tPRINTF; /* XXX : Version de base : pas de reconnaissance de fonctions*/}
int			{return tINT;}
const			{return tCONST;}
main			{return tMAIN;}
{INTEGER}		{return tINTEGER;}
{WORD}			{return tWORD;}
\+			{return tADD;}
-			{return tSUB;}
\/			{return tDIV;}
\*			{return tSTAR;}
=			{return tEQ;}
\(			{return tPARO;}
\)			{return tPARC;}
;			{return tSEMICOLON;}
\.			{return tDOT;}
,			{return tCOMMA;}
{WHITESPACE}		{}
\n			{}
.			{return tERROR;}

%%
