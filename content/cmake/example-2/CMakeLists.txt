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
