int fibo(int n) {
  int a;
  if (n == 1) {
    a = 1;
  } else if (n == 2) {
    a = 1;
  } else {
    int b = fibo(n - 1);
    int c = fibo(n - 2);
    a = b + c;
  }
  return a;
}

int main() {
  int a = fibo(20);
  printf(a);
  return 0;
}

