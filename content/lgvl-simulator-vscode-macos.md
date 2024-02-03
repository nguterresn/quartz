---
title:  How to simulate LGVL using SDL2 on VSCode (MacOS)
date: "2024-01-08"
---

### Introduction

I've started 2024 looking for new technologies to explore and there was one I had in mind to explore a bit, the [LGVL](https://lvgl.io) library, a open-source graphics library for embedded systems.

When I started looking into the documentation about the simulator in VSCode, I noticed there was no clear documentation on how to run the simulator on macOS. After following the [first steps](https://github.com/lvgl/lv_port_pc_vscode) and triying to build the code, I end up having no success on the last. The code didn't build.

In order to find what was missing on my side, I decided to run a simple [SDL minimal project](https://gist.github.com/haxpor/c9f4870947eacfb5e974d8f5c33e5a03) and noticed the following line was NOT present in the previous repository Makefile:

```zsh
`sdl2-config --cflags --libs`
```

This line will expose the C Flags and the library path, which are necesary for a successful build of the project.

```zsh
-I/opt/homebrew/include/SDL2 -D_THREAD_SAFE
-L/opt/homebrew/lib -lSDL2
```

---

### Steps

a. Install [**SDL2**](https://formulae.brew.sh/formula/sdl2):

```console
foo@bar:~$ brew install sdl2
```

b. Find **SDL2** paths:

```console
foo@bar:~$ brew ls SDL2
```

It will print something like this:

```zsh
/opt/homebrew/Cellar/sdl2/2.28.5/bin/sdl2-config
/opt/homebrew/Cellar/sdl2/2.28.5/include/SDL2/ (78 files)
/opt/homebrew/Cellar/sdl2/2.28.5/lib/libSDL2-2.0.0.dylib
/opt/homebrew/Cellar/sdl2/2.28.5/lib/cmake/ (2 files)
/opt/homebrew/Cellar/sdl2/2.28.5/lib/pkgconfig/sdl2.pc
/opt/homebrew/Cellar/sdl2/2.28.5/lib/ (4 other files)
/opt/homebrew/Cellar/sdl2/2.28.5/share/aclocal/sdl2.m4
```

c. Add the include SDL2 path to the Makefile:

```Makefile
INC := -I./ui/simulator/inc/ -I./ -I./lvgl/ -I/opt/homebrew/Cellar/sdl2/2.28.5/include/SDL2
```

d. Include the SDL2 library and respective C flags, by adding `sdl2-config --cflags --libs`:

```Makefile
$(BIN): $(OBJECTS)
  @mkdir -p $(BIN_DIR)
  $(CC) -o $(BIN) $(OBJECTS) $(LDFLAGS) ${LDLIBS} `sdl2-config --cflags --libs`
```

e. Change the `main.c` include `#include <SDL2/SDL.h>` to `#include <SDL.h>`.

f. Run `make` 🤝

---

#### Other

I've created a [PR](https://github.com/lvgl/lv_port_pc_vscode/pull/32) to merge this info to the main branch.

There is also another [PR](https://github.com/lvgl/lv_port_pc_vscode/pull/14) which adds support for CMake on MacOS.


