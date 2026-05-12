cmake_host_system_information(RESULT nproc QUERY NUMBER_OF_LOGICAL_CORES)
set(CTEST_BUILD_FLAGS -j${nproc})
set(ctest_test_args ${ctest_test_args} PARALLEL_LEVEL ${nproc})

# CTEST_SITE and CTEST_SOURCE_DIRECTORY are provided by the GitHub Actions
# workflow.
include("${CMAKE_CURRENT_LIST_DIR}/set-cdash-build-name.cmake")
get_filename_component(CTEST_SOURCE_DIRECTORY "${CTEST_SOURCE_DIRECTORY}" ABSOLUTE)
set(CTEST_BINARY_DIRECTORY "${CTEST_SOURCE_DIRECTORY}/build")
set(functional_ctest_binary_directory "${CTEST_SOURCE_DIRECTORY}/build-functional-ctest")
find_program(CTEST_GIT_COMMAND git)
set(CTEST_UPDATE_VERSION_ONLY TRUE)
if(DEFINED ENV{CTEST_DASHBOARD_MODEL})
    set(ctest_dashboard_model "$ENV{CTEST_DASHBOARD_MODEL}")
else()
    set(ctest_dashboard_model "Nightly")
endif()

# Include this dashboard script in the submitted CDash notes.
set(CTEST_NOTES_FILES)
list(APPEND CTEST_NOTES_FILES "${CMAKE_CURRENT_LIST_FILE}")

ctest_start("${ctest_dashboard_model}")

# Record the current revision without updating the source tree checked out by
# the workflow.
ctest_update()
ctest_submit(PARTS "Update")

ctest_configure(
    BUILD   ${CTEST_BINARY_DIRECTORY}
    SOURCE  ${CTEST_SOURCE_DIRECTORY}
)
include("${CMAKE_CURRENT_LIST_DIR}/write-build-config-note.cmake")
ctest_submit(PARTS "Configure" "Notes")

ctest_build(BUILD ${CTEST_BINARY_DIRECTORY})
ctest_submit(PARTS "Build")

ctest_test(${ctest_test_args} EXCLUDE "interface_ipc")
ctest_submit(PARTS "Test")

file(MAKE_DIRECTORY "${functional_ctest_binary_directory}")
ctest_configure(
    BUILD   ${functional_ctest_binary_directory}
    SOURCE  "${CMAKE_CURRENT_LIST_DIR}/functional-ctest"
    OPTIONS "-DBITCOIN_BUILD_DIR=${CTEST_BINARY_DIRECTORY}"
)

ctest_test(BUILD ${functional_ctest_binary_directory} APPEND ${ctest_test_args})
ctest_submit(PARTS "Test")

# Submit Done last so CDash marks the build as complete.
ctest_submit(PARTS "Done")
