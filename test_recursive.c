int tictac(int n);

int tuning(int n);

int main () {
  int a = 42;
  tictac(10);
  int b = 0;
  while ( b < 10) {
    b = tuning(b);
    printf(b);
  }
  return 0;
}

int tictac(int n) {
  printf(n);
  if (n > 0) {
    tictac(n - 1);
  }
}

int tuning(int a) {
  int b = a + 1;
  return b;
}

