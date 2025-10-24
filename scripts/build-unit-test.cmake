cmake_host_system_information(RESULT HOST_NAME QUERY HOSTNAME)

include(ProcessorCount)
ProcessorCount(n)
if(NOT n EQUAL 0)
  set(CTEST_BUILD_FLAGS -j${n})
  set(ctest_test_args ${ctest_test_args} PARALLEL_LEVEL ${n})
endif()

set( CTEST_SITE ${HOST_NAME})
if(NOT CTEST_BUILD_NAME)
  set(CTEST_BUILD_NAME "bix-nix-flake")
endif()
if(NOT CTEST_SOURCE_DIRECTORY)
  set( CTEST_SOURCE_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" )
endif()
set( CTEST_BINARY_DIRECTORY "${CTEST_SOURCE_DIRECTORY}/build")
set(CTEST_CMAKE_GENERATOR "Ninja")

# Optionally, set files to upload as "NOTES" for the build
set(CTEST_NOTES_FILES "${CTEST_SOURCE_DIRECTORY}/CMakeLists.txt")

# ctest_start will take the name of the mode like the
# -D command does
ctest_start("Experimental")

# Attempt to pull updates from version control
# ctest_update()

# Executes the Configure/Generate step
ctest_configure(
    BUILD   ${CTEST_BINARY_DIRECTORY}
    SOURCE  ${CTEST_SOURCE_DIRECTORY}
)

# Execute the build step to capture build information
ctest_build(BUILD ${CTEST_BINARY_DIRECTORY})

# Executing  ctest command
ctest_test(${ctest_test_args})

# Submit Files to CDash
ctest_submit()
