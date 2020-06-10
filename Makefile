CC=gcc
LD=ld
OBJCOPY=objcopy
QEMU=~/qemu/bin/qemu-system-ppc64
QEMU_CMD=$(QEMU) -s -M powernv -cpu POWER9 -nographic -bios ./image.bin

LDFLAGS= -N -T powernv.lds -EB
CFLAGS= -nostdlib -mbig-endian

SRC_C := uart.c
SRC_S := h.S

OBJ_C := $(SRC_C:.c=.o)
OBJ_S := $(SRC_S:.S=.o)

all: image
	@size image.elf

	@echo "image.elf mapping:"
	@cat image.map

image.elf: $(OBJ_C) $(OBJ_S) powernv.lds
	$(LD) $(OBJ_C) $(OBJ_S) $(LDFLAGS) -o $@

image.map: image.elf
	nm image.elf | sort > image.map

image.bin: image.elf
	$(OBJCOPY) -O binary $^ $@

image:	image.bin image.map

$(OBJ_C):	$(SRC_C)
	$(CC) $^ -c -o $@ $(CFLAGS)

$(OBJ_S):	$(SRC_S)
	$(CC) $^ -c -o $@ $(CFLAGS)

clean:
	rm -fr *.o
	rm -fr image.*

run: all
	which $(QEMU)
	$(QEMU_CMD)
