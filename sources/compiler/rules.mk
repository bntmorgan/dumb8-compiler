# Copyright (C) 2012, 2016 Benoît Morgan
#
# This file is part of dumb8-compiler.
#
# dumb8-compiler is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# dumb8-compiler is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with dumb8-compiler.  If not, see <http://www.gnu.org/licenses/>.

sp              := $(sp).x
dirstack_$(sp)  := $(d)
d               := $(dir)

TARGET					:= $(call SRC_2_BIN, $(d)/compiler)
TARGETS 				+= $(TARGET)
OBJS_$(d)				:= $(call SRC_2_OBJ, $(d)/parser.o $(d)/lexer.o \
		$(d)/sym.o $(d)/options.o)

OBJECTS 				+= $(OBJS_$(d))

$(OBJS_$(d))		:  CC_FLAGS_TARGET	:= -I$(d) -I$(call SRC_2_OBJ, $(d))

$(TARGET)				:  LD_FLAGS_TARGET	:= -ly -lfl
$(TARGET)				:  LD_OBJECTS	:= $(OBJS_$(d))
$(TARGET)				:  $(OBJS_$(d))

# Lex and yacc files dependecies
$(call SRC_2_OBJ, $(d)/parser.o): $(call SRC_2_OBJ, $(d)/lexer.h)
$(call SRC_2_OBJ, $(d)/lexer.o): $(call SRC_2_OBJ, $(d)/parser.h)

d               := $(dirstack_$(sp))
sp              := $(basename $(sp))
