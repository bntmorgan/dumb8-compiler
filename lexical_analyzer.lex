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

%x COMMENT
%%

"/*"			{BEGIN COMMENT;}
<COMMENT>[.|\n]*	{}
<COMMENT>"*/"		{BEGIN INITIAL;printf("\n");}

int			{return tINT;}
const			{return tCONST;}
{INTEGER}		{return tINTEGER;}
{WORD}			{return tWORD;}
"+"			{return tADD;}
-			{return tSUB;}
"/"			{return tDIV;}
"*"			{return tSTAR;}
=			{return tEQ;}
"("			{return tPARO;}
")"			{return tPARC;}
"{"			{return tACCO;}
"}"			{return tACCC;}
;			{return tSEMICOLON;}
"."			{return tDOT;}
,			{return tCOMMA;}
{WHITESPACE}		{}
\n			{}
.			{return tERROR;}

%%
