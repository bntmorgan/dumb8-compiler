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

/****FICHIER DE TESTS*/

/****Declarations*/
int a = 20+8;
int b = 46;
int c = 3;
int p = 0;

/****Affectations*/
a = 3;
c = 23+32-5;
b = a = 5;
p = c/5;

/***Declarations de fonctions*/
int g();
int g2(int i, int j);

/****Appels de fonctions*/
g();
g2(i,j);
f2(aa, bb, 5, 12);

/***Definitions de fonctions*/
int h(){f(x);}
int h2(int i, int j){int yy=3;};

/***Bloc*/
{int z=3;}

/***If*/
if (1>5) {}
if (5) {int a = 8;}
if (4 == 5+b) {int o=0;f(x);}
if (1) f(x);
else if (3<8)
  {c=4242424242;printf(c);}
else {}

/***While*/
while (1) f(x);

/***Print*/
printf(a);
int q = 6;
{int q = 34;
int b = 3;
printf(b);}
