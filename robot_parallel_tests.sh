#!/bin/bash

## NOTE: SUITES can be a directory or a test file
## SUITES can also include optional params provided by pabot like "--processes <integer>"
## Execution example: bash /tmp/st2tests/robot_parallel_tests.sh '--processes 4 robotfm_tests/cli/ robotfm_tests/demo_st2_robotfm_test.rst' 0
SUITES=$1
VERBOSE=$2

elapsed_time()
{
    echo -e "$result" | grep -i -e "Elapsed time"
}

verbose_output()
{
    if [[ "${VERBOSE}" -eq "1" ]];then
        cat pabot_results/*/stdout.txt
    else
        for filename in pabot_results/*/
        do
            echo -e "\nExecuting: ${filename:14}\n"
            if grep -q "| FAIL |" "$filename/stdout.txt";then
                cat "$filename/stdout.txt"
            fi
        done
    fi
}

main()
{
    echo -e "Running Robot tests in parallel at: "$(pwd)"\n"

    if [ "${VERBOSE}" -eq "1" ]; then
        pabot_command="pabot --verbose ${SUITES}"
    else
        pabot_command="pabot ${SUITES}"
    fi

    result=$(eval $pabot_command) 2>&1

    if [[ $? -eq 0 ]]; then
        if [[ "$result" =~ "does not exist" ]]; then
            echo "Error: Check the Suites Name: ${SUITES} or it is some pabot exception"
            exit 3
        fi
        echo "$result" | grep -iv "Elapsed time"
        elapsed_time
        echo "#################################"
        echo "Robot Tests Executed Successfully"
        echo "#################################"
        verbose_output
        exit 0
    else
        echo "##################"
        echo "Robot Tests Failed"
        echo "##################"
        echo "$result" | grep -i -e "Execution failed" -e "FAILED"
        elapsed_time
        echo "Logs:"
        echo "#####"
        verbose_output
        exit 2
    fi
}

main
