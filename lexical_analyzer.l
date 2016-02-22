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
\n {line++;}
. {return tERROR;}

%%
