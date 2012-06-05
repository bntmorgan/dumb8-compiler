%{
#include <stdlib.h>
#include <stdio.h>
#include "syntaxic_analyzer.h"

int line = 1;

%}
 
DIGIT [0-9]
DECIMALNUM [0-9]+
EXPONETIAL {DECIMALNUM}e{DECIMALNUM}
INTEGER {DECIMALNUM}|{EXPONETIAL}
WHITESPACE [ \t]
WORD [a-zA-Z0-9_]+

%x COMMENT
%%

"/*" {BEGIN COMMENT;}
<COMMENT>\n {line++;}
<COMMENT>[.]* {}
<COMMENT>"*/" {BEGIN INITIAL;printf("\n");}

int {return tINT;}
const {return tCONST;}
printf {return tPRINTF;}
if {return tIF;}
else {return tELSE;}
while {return tWHILE;}
return {return tRETURN;}
{INTEGER} {yylval.entier = atoi(yytext); return tINTEGER;}
== {return tEQEQ;}
= {return tEQ;}
"!" {return tEXCL;}
{WORD} {yylval.chaine = strdup(yytext) ; return tWORD;}
"+" {return tADD;}
- {return tSUB;}
"/" {return tDIV;}
"*" {return tSTAR;}
">" {return tSUP;}
"<" {return tINF;}
"(" {return tPARO;}
")" {return tPARC;}
"{" {return tACCO;}
"}" {return tACCC;}
; {return tSEMICOLON;}
"." {return tDOT;}
, {return tCOMMA;}
{WHITESPACE} {}
\n      {line++;}
.     {return tERROR;}

%%
