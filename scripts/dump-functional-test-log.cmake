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

list(APPEND CTEST_NOTES_FILES "${functional_test_combined_log}")
