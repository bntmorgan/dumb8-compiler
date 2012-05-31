int g(int i, int j);
int f() {
  g(33,44); 
}

int g(int i, int j) {
  printf(j);
  printf(i);
}

int main() {
  f();
}
