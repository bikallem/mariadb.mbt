all: clean fmt info build

build:
	NEW_MOON=1 moon build	

fmt: 
	NEW_MOON=1 moon fmt
	clang-format -i ./**/*.c	

clean:
	NEW_MOON=1 moon clean

check:
	NEW_MOON=1 moon check

info:
	NEW_MOON=1 moon info

.PHONY: all build fmt clean check info