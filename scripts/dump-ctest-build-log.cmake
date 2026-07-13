if(NOT DEFINED CTEST_BINARY_DIRECTORY)
    message(FATAL_ERROR "CTEST_BINARY_DIRECTORY must be set")
endif()

set(ctest_tag_file "${CTEST_BINARY_DIRECTORY}/Testing/TAG")
if(NOT EXISTS "${ctest_tag_file}")
    message(STATUS "No CTest tag file found at ${ctest_tag_file}")
    return()
endif()

file(STRINGS "${ctest_tag_file}" ctest_tag LIMIT_COUNT 1)
set(ctest_build_log "${CTEST_BINARY_DIRECTORY}/Testing/Temporary/LastBuild_${ctest_tag}.log")

if(NOT EXISTS "${ctest_build_log}")
    message(STATUS "No CTest build log found at ${ctest_build_log}")
    return()
endif()

file(READ "${ctest_build_log}" ctest_build_log_content)
message("Begin ${ctest_build_log}")
message("${ctest_build_log_content}")
message("End ${ctest_build_log}")
