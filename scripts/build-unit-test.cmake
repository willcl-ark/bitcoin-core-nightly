include(ProcessorCount)
ProcessorCount(n)
if(NOT n EQUAL 0)
  set(CTEST_BUILD_FLAGS -j${n})
  set(ctest_test_args ${ctest_test_args} PARALLEL_LEVEL ${n})
endif()

set( CTEST_BINARY_DIRECTORY "${CTEST_SOURCE_DIRECTORY}/build")
set(CTEST_CMAKE_GENERATOR "Ninja")
find_program(CTEST_GIT_COMMAND git)
set(CTEST_UPDATE_VERSION_ONLY TRUE)

# Optionally, set files to upload as "NOTES" for the build
set(CTEST_NOTES_FILES "${CMAKE_CURRENT_LIST_FILE}")

# ctest_start will take the name of the mode like the
# -D command does
ctest_start("Nightly")

# Record the current revision without updating the source tree.
ctest_update()

# Executes the Configure/Generate step
ctest_configure(
    BUILD   ${CTEST_BINARY_DIRECTORY}
    SOURCE  ${CTEST_SOURCE_DIRECTORY}
)

# Execute the build step to capture build information
ctest_build(BUILD ${CTEST_BINARY_DIRECTORY})

# Executing  ctest command
ctest_test(${ctest_test_args} EXCLUDE "interface_ipc")

# Submit Files to CDash
ctest_submit()
