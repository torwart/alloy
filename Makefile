# local compiler stuff, change this to your favorite compiler, we recommend clang though
LCC = clang
LCXX = clang++

# local stuff
C_FLAGS = `llvm-config --cflags` -Wall -Iincludes/ -g
LLVM_FLAGS = `llvm-config --system-libs --libs --cflags --ldflags core analysis executionengine jit interpreter native`
LLVM_VERSION = $(shell llvm-config --version | grep ^llvm-version | sed 's/^.* //g')

# travis is a bitch so we setup its own stuff
TRAVIS_LINK_STUFF = `llvm-config --libs --cflags --ldflags core analysis executionengine jit interpreter native`
TRAVIS_FLAGS = -ldl -ltinfo -pthread
 
# detect LLVM flags and do additional tasks if host is Linux
ifeq (("$(LLVM_VERSION)" "3.5" && "$(shell uname -s)" "Linux"),true)
	LLVM_FLAGS = `llvm-config-3.5 --libs --system-libs --cflags --ldflags core analysis executionengine jit interpreter native -lz -lncurses`
endif

# 3.5 seems to need these flags
ifeq "$(LLVM_VERSION)" "3.5"
	LLVM_FLAGS += -lz -lncurses
endif

# where source files are
SOURCES = src/*.c

# build command FOR TRAVIS
BUILD_COMMAND =

# also for TRAVIS
ifeq ($(CC),gcc)
	BUILD_COMMAND = g++ *.o ${TRAVIS_LINK_STUFF} -o alloyc-linux
else
	BUILD_COMMAND = ${CC}++ *.o ${TRAVIS_LINK_STUFF} -o alloyc-linux
endif

# this is what should be built
all: ${SOURCES}
	${LCC} ${C_FLAGS} ${SOURCES} -c ${SOURCES}
	mkdir -p bin
	${LCXX} *.o ${LLVM_FLAGS} -o bin/alloyc 
	-rm *.o

# windows build?
win: ${SOURCES}
	i586-mingw32msvc-gcc ${C_FLAGS} ${SOURCES} -c ${SOURCES}
	mkdir -p bin
	i586-mingw32msvc-g++ *.o ${LLVM_FLAGS} -o bin/alloyc 
	-rm *.o

# this is for TRAVIS ONLY!!
travis: ${SOURCES}
	${CC} ${C_FLAGS} ${SOURCES} -c ${SOURCES}
	${BUILD_COMMAND} ${TRAVIS_FLAGS}
	-rm *.o

# clean stuff up
clean:
	-rm *.o
	-rm bin/alloyc

.PHONY: clean
