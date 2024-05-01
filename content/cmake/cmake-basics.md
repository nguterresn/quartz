---
title: The basics of CMake
tags:
  - CMake
date: "2024-01-03"
---

### Introduction

CMake is everywhere.

(If you still use Makefile, keep reading, you are missing out in life!)

CMake can look complicated but in fact it is not: has all the complexity of a build system that can build almost anything but, in fact, its use is as simple as it gets.

This is not a complete guide into CMake, but one to get you started. If you want to read more about CMake, I recommend you read more about [Modern CMake](https://cliutils.gitlab.io/modern-cmake/).

### Requirements

To start with CMake, I'd need a `CMakeLists.txt` file like this:

```cmake
cmake_minimum_required(VERSION 3.16.0)
project(test_c)

add_executable(test test.c)
```

And a `test.c` file like this:

```c
#include <stdio.h>

int add(int a, int b)
{
  return a + b;
}

int main()
{
  int a, b;

  printf("Enter number a: ");
  scanf("%d", &a);
  printf("Enter number b: ");
  scanf("%d", &b);

  printf("Adding result -> %d", add(a, b));
}
```

With a project structure as such:

```md
-- CMakeLists.txt
-- test.c
```

The fun thing about CMake is that you only need to run `cmake` once:

```bash
$ mkdir build
$ cmake -B build/
```

This will generate the Makefile inside the `build/` folder.
Next, jump into the directory created and generate the Makefile:

```md
$ cd build
$ make
```

Once this is done, you will end up with something like this:

```md
-- build
  -- Makefile
  -- test
-- CMakeLists.txt
-- test.c
```

Running `make` has generated the `test` executable. Now, run:

```bash
$ ./test
```

Done 👍🏼

---

### Adding libraries

Adding a library is easy. Let's start with this directory structure:

```md
-- CMakeLists.txt
-- test.c
-- /test_lib
  -- test_lib.c
  -- test_lib.h
```

Inside `test.c`:

```c
#include <stdio.h>
#include "test_lib.h"

int add(int a, int b)
{
  return a + b;
}

int main()
{
  int a, b;

  printf("Enter number a: ");
  scanf("%d", &a);
  printf("Enter number b: ");
  scanf("%d", &b);

  printf("Mux result -> %d", mux(a, b)); // Uses `mux` method
}
```

Inside `test_lib.h`:

```c
int mux (int a, int b);
```

Inside `test_lib.c`:

```c
#include "test_lib.h"

int mux (int a, int b) {
  return a * b;
}
```

Finally, to add this as library to the executable target `test`, add:

```cmake
cmake_minimum_required(VERSION 3.16.0)
project(test_c)

add_library(test_lib ${CMAKE_CURRENT_SOURCE_DIR}/test_lib/test_lib.c)
target_include_directories(test_lib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/test_lib)

add_executable(test src/test.c)
target_link_libraries(test test_lib)
```

The `add_library` creates a target (test_lib) that points to the `test_lib.c` file and `target_link_libraries` links the `test_lib` target to the executable `test` target.

Hit `$ make` again 👍🏼

### Adding an external library

Imagine the scenario where you have your project and want to include an external library you have seen on Github.

This is your project structure:

```md
CMakeLists.txt
-- /src
  -- test.c
-- /test_lib
  -- test_lib.c
  -- test_lib.h
  -- CMakeLists.txt
```

The folder `src` has the file we want to execute and `test.c` contains the `int main()` function.
The `test_lib` folder contains one executable file, one header and one CMakeLists.txt.

Inside `test_lib/CMakeLists.txt` we have the following:

```cmake
# The library `test_lib` should ideally be one step below
set(TEST_LIB_PATH ${CMAKE_CURRENT_SOURCE_DIR})

# Set it up as a library.
add_library(test_lib ${TEST_LIB_PATH}/test_lib.c)

# Turn it into a searchable field in PUBLIC. This means any target that includes
# this library is capable of looking for the directory passed below.
target_include_directories(test_lib PUBLIC ${TEST_LIB_PATH})
```

There, the library is created and placed under a PUBLIC inheritance. If you don't know which inheritance to choose, leave it blank and CMake will default it to PUBLIC.
Nevertheless, this is a library you just downloaded and want to include it inside you project. The magic happens in the root CMakeLists.txt:

```cmake
cmake_minimum_required(VERSION 3.16.0)
project(
  test_c
  VERSION 1.0
  DESCRIPTION "An example project with CMake"
  LANGUAGES C
)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

add_executable(test ${CMAKE_CURRENT_SOURCE_DIR}/src/test.c)

add_subdirectory(test_lib)
target_link_libraries(test PRIVATE test_lib)

add_custom_command(
  TARGET test
  POST_BUILD
  COMMENT "Running ./test"
  COMMAND ./test
)
```

You can easily add the external library by calling `add_subdirectory` and the target library name you've created in `test_lib/CMakeLists.txt` as an argument. Once you add the subdirectory, you need to link it to the executable target, `test`. You can link it as PRIVATE since you won't share this subdirectory anywhere else.

Finally, instead of runnning `$ make` and then `$ ./test`, you can ask CMake to do that for you by using the `add_custom_command` method. As an argument of `add_custom_command`, add `COMMAND` followed by the command you want to run.
The `POST_BUILD` keyword makes sure the command will only run after building the code.

Hit `$ make` 👍🏼
