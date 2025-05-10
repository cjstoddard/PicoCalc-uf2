
CC        = $(CROSS_COMPILE)gcc

SYSROOT   = $(shell $(CC) --print-sysroot)

TARGET    = tv

SRC       = tv.c

unexport CFLAGS

CFLAGS     = -Wall -O2

LDFLAGS    = -lncurses

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC) $(LDFLAGS)

clean:
	rm -f $(TARGET)

