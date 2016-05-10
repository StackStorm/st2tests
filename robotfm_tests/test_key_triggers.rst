.. code:: robotframework

    *** Variables ***
    ${KEY}                  robot_key
    ${VALUE}                robot_value
    ${UPDATED VALUE}        new_robot_value
    &{ELEMENTS}             robot2=key5  robot1=key4  1=2
    ${JSON FILE}            robotfm_tests/variables/test_key_triggers.json

    ${TRIGGER KEY CREATE}   core.st2.key_value_pair.create
    ${TRIGGER KEY UPDATE}   core.st2.key_value_pair.update
    ${TRIGGER KEY CHANGE}   core.st2.key_value_pair.value_change
    ${TRIGGER KEY DELETE}   core.st2.key_value_pair.delete
    ${SUCCESS STATUS}       "status": "succeeded
    ${RUNNING STATUS}       "status": "running
    ${CANCELED STATUS}      "status": "canceled"
    ${FAILED STATUS}        "status": "failed"

    *** Test Cases ***
    Verify Key Value Triggers
        Sleep  15s
        ${result}=       Run Process  st2  trigger  list  -p  core  -a ref  -j
        Log To Console   \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        Should Contain   ${result.stdout}   ${TRIGGER KEY CREATE}
        Should Contain   ${result.stdout}   ${TRIGGER KEY UPDATE}
        Should Contain   ${result.stdout}   ${TRIGGER KEY CHANGE}
        Should Contain   ${result.stdout}   ${TRIGGER KEY DELETE}

    Create, Update and Value Change key value pair
        [Template]                 Set and update key
        ${KEY}  ${VALUE}           ${TRIGGER KEY CREATE}
        ${KEY}  ${VALUE}           ${TRIGGER KEY UPDATE}
        ${KEY}  ${UPDATED VALUE}   ${TRIGGER KEY CHANGE}

    Delete a key
        Run Keyword      Delete Key        ${KEY}
        Run Keyword      Check key store actions with trigger instance  ${KEY}  ${UPDATED VALUE}  ${TRIGGER KEY DELETE}

    Load and Delete Key Value pairs from json file
        ${result}=          Run Process        st2  key  load  ${JSON FILE}  -j
        Should Contain      ${result.stdout}   &{ELEMENTS}[robot2]
        Should Contain      ${result.stdout}   &{ELEMENTS}[robot1]
        Should Contain      ${result.stdout}   &{ELEMENTS}[1]
        ${result}=          Run Process        st2  key  list  -j
        Should Contain      ${result.stdout}   &{ELEMENTS}[robot2]
        Should Contain      ${result.stdout}   &{ELEMENTS}[robot1]
        Should Contain      ${result.stdout}   &{ELEMENTS}[1]
        Should Not Contain  ${result.stdout}   key1
        Should Not Contain  ${result.stdout}   key2
        ${result}=          Run Process        st2  key  delete_by_prefix  -p  ro
        Should Contain      ${result.stdout}   Deleted 2 keys\nDeleted key ids: robot1, robot2
        ${result}=          Run Process        st2  key  delete  1  -j
        Should Contain      ${result.stdout}   Resource with id "1" has been successfully deleted.

    Key Value pair operations with expiry
        ${result}=           Run Process       st2  key  set  ${KEY}  ${VALUE}  -l  1  -j
        Should Contain       ${result.stdout}  expire_timestamp
        Should Contain       ${result.stdout}  "name": "${KEY}"
        Should Contain       ${result.stdout}  "value": "${VALUE}"
        ${result}=           Run Process       st2  key  get  ${KEY}  -j
        Should Contain       ${result.stdout}  expire_timestamp
        Should Contain       ${result.stdout}  "name": "${KEY}"
        Should Contain       ${result.stdout}  "value": "${VALUE}"
        Sleep  1m
        ${result}=           Run Process       st2  key  set  list  -j
        Should Not Contain   ${result.stdout}  "name": "${KEY}"
        Should Not Contain   ${result.stdout}  "value": "${VALUE}"



    *** Keywords ***
    Set and update key
        [Arguments]      ${key}  ${value}   ${trigger value}
        ${result}=       Run Process        st2  key  set  ${key}  ${value}  -j
        ${message}=      Convert To Uppercase    ${trigger value}
        Log To Console   \n${message}:\nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}\n
        Should Contain   ${result.stdout}   "name": "${key}"
        Should Contain   ${result.stdout}   "value": "${value}"
        Run Keyword      Check key store actions with trigger instance  ${key}  ${value}  ${trigger value}

    Check key store actions with trigger instance
        [Arguments]      ${key}  ${value}  ${trigger value}
        ${result}=       Run Process       st2  trigger-instance  list  -n  1  -j
        Should Contain   ${result.stdout}  "trigger": "${trigger value}" 
        ${result}=       Run Process       st2  trigger-instance  list  -n  1  -a  id  -j
        @{instance id}   Split String      ${result.stdout}    separator="
        # Log To Console   \nINSTANCE ID: @{instance id}[3]
        ${result}=       Run Process       st2  trigger-instance  get  @{instance id}[3]  -j
        Log To Console   \nTRIGGER-INSTANCE\nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        Should Contain   ${result.stdout}  "name": "${key}"
        Should Contain   ${result.stdout}  "value": "${value}"

    Delete Key
        [Arguments]      ${key}
        ${result}=       Run Process        st2  key  delete  ${key}
        Should Contain   ${result.stdout}    Resource with id "${key}" has been successfully deleted.

    Key Not Found
        [Arguments]      ${key}
        ${result}=       Run Process        st2  key  delete  ${key}
        Should Contain   ${result.stdout}    Key Value Pair "${key}" is not found.

    Check and Delete Key
       ${result}=       Run Process  st2  key  list  -j
       Run Keyword If   "${KEY}" in '''${result.stdout}'''  Delete Key  ${KEY}
       ...       ELSE   Key Not Found  ${KEY}

    *** Settings ***
    Library            Process
    Library            String
    Suite Setup        Check and Delete Key
    Suite Teardown     Check and Delete Key
