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

int main() {
  int a = 0;
  int b = 23;
  int c = 33;
  while (a < 7) {
    a = a + 1;
    printf(a);
  }
  while (a < 9) {
    if(0){
      printf(b);
    } else {
     if (5)
       printf(c);
    }
    a = a + 1;
  }
  while (1)
    printf(a);
}
