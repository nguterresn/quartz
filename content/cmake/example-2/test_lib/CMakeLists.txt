# The library `test_lib` should ideally be one step below
set(TEST_LIB_PATH ${CMAKE_CURRENT_SOURCE_DIR})

# Set it up as a library.
add_library(test_lib ${TEST_LIB_PATH}/test_lib.c)

# Turn it into a searchable field in PUBLIC. This means any target that includes
# this library is capable of looking for the directory passed below.
target_include_directories(test_lib PUBLIC ${TEST_LIB_PATH})
