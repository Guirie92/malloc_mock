# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: guillsan <guillsan@student.42madrid.com    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/10/31 20:56:48 by guillsan          #+#    #+#              #
#    Updated: 2025/11/01 01:12:53 by guillsan         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

CC := gcc
CFLAGS := -Wall -Wextra -g

# Where to put the final executable (project root)
ifeq ($(MODE),local)
    EXEC := ./a.out
else
    EXEC := ../a.out
endif

# Mock implementation and override header (in this dir)
MM_SRC := $(abspath malloc_mock.c)
MM_BNAME := $(notdir $(MM_SRC))         # malloc_mock.c
MM_OBJ := malloc_mock.o
OVERRIDE_HEADER := $(abspath malloc_mock.h)
OVERRIDE_FLAG := -include $(OVERRIDE_HEADER)

# Mode: local | parent | deep
MODE ?= parent

# ===========================================================
# Source file selection modes
# ===========================================================

# choose source collection based on MODE
ifeq ($(MODE),local)
    # compile sources in current folder and its subdirs, excluding malloc_mock/*
    SRC_PATHS := $(shell find . -type f -name '*.c' -not -path './malloc_mock/*' -print)
else ifeq ($(MODE),parent)
    # compile only top-level .c files in parent folder
    SRC_PATHS := $(shell find ../ -maxdepth 1 -type f -name '*.c' -print)
else ifeq ($(MODE),deep)
    # compile recursively under parent, excluding this folder
    SRC_PATHS := $(shell find .. -type f -name '*.c' -not -path '../malloc_mock/*' -print)
else
    $(error Invalid MODE '$(MODE)'; use local | parent | deep)
endif

# ===========================================================
# Object building
# ===========================================================
# remove the mock implementation from collected sources (by basename)
# handle both abspath vs basename cases
SRC_PATHS := $(filter-out %/$(MM_BNAME),$(SRC_PATHS))
SRC_PATHS := $(filter-out $(MM_BNAME),$(SRC_PATHS))

# compute objects using basenames, to emit them into current dir
OBJS := $(patsubst %.c,%.o,$(notdir $(SRC_PATHS)))

all: test

info:
	@echo "MODE: $(MODE)"
	@echo "SRC_PATHS:"
	@printf "  %s\n" $(SRC_PATHS)
	@echo "OBJS:"
	@printf "  %s\n" $(OBJS)
	@echo "MM_SRC = $(MM_SRC)"

# ensure we have at least one non-mock source
ifeq ($(words $(OBJS)),0)
$(warning No non-mock sources found for MODE=$(MODE). Nothing to build except the mock.)
endif

# Compile project sources WITH the override injected.
# map basename.o -> actual path via find (first match)
$(OBJS): %.o:
	@src_path=$$(printf "%s\n" $(SRC_PATHS) | grep -E "/$*.c$$" | head -n1); \
	if [ -z "$$src_path" ]; then \
	    src_path=$$(printf "%s\n" $(SRC_PATHS) | grep -E "^./$*.c$$" | head -n1); \
	fi; \
	if [ -z "$$src_path" ]; then \
	    echo "ERROR: source for $*.c not found (checked: $(SRC_PATHS))"; exit 1; \
	fi; \
	echo "CC $$src_path -> $@"; \
	$(CC) $(CFLAGS) $(OVERRIDE_FLAG) -c "$$src_path" -o "$@"

# Compile malloc_mock.c without override (important)
$(MM_OBJ): $(MM_SRC)
	@echo "CC $(MM_SRC)"
	$(CC) $(CFLAGS) -c $(MM_SRC) -o $(MM_OBJ)

# Link - require at least one object besides mock, otherwise error
test: $(MM_OBJ) $(OBJS)
ifeq ($(words $(OBJS)),0)
	@echo "ERROR: No target source files found for MODE=$(MODE). Aborting link (no main)."
	@false
else
	@echo "Linking $(EXEC)"
	$(CC) $(CFLAGS) -o $(EXEC) $(MM_OBJ) $(OBJS) -ldl
endif

clean:
	rm -f $(OBJS) $(MM_OBJ) $(EXEC)

fclean: clean
	rm -f *.o *.out *.gch ../*.o ../*.out ../*.gch */*.o */*.out */*.gch

re: fclean all

.PHONY: all test clean fclean re info