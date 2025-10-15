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

debug: clean
	MOON_CC="gcc -g -O0 -fno-omit-frame-pointer" moon build

asan: clean
	MOON_CC="clang -g -O1 -fsanitize=address -fno-omit-frame-pointer" moon build
	ASAN_OPTIONS="detect_leaks=1:log_path=asan.log:atexit=1" \
	./target/native/release/build/examples/contacts/contacts.exe

valgrind: clean
	MOON_CC="clang -g -O1 -fno-omit-frame-pointer" moon build	
	valgrind --leak-check=full \
	--show-leak-kinds=all \
	--track-origins=yes \
	--log-file=valgrind.log \
	--track-origins=yes \
	./target/native/release/build/examples/contacts/contacts.exe

.PHONY: all build fmt clean check info debug asan valgrind