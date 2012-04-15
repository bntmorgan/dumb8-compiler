/****FICHIER DE TESTS*/

/****Declarations*/
int a = 1;
int b = 11;
int d = 21;

/****Affectations*/
a = 3;
b = d = e = 5;

/****Appels de fonctions*/
f();
f2(aa, bb, 5, 12);

/***Declarations de fonctions*/
int g();
int g2(int i, int j);

/***Definitions de fonctions*/
int h(){f(x);};
int h2(int i, int j){int yy=3;};

/***Bloc*/
{int h(); int z=3;}

/***If*/
if (1>5) {}
if (5) {int a = 8;}
if (4 == 5+B) {int o=0;f(x);}
if (1) f(x);
else if (3<k) {k=4;}
else {}

/***While*/
while (1) f(x);

/***Print*/
printf(a);
int q =6;
{int q =34;
int b = 3;
printf(b);}
