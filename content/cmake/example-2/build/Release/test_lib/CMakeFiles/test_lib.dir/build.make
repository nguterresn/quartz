# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.29

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /opt/homebrew/Cellar/cmake/3.29.2/bin/cmake

# The command to remove a file.
RM = /opt/homebrew/Cellar/cmake/3.29.2/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /Users/nunonogueira/quartz/content/cmake/example-2

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /Users/nunonogueira/quartz/content/cmake/example-2/build/Release

# Include any dependencies generated for this target.
include test_lib/CMakeFiles/test_lib.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include test_lib/CMakeFiles/test_lib.dir/compiler_depend.make

# Include the progress variables for this target.
include test_lib/CMakeFiles/test_lib.dir/progress.make

# Include the compile flags for this target's objects.
include test_lib/CMakeFiles/test_lib.dir/flags.make

test_lib/CMakeFiles/test_lib.dir/test_lib.c.o: test_lib/CMakeFiles/test_lib.dir/flags.make
test_lib/CMakeFiles/test_lib.dir/test_lib.c.o: /Users/nunonogueira/quartz/content/cmake/example-2/test_lib/test_lib.c
test_lib/CMakeFiles/test_lib.dir/test_lib.c.o: test_lib/CMakeFiles/test_lib.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green --progress-dir=/Users/nunonogueira/quartz/content/cmake/example-2/build/Release/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building C object test_lib/CMakeFiles/test_lib.dir/test_lib.c.o"
	cd /Users/nunonogueira/quartz/content/cmake/example-2/build/Release/test_lib && /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -MD -MT test_lib/CMakeFiles/test_lib.dir/test_lib.c.o -MF CMakeFiles/test_lib.dir/test_lib.c.o.d -o CMakeFiles/test_lib.dir/test_lib.c.o -c /Users/nunonogueira/quartz/content/cmake/example-2/test_lib/test_lib.c

test_lib/CMakeFiles/test_lib.dir/test_lib.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green "Preprocessing C source to CMakeFiles/test_lib.dir/test_lib.c.i"
	cd /Users/nunonogueira/quartz/content/cmake/example-2/build/Release/test_lib && /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /Users/nunonogueira/quartz/content/cmake/example-2/test_lib/test_lib.c > CMakeFiles/test_lib.dir/test_lib.c.i

test_lib/CMakeFiles/test_lib.dir/test_lib.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green "Compiling C source to assembly CMakeFiles/test_lib.dir/test_lib.c.s"
	cd /Users/nunonogueira/quartz/content/cmake/example-2/build/Release/test_lib && /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /Users/nunonogueira/quartz/content/cmake/example-2/test_lib/test_lib.c -o CMakeFiles/test_lib.dir/test_lib.c.s

# Object files for target test_lib
test_lib_OBJECTS = \
"CMakeFiles/test_lib.dir/test_lib.c.o"

# External object files for target test_lib
test_lib_EXTERNAL_OBJECTS =

test_lib/libtest_lib.a: test_lib/CMakeFiles/test_lib.dir/test_lib.c.o
test_lib/libtest_lib.a: test_lib/CMakeFiles/test_lib.dir/build.make
test_lib/libtest_lib.a: test_lib/CMakeFiles/test_lib.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green --bold --progress-dir=/Users/nunonogueira/quartz/content/cmake/example-2/build/Release/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking C static library libtest_lib.a"
	cd /Users/nunonogueira/quartz/content/cmake/example-2/build/Release/test_lib && $(CMAKE_COMMAND) -P CMakeFiles/test_lib.dir/cmake_clean_target.cmake
	cd /Users/nunonogueira/quartz/content/cmake/example-2/build/Release/test_lib && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/test_lib.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
test_lib/CMakeFiles/test_lib.dir/build: test_lib/libtest_lib.a
.PHONY : test_lib/CMakeFiles/test_lib.dir/build

test_lib/CMakeFiles/test_lib.dir/clean:
	cd /Users/nunonogueira/quartz/content/cmake/example-2/build/Release/test_lib && $(CMAKE_COMMAND) -P CMakeFiles/test_lib.dir/cmake_clean.cmake
.PHONY : test_lib/CMakeFiles/test_lib.dir/clean

test_lib/CMakeFiles/test_lib.dir/depend:
	cd /Users/nunonogueira/quartz/content/cmake/example-2/build/Release && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/nunonogueira/quartz/content/cmake/example-2 /Users/nunonogueira/quartz/content/cmake/example-2/test_lib /Users/nunonogueira/quartz/content/cmake/example-2/build/Release /Users/nunonogueira/quartz/content/cmake/example-2/build/Release/test_lib /Users/nunonogueira/quartz/content/cmake/example-2/build/Release/test_lib/CMakeFiles/test_lib.dir/DependInfo.cmake "--color=$(COLOR)"
.PHONY : test_lib/CMakeFiles/test_lib.dir/depend

