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

