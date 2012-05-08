int g() {
  int b;
  b = 12;
  printf(b);
}

int f(int i, int j) {
  int a;
  a = 3 * 4 + 5;
  printf(a);
  g();
}

int main() {
  f(4,5);
}
