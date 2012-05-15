int g(int i, int j) {
  printf(i);
  printf(j);
}

int f() {
  int k, o;
  k = 45;
  o = 7;
  g(k,o);
}

int main() {
  f();
}
