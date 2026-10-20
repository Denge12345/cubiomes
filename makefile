#CC      = gcc
#AR      = ar
ARFLAGS = cr
override LDFLAGS = -lm
override CFLAGS += -Wall -Wextra -fwrapv

ifeq ($(OS),Windows_NT)
	override CFLAGS += -D_WIN32
	CC = gcc
	RM = del /Q
else
	override LDFLAGS += -pthread
	RM = rm -f
endif

.PHONY : all debug release native libcubiomes clean

all: release

debug: CFLAGS += -DDEBUG -O0 -ggdb3
debug: libcubiomes
release: CFLAGS += -O3
release: libcubiomes
native: CFLAGS += -O3 -march=native -ffast-math
native: libcubiomes

ifneq ($(OS),Windows_NT)
release: CFLAGS += -fPIC
#debug: CFLAGS += -fsanitize=undefined
endif

# The library was restructured into sub-directories (features, loot, ...),
# so collect the translation units instead of listing them manually.
SOURCES = \
	$(filter-out tests.c,$(wildcard *.c)) \
	$(wildcard features/*.c) \
	$(wildcard loot/*.c) \
	$(wildcard loot/cjson/*.c) \
	$(wildcard loot/loot_tables/*.c) \
	$(wildcard loot/loot_tables/chests/*.c) \
	$(wildcard loot/loot_tables/chests/trial_chambers/*.c) \
	$(wildcard loot/loot_tables/barrels/*.c)

OBJECTS = $(SOURCES:.c=.o)

libcubiomes: $(OBJECTS)
	$(AR) $(ARFLAGS) libcubiomes.a $^

%.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@

clean:
	-$(RM) $(OBJECTS) libcubiomes.a
