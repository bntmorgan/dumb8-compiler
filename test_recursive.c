int tictac(int n) {
  printf(n);
  if (n > 0) {
    tictac(n - 1);
  }
}

int main() {
  int a = 42;
  tictac(10);
}
