#!/bin/sh
CC="/usr/local/opt/gcc/bin/gcc-7"
OBJDUMP="/usr/local/opt/binutils/bin/gobjdump"

$CC -m32 -march=i386 -mtune=i386 -mfpmath=387 -fno-asynchronous-unwind-tables -fno-pic -O1 -S -s test.c -o test.s && cat test.s
