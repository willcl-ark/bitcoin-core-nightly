if(NOT DEFINED CTEST_BINARY_DIRECTORY)
    message(FATAL_ERROR "CTEST_BINARY_DIRECTORY must be set")
endif()

set(cmake_configure_log "${CTEST_BINARY_DIRECTORY}/CMakeFiles/CMakeConfigureLog.yaml")

if(NOT EXISTS "${cmake_configure_log}")
    message(STATUS "No CMake configure log found at ${cmake_configure_log}")
    return()
endif()

file(READ "${cmake_configure_log}" cmake_configure_log_content)
message("Begin ${cmake_configure_log}")
message("${cmake_configure_log_content}")
message("End ${cmake_configure_log}")
