set(functional_test_log_script
    "${CTEST_SOURCE_DIRECTORY}/test/functional/combine_logs.py")
if(NOT EXISTS "${functional_test_log_script}")
    return()
endif()

find_program(functional_test_python NAMES python3 python)
if(NOT functional_test_python)
    message(WARNING "Could not find Python to combine functional test logs")
    return()
endif()

file(GLOB_RECURSE functional_test_framework_logs
    "${functional_ctest_binary_directory}/tmp/*/test_framework.log")
if(NOT functional_test_framework_logs)
    return()
endif()

list(SORT functional_test_framework_logs)
set(functional_test_combined_log
    "${functional_ctest_binary_directory}/functional-test-combined.log")
file(WRITE "${functional_test_combined_log}"
    "Functional test logs combined after a CTest failure.\n\n")

foreach(functional_test_framework_log IN LISTS functional_test_framework_logs)
    get_filename_component(functional_test_directory
        "${functional_test_framework_log}" DIRECTORY)
    get_filename_component(functional_test_name
        "${functional_test_directory}" NAME)
    file(APPEND "${functional_test_combined_log}"
        "===== ${functional_test_name} =====\n")
    execute_process(
        COMMAND
            "${functional_test_python}"
            "${functional_test_log_script}"
            "${functional_test_directory}"
        RESULT_VARIABLE combine_logs_result
        OUTPUT_VARIABLE combine_logs_output
        ERROR_VARIABLE combine_logs_error
    )
    if(combine_logs_result EQUAL 0)
        file(APPEND "${functional_test_combined_log}" "${combine_logs_output}")
    else()
        file(APPEND "${functional_test_combined_log}"
            "combine_logs.py failed with ${combine_logs_result}:\n"
            "${combine_logs_error}\n${combine_logs_output}")
    endif()
    file(APPEND "${functional_test_combined_log}" "\n")
endforeach()

file(GLOB_RECURSE functional_test_node_output_files
    LIST_DIRECTORIES false
    "${functional_ctest_binary_directory}/cache/node*/stderr/*"
    "${functional_ctest_binary_directory}/cache/node*/stdout/*")
if(functional_test_node_output_files)
    list(SORT functional_test_node_output_files)
    file(APPEND "${functional_test_combined_log}"
        "===== Functional cache node output =====\n")
    foreach(functional_test_node_output_file IN LISTS functional_test_node_output_files)
        file(READ "${functional_test_node_output_file}" functional_test_node_output)
        file(APPEND "${functional_test_combined_log}"
            "----- ${functional_test_node_output_file} -----\n"
            "${functional_test_node_output}\n")
    endforeach()
endif()

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
    # Crash reports can be written asynchronously after bitcoind exits.
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 2)
    file(GLOB macos_bitcoind_crash_reports
        LIST_DIRECTORIES false
        "$ENV{HOME}/Library/Logs/DiagnosticReports/bitcoind*.ips"
        "$ENV{HOME}/Library/Logs/DiagnosticReports/bitcoind*.crash")
    if(macos_bitcoind_crash_reports)
        list(SORT macos_bitcoind_crash_reports)
        file(APPEND "${functional_test_combined_log}"
            "===== macOS bitcoind crash reports =====\n")
        foreach(macos_bitcoind_crash_report IN LISTS macos_bitcoind_crash_reports)
            file(READ "${macos_bitcoind_crash_report}" macos_bitcoind_crash_report_text)
            file(APPEND "${functional_test_combined_log}"
                "----- ${macos_bitcoind_crash_report} -----\n"
                "${macos_bitcoind_crash_report_text}\n")
        endforeach()
    endif()
endif()

list(APPEND CTEST_NOTES_FILES "${functional_test_combined_log}")
