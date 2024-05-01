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
