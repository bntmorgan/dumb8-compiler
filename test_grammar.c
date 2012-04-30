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
int h(){f(x);};
int h2(int i, int j){int yy=3;};

/***Bloc*/
{int h(); int z=3;}

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
