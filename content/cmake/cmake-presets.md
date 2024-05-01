---
title: How to use CMake Presets with a custom Command Line Interface
tags:
  - CMake
date: "2024-05-01"
---

In the [last article about CMake](cmake-for-embedded.md) I've explained how to use CMake for embedded software development and how to use, for example, an external toolchain.

This time, I'm going to write about how can you automate CMake for your own needs.
The [CMake Presets](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html) is a very powerful — and readable — tool for CMake.

## Creating a minimal CMake Preset from a simple CMake example

I'm using the same application code I've used before. In short, it has a `main.c` and a _library_ named `test_lib` with a respective `test_lib.c` and `test_lib.h`.

The root `CMakeLists.txt` is written as following:

```cmake
cmake_minimum_required(VERSION 3.23)
project(
  test_c
  VERSION 2.0
  DESCRIPTION "Another example project with CMake"
  LANGUAGES C
)

add_executable(test ${CMAKE_SOURCE_DIR}/src/test.c)

add_subdirectory(test_lib)
target_link_libraries(test PRIVATE test_lib)
```

The executable target is named `test`.

The `test_lib` library `CMakeLists.txt` is written as following:

```cmake
set(TEST_LIB_PATH ${CMAKE_CURRENT_SOURCE_DIR})

add_library(test_lib ${TEST_LIB_PATH}/test_lib.c)
target_include_directories(test_lib PUBLIC ${TEST_LIB_PATH})
```

A CMake preset can be simply added by creating the file `CMakePresets.json` in the root directory of the project.

A _minimal_ `CMakePresets.json` might look like this:

```cmake
{
  "version": 6,
  "cmakeMinimumRequired": {
    "major": 3,
    "minor": 23,
    "patch": 0
  },
  "configurePresets": [
    {
      "name": "default",
      "displayName": "Default Configure Preset",
      "generator": "Unix Makefiles",
      "binaryDir": "${sourceDir}/build",
    }
  ],
  "buildPresets": [
    {
      "name": "default",
      "displayName": "Default Build Preset",
      "configurePreset": "default",
      "jobs": 8,
      "targets": "test"
    }
  ]
}
```

There is a `default` configure preset and a `default` build preset. Essentially, this is minimum required to take advantage from the CMake preset feature.

I've decided to define the target inside the preset, but it can also be done as usual.

## Test your CMake Preset

To run a configure preset, run on the shell:

```shell
cmake --preset default
```

This will create the Makefiles inside the `/build` directory, defined by the field `binaryDir`.

To run a build preset, do the same as above but add the keyword `--build` before the `--preset`:

```shell
cmake --build --preset default
```

This will automatically build the binary and store it in `/build`.

## Different presets for different build types

The most popular build types are _debug_ and _release_.
To have a preset with a pre-defined build type, change `CMAKE_BUILD_TYPE` inside the `cacheVariables` configure preset variable to match your desired build type. The `configuration` inside the build preset should also match the build type.

```cmake
{
  "version": 6,
  "cmakeMinimumRequired": {
    "major": 3,
    "minor": 23,
    "patch": 0
  },
  "configurePresets": [
    {
      "name": "default",
      "displayName": "Default Configure Preset",
      "generator": "Unix Makefiles",
      "binaryDir": "${sourceDir}/build",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Debug"
      }
    }
  ],
  "buildPresets": [
    {
      "name": "default",
      "displayName": "Default Build Preset",
      "configurePreset": "default",
      "configuration": "Debug",
      "jobs": 8,
      "targets": "test"
    }
  ]
}
```

The preset above will configure and build with the build type Debug.

Furthermore, to support the _release_ build type, you only need to include two more presets:

```cmake
{
  "version": 6,
  "cmakeMinimumRequired": {
    "major": 3,
    "minor": 23,
    "patch": 0
  },
  "configurePresets": [
    {
      "name": "debug",
      "displayName": "Debug Configure Preset",
      "generator": "Unix Makefiles",
      "binaryDir": "${sourceDir}/build",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Debug"
      }
    },
    {
      "name": "release",
      "displayName": "Release Configure Preset",
      "generator": "Unix Makefiles",
      "binaryDir": "${sourceDir}/build",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Release"
      }
    }
  ],
  "buildPresets": [
    {
      "name": "debug",
      "displayName": "Default Build Preset",
      "configurePreset": "debug",
      "configuration": "Debug",
      "jobs": 8,
      "targets": "test"
    },
    {
      "name": "release",
      "displayName": "Default Build Preset",
      "configurePreset": "release",
      "configuration": "Release",
      "jobs": 8,
      "targets": "test"
    }
  ]
}
```

The preset file above includes two configure presets and two build presets, each one for a different build type.

> [!info]
>
> Note that the field `configurePreset` was also changed and it should match a existing configure preset.

You can try configuring and building for the two build types by running:

```shell
cmake --preset debug
cmake --build --preset debug
```

Or for _release_:

```shell
cmake --preset release
cmake --build --preset release
```

## Include a workflow

The next step of your CMake preset file is to include a workflow preset. A workflow is basically a bunch of steps you want CMake to execute. Since you already configured and built, you might want to group that into ONE only command — that's where the workflow shines.

A workflow preset might look like this:

```cmake
{
  "version": 6,
  "cmakeMinimumRequired": {
    "major": 3,
    "minor": 23,
    "patch": 0
  },
  "configurePresets": [
    {
      "name": "debug",
      "displayName": "Debug Configure Preset",
      "generator": "Unix Makefiles",
      "binaryDir": "${sourceDir}/build",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Debug"
      }
    },
    {
      "name": "release",
      "displayName": "Release Configure Preset",
      "generator": "Unix Makefiles",
      "binaryDir": "${sourceDir}/build",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Release"
      }
    }
  ],
  "buildPresets": [
    {
      "name": "debug",
      "displayName": "Default Build Preset",
      "configurePreset": "debug",
      "configuration": "Debug",
      "jobs": 8,
      "targets": "test"
    },
    {
      "name": "release",
      "displayName": "Default Build Preset",
      "configurePreset": "release",
      "configuration": "Release",
      "jobs": 8,
      "targets": "test"
    }
  ],
  "workflowPresets": [
    {
      "name": "debug",
      "displayName": "Debug Workflow",
      "steps": [
        {
          "type": "configure",
          "name": "debug"
        },
        {
          "type": "build",
          "name": "debug"
        }
      ]
    },
    {
      "name": "release",
      "displayName": "Release Workflow",
      "steps": [
        {
          "type": "configure",
          "name": "release"
        },
        {
          "type": "build",
          "name": "release"
        }
      ]
    }
  ]
}
```

Try runing the workflow by typing:

```shell
cmake --workflow --preset debug
```

It will configure and build for you. Crazy good! 😁

## Sprinkle CMake with a simple Command Line Interface

If you are like me, you can't be satisfied with the previous result. Even though the commands work as expected, the commands are still too long and most of it could be easily abstracted.

With the help of Python and its libraries, it is possible to create a CLI with the following methods:

- `init`: generates the Makefiles according to a preset
- `build`: builds the code according to a preset
- `workflow`: executes the workflow steps according to a preset
- `run`: executes the binary
- `reset`: deletes the `/build` directory

Create a file (do not include the extension .py) in the root project directory. I've named it `example`.

My `example` file contains:

```python
#!/usr/bin/env python3

import argparse
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("action", help="The action to perform, e.g. init, build, workflow, run, reset")
parser.add_argument("type", nargs='?', const="debug", default="debug", help="The build type to perform, e.g. debug, release")
args = parser.parse_args()

if (args.action == 'init'):
  subprocess.run(["cmake", "--preset", args.type])
elif (args.action == 'build'):
  subprocess.run(["cmake", "--build", "--preset", args.type])
elif (args.action == 'workflow'):
  subprocess.run(["cmake", "--workflow", "--preset", args.type])
elif (args.action == 'run'):
  subprocess.run(["./build/" + args.type + "/test"], shell=True)
elif(args.action == 'reset'):
  subprocess.run(["rm", "-rf", "build"])
```

I've also added the `example` path into the `$PATH` with:

```shell
export PATH=<your/path/here>:$PATH
source ~/.zshrc
```

And finally, to run any command inside the `example`, all you have to do is:

```shell
example <command>
```

If you want to execute your workflow preset, you simply run:

```shell
example workflow
```

> [!info]
>
> The build type is Debug as default.

In case it is a release build:

```shell
example workflow release
```

That's all folks! Not only you ended up with a _2 words command_ to compile your code, but the entire code necessary to reach this result is also easy to understand and to go through. The JSON preset is readable and quite flexible: only a few preset options are necesary to make it work.
