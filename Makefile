all: clean fmt info build

build:
	moon build	

fmt: 
	moon fmt
	clang-format -i ./**/*.c
	clang-format -i *.c

clean:
	moon clean

check:
	moon check

info:
	moon info

.PHONY: all build fmt clean check info