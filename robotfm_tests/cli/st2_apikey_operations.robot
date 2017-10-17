*** Variables ***

*** Test Cases ***
TEST:Verify load command works and is idempotent
    # Create two api keys
    ${result}=           Run  st2 apikey create
    Log To Console       \nCREATE APIKEY:\n
    Log To Console       \nRESULT:\n: ${result}
    Should Contain       ${result}  key
    Should Contain       ${result}  created_at

    ${result}=           Run  st2 apikey create
    Log To Console       \nCREATE APIKEY:\n
    Log To Console       \nRESULT:\n: ${result}
    Should Contain       ${result}  key
    Should Contain       ${result}  created_at

    # Dump the keys and load them twice - operation should be idempotent and existing keys should be updated
    ${result}=           Run  st2 apikey list -d --show-secrets -j > /tmp/apikeys.json

    ${result}=           Run  st2 apikey list | wc -l
    Set Suite Variable   ${APIKEY COUNT}  ${result}
    Log To Console       \nKEY LIST COUNT:\n
    Log To Console       \nRESULT:\n
    Log To Console       \n${result}

    ${result}=           Run  st2 apikey load /tmp/apikeys.json
    Log To Console       \nRUN st2 apikey load:\n
    Log To Console       \nRESULT:\n
    Log To Console       \n${result}

    # Verify count is correct / same after load
    ${result}=           Run  st2 apikey list | wc -l
    Should Be Equal As Integers  ${result}  ${APIKEY COUNT}

    ${result}=           Run  st2 apikey load /tmp/apikeys.json
    Log To Console       \nRUN st2 apikey load:\n
    Log To Console       \nRESULT:\n
    Log To Console       \n${result}

    # Verify count is correct / same after load
    ${result}=           Run  st2 apikey list | wc -l
    Should Be Equal As Integers  ${result}  ${APIKEY COUNT}

*** Settings ***
Library         Process
Library         String
Library         OperatingSystem
Resource        ../common/keywords.robot
