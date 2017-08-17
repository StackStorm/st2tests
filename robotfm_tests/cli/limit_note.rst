.. code:: robotframework

    *** Variables ***
    ${EXECUTION LIST}         st2 execution list
    ${RULE LIST}              st2 rule list
    ${TRACE LIST}             st2 trace list
    ${KEY LIST}               st2 key list
    ${TRIGGERINSTANCE LIST}   st2 trigger-instance list
    ${RULEENFORCEMENT LIST}   st2 rule-enforcement list
    ${SINGLE LIMIT NOTE 1}    Note: Only one
    ${SINGLE LIMIT NOTE 2}    is displayed. Use -n/--last flag for more results
    ${DEFAULT LIMIT NOTE 1}   Note: Only first 50
    ${DEFAULT LIMIT NOTE 2}   are displayed. Use -n/--last flag for more results.


    *** Test Cases ***
    Verify default note in the execution, trace, trigger-instance, rule and rule-enforcement list
        ${count}=        Run  ${EXECUTION LIST} | grep \-c 'stanley'
        Log To Console   \nCOUNT:\n${count}
        ${result}=       Run Keyword If  4>${count}==50   Run Process  st2  execution  list
        Run Keyword If   ${result}  Log To Console   \nEXECUTION LIST:\nSTDOUT:\n${result.stdout}\nSTDERR:\n${result.stderr}
        Run Keyword If   ${result}  Should Contain   ${result.stderr}
        ...              ${DEFAULT LIMIT NOTE 1} action executions ${DEFAULT LIMIT NOTE 2}

        ${count}=        Run  ${TRACE LIST} | grep \-c 'trace:'
        Log To Console   \nCOUNT:\n${count}
        ${result}=       Run Keyword If  4>${count}==50   Run Process  st2  trace  list
        Run Keyword If   ${result}  Log To Console   \nTRACE LIST:\nSTDOUT:\n${result.stdout}\nSTDERR:\n${result.stderr}
        Run Keyword If   ${result}  Should Contain   ${result.stderr}
        ...              ${DEFAULT LIMIT NOTE 1} traces ${DEFAULT LIMIT NOTE 2}

        ${count}=        Run  ${TRIGGERINSTANCE LIST} | grep \-c 'processed'
        Log To Console   \nCOUNT:\n${count}
        ${result}=       Run Keyword If  4>${count}==50   Run Process  st2  trigger-instance  list
        Run Keyword If   ${result}  Log To Console   \nTRIGGER-INSTANCE LIST:\nSTDOUT:\n${result.stdout}\nSTDERR:\n${result.stderr}
        Run Keyword If   ${result}  Should Contain   ${result.stderr}
        ...              ${DEFAULT LIMIT NOTE 1} triggerinstances ${DEFAULT LIMIT NOTE 2}

        ${count}=        Run  ${RULE LIST} \| grep \-c \-e True \-e False
        Log To Console   \nCOUNT:\n${count}
        ${result}=       Run Keyword If   4>${count}==50   Run Process  st2  rule  list
        Run Keyword If   ${result}   Log To Console   \nRULE LIST:\nSTDOUT:\n${result.stdout}\nSTDERR:\n${result.stderr}
        Run Keyword If   ${result}  Should Contain   ${result.stderr}
        ...              ${DEFAULT LIMIT NOTE 1} rules ${DEFAULT LIMIT NOTE 2}

        ${count}=        Run  ${RULEENFORCEMENT LIST} | grep \-c chatops\.notify
        Log To Console   \nCOUNT:\n${count}
        ${result}=       Run Keyword If  4>${count}==50   Run Process  st2  rule-enforcement  list
        Run Keyword If   ${result}   Log To Console   \nRULE-ENFORCEMENT LIST:\nSTDOUT:\n${result.stdout}\nSTDERR:\n${result.stderr}
        Run Keyword If   ${result}  Should Contain   ${result.stderr}
        ...              ${DEFAULT LIMIT NOTE 1} rule enforcements ${DEFAULT LIMIT NOTE 2}

        ${count}=        Run  ${KEY LIST} | grep \-c st2kv.system
        Log To Console   \nCOUNT:\n${count}
        ${result}=       Run Keyword If  4>${count}==50   Run Process  st2  key  list
        Run Keyword If   ${result}   Log To Console   \nKEY LIST:\nSTDOUT:\n${result.stdout}\nSTDERR:\n${result.stderr}
        Run Keyword If   ${result}  Should Contain   ${result.stderr}
        ...              ${DEFAULT LIMIT NOTE 1} key value pairs ${DEFAULT LIMIT NOTE 2}


    Verify note when limit is 1
        ${result}=         Run Process  st2  execution  list  -n  1
        Log To Console     \nEXECUTION LIST:\nSTDOUT:\n${result.stdout}\nSTDERR:\n${result.stderr}
        Should Contain     ${result.stderr}   ${SINGLE LIMIT NOTE 1} action execution
        ...                ${SINGLE LIMIT NOTE 2}

        ${result}=         Run Process  st2  trace  list  -n  1
        Log To Console     \nTRACE LIST:\nSTDOUT:\n${result.stdout}\nSTDERR:${result.stderr}
        Should Contain     ${result.stderr}   ${SINGLE LIMIT NOTE 1} trace ${SINGLE LIMIT NOTE 2}

        ${result}=         Run Process  st2  trigger-instance  list  -n  1
        Log To Console     \nTRIGGER-INSTANCE LIST:\nSTDOUT:\n${result.stdout}\nSTDERR:
        Should Contain     ${result.stderr}   ${SINGLE LIMIT NOTE 1} triggerinstance
        ...                ${SINGLE LIMIT NOTE 2}

        ${result}=         Run Process  st2  rule  list  -n  1
        Log To Console     \nRULE LIST:\nSTDOUT:\n${result.stdout}\nSTDERR:\n${result.stderr}
        Should Contain     ${result.stderr}   ${SINGLE LIMIT NOTE 1} rule ${SINGLE LIMIT NOTE 2}

        ${result}=         Run Process  st2  rule-enforcement  list  -n  1
        Log To Console     \nRULE-ENFORCEMENT LIST:\nSTDOUT:\n${result.stdout}\nSTDERR:\n${result.stderr}
        Should Contain     ${result.stderr}   ${SINGLE LIMIT NOTE 1} rule enforcement
        ...                ${SINGLE LIMIT NOTE 2}

        ${result}=         Run Process  st2  key  list  -n  1
        Log To Console     \nKEY LIST:\nSTDOUT:\n${result.stdout}\nSTDERR:\n${result.stderr}
        Should Contain     ${result.stderr}   ${SINGLE LIMIT NOTE 1} key value pair
        ...                ${SINGLE LIMIT NOTE 2}


    Verify no note with json/yaml output
        ${result_1}=       Run Process  st2  execution  list  -n  1  -j
        ${result_2}=       Run Process  st2  execution  list  -n  1  -y
        Log To Console     \nEXECUTION LIST JSON:\nSTDOUT:\n${result_1.stdout}\nSTDERR:\n${result_1.stderr}
        Log To Console     \nEXECUTION LIST YAML:\nSTDOUT:\n${result_2.stdout}\nSTDERR:\n${result_2.stderr}
        Should Be Empty    ${result_1.stderr}
        Should Be Empty    ${result_2.stderr}

        ${result_1}=       Run Process  st2  trace  list  -n  1  -j
        ${result_2}=       Run Process  st2  trace  list  -n  1  -y
        Log To Console     \nTRACE LIST JSON:\nSTDOUT:\n${result_1.stdout}\nSTDERR:\n${result_1.stderr}
        Log To Console     \nTRACE LIST YAML:\nSTDOUT:\n${result_2.stdout}\nSTDERR:\n${result_2.stderr}
        Should Be Empty    ${result_1.stderr}
        Should Be Empty    ${result_2.stderr}


        ${result_1}=       Run Process  st2  trigger-instance  list  -n  1  -j
        ${result_2}=       Run Process  st2  trigger-instance  list  -n  1  -y
        Log To Console     \nTRIGGER-INSTANCE LIST JSON:\nSTDOUT:\n${result_1.stdout}\nSTDERR:\n${result_1.stderr}
        Log To Console     \nTRIGGER-INSTANCE LIST YAML:\nSTDOUT:\n${result_2.stdout}\nSTDERR:\n${result_2.stderr}
        Should Be Empty    ${result_1.stderr}
        Should Be Empty    ${result_2.stderr}

        ${result_1}=       Run Process  st2  rule  list  -n  1  -j
        ${result_2}=       Run Process  st2  rule  list  -n  1  -y
        Log To Console     \nRULE LIST JSON:\nSTDOUT:\n${result_1.stdout}\nSTDERR:\n${result_1.stderr}
        Log To Console     \nRULE LIST YAML:\nSTDOUT:\n${result_2.stdout}\nSTDERR:\n${result_2.stderr}
        Should Be Empty    ${result_1.stderr}
        Should Be Empty    ${result_2.stderr}

        ${result_1}=       Run Process  st2  rule-enforcement  list  -n  1  -j
        ${result_2}=       Run Process  st2  rule-enforcement  list  -n  1  -y
        Log To Console     \nRULE-ENFORCEMENT LIST JSON:\nSTDOUT:\n${result_1.stdout}\nSTDERR:\n${result_1.stderr}
        Log To Console     \nRULE-ENFORCEMENT LIST YAML:\nSTDOUT:\n${result_2.stdout}\nSTDERR:\n${result_2.stderr}
        Should Be Empty    ${result_1.stderr}
        Should Be Empty    ${result_2.stderr}

        ${result_1}=       Run Process  st2  key  list  -n  1  -j
        ${result_2}=       Run Process  st2  key  list  -n  1  -y
        Log To Console     \nKEY LIST JSON:\nSTDOUT:\n${result_1.stdout}\nSTDERR:\n${result_1.stderr}
        Log To Console     \nKEY LIST YAML:\nSTDOUT:\n${result_2.stdout}\nSTDERR:\n${result_2.stderr}
        Should Be Empty    ${result_1.stderr}
        Should Be Empty    ${result_2.stderr}

    *** Settings ***
    Library            Process
    Library            OperatingSystem
