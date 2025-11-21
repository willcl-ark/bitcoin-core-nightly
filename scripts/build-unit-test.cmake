if(NOT DEFINED WITH_UPDATE)
  set(WITH_UPDATE FALSE)
endif()
if(NOT DEFINED MODEL)
  set(MODEL "Experimental")
endif()

cmake_host_system_information(RESULT HOST_NAME QUERY HOSTNAME)
set(CTEST_SITE ${HOST_NAME})

cmake_host_system_information(RESULT nproc QUERY NUMBER_OF_LOGICAL_CORES)
if(NOT nproc)
  message(WARNING "Could not determine number of logical cores; defaulting to 1.")
  set(nproc 1)
endif()

if(NOT CTEST_BUILD_NAME)
  set(CTEST_BUILD_NAME "${CMAKE_HOST_SYSTEM_PROCESSOR}_${CMAKE_SYSTEM_NAME}-nix")
endif()
if(NOT CTEST_SOURCE_DIRECTORY)
  set(CTEST_SOURCE_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}")
endif()
if(NOT CTEST_BINARY_DIRECTORY)
  set(CTEST_BINARY_DIRECTORY "${CTEST_SOURCE_DIRECTORY}/build")
endif()

set(CTEST_CMAKE_GENERATOR "Ninja")
set(CTEST_NOTES_FILES "${CTEST_SOURCE_DIRECTORY}/CMakeLists.txt")

find_program(CTEST_GIT_COMMAND "git")
if(WITH_UPDATE AND NOT CTEST_GIT_COMMAND)
  message(WARNING "Git not found; skipping update.")
  set(WITH_UPDATE FALSE)
endif()

ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})

ctest_start(${MODEL})

if(WITH_UPDATE AND CTEST_GIT_COMMAND)
  ctest_update()
endif()

ctest_configure()

ctest_build(PARALLEL_LEVEL ${nproc})

ctest_test(PARALLEL_LEVEL ${nproc})

ctest_submit()
