#!/bin/bash
SUITES=$1
VERBOSE=$2
GREEN='\033[0;32m'
NC='\033[0m'


elapsed_time()
{
    echo -e "${GREEN}"
    echo -e "$result" | grep -i -e "Elapsed time"
    echo -e "${NC}"
}

verbose_output()
{
    if [ "${VERBOSE}" -eq "1" ]; then
        cat pabot_results/*/stdout.txt
    else
        for filename in pabot_results/*/
        do
            echo -e "\nExecuting: ${filename:14:-1}\n"
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

    result=$(eval $pabot_command)

    if [[ $? -eq 0 ]]; then
        if [[ "$result" =~ "does not exist" ]]; then
            echo "Error: Check the Suites Name: ${SUITES}"
            exit 3
        fi
        echo "$result" | grep -iv "Elapsed time"
        elapsed_time
        echo "#################################"
        echo "Robot Tests Executed Successfully"
        echo "#################################"
        verbose_output
    elif [[ $? -eq 1 ]]; then
        exit 1
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
