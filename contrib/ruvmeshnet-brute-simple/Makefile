.PHONY: all

all: util ruvmeshnet-brute-multi-curve25519 ruvmeshnet-brute-multi-ed25519

util: util.c
	gcc -Wall -std=c89 -O3 -c -o util.o util.c

ruvmeshnet-brute-multi-ed25519: ruvmeshnet-brute-multi-ed25519.c util.o
	gcc -Wall -std=c89 -O3 -o ruvmeshnet-brute-multi-ed25519 -lsodium ruvmeshnet-brute-multi-ed25519.c util.o

ruvmeshnet-brute-multi-curve25519: ruvmeshnet-brute-multi-curve25519.c util.o
	gcc -Wall -std=c89 -O3 -o ruvmeshnet-brute-multi-curve25519 -lsodium ruvmeshnet-brute-multi-curve25519.c util.o
