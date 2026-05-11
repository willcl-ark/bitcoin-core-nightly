cmake_host_system_information(RESULT nproc QUERY NUMBER_OF_LOGICAL_CORES)
set(CTEST_BUILD_FLAGS -j${nproc})
set(ctest_test_args ${ctest_test_args} PARALLEL_LEVEL ${nproc})

# CTEST_SITE and CTEST_SOURCE_DIRECTORY are provided by the GitHub Actions
# workflow.
include("${CMAKE_CURRENT_LIST_DIR}/set-cdash-build-name.cmake")
set(CTEST_BINARY_DIRECTORY "${CTEST_SOURCE_DIRECTORY}/build")
find_program(CTEST_GIT_COMMAND git)
set(CTEST_UPDATE_VERSION_ONLY TRUE)

# Include this dashboard script in the submitted CDash notes.
set(CTEST_NOTES_FILES "${CMAKE_CURRENT_LIST_FILE}")

ctest_start("Nightly")
ctest_submit(PARTS "Notes")

# Record the current revision without updating the source tree checked out by
# the workflow.
ctest_update()
ctest_submit(PARTS "Update")

ctest_configure(
    BUILD   ${CTEST_BINARY_DIRECTORY}
    SOURCE  ${CTEST_SOURCE_DIRECTORY}
)
ctest_submit(PARTS "Configure")

ctest_build(BUILD ${CTEST_BINARY_DIRECTORY})
ctest_submit(PARTS "Build")

ctest_test(${ctest_test_args} EXCLUDE "interface_ipc")
ctest_submit(PARTS "Test")

# Submit Done last so CDash marks the build as complete.
ctest_submit(PARTS "Done")
