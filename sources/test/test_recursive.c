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

