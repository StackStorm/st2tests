*** Variables ***
${SLEEP}             20
${SUCCESS STATUS}    "status": "succeeded
${RUNNING STATUS}    "status": "running
${CANCELING STATUS}  "status": "canceling"
${CANCELED STATUS}   "status": "canceled"
${FAILED STATUS}     "status": "failed"

*** Test Cases ***
TEST:Run examples.mistral-test-cancel
    ${result}=           Run Process  st2  run  examples.mistral-test-cancel  sleep\=${SLEEP}  -j  -a
    @{Execution ID}      Split String  ${result.stdout}
    Set Suite Variable   @{Execution ID}
    Log To Console       \nRUN EXECUTION:\n
    Process Log To Console  ${result}
    Log To Console       EXECUTION ID: @{Execution ID}[-1]\n

TEST:Get Execution Result
    Sleep  2s
    ${result}=  Wait Until Keyword Succeeds  10s  1s  KEYWORD:Execution Result
    Log To Console      \nGET EXECUTION:\n
    Process Log To Console  ${result}

TEST:Cancel examples.mistral-test-cancel
    Sleep  4s
    ${result}=  Wait Until Keyword Succeeds  10s  1s  KEYWORD:Execution Cancel
    Log To Console       \nEXECUTION CANCEL:\n
    Process Log To Console  ${result}

TEST:Check Canceled Execution
    Sleep  4s
    ${Sleep}=   Evaluate  ${SLEEP}+10
    ${result}=  Wait Until Keyword Succeeds  ${Sleep}s  1s         KEYWORD:Canceled Execution
    Log To Console       \nGET EXECUTION AFTER CANCELLATION:\n
    Process Log To Console  ${result}

TEST:Executed successfully examples.mistral-test-cancel
    Sleep  2s
    ${Sleep}=   Evaluate  ${SLEEP}+10
    ${result}=  Wait Until Keyword Succeeds  ${Sleep}s  1s  KEYWORD:Final Execution
    Log To Console       \nGET EXECUTION AFTER COMPLETION:\n
    Process Log To Console  ${result}

*** Keywords ***
KEYWORD:Execution Result
    ${result}=          Run Process  st2  execution  get  @{Execution ID}[-1]  -j
    Should Contain      ${result.stdout}  ${RUNNING STATUS}
    [return]            ${result}

KEYWORD:Execution Cancel
    ${result}=           Run Process  st2  execution  cancel  @{Execution ID}[-1]  -j
    Should Contain  ${result.stdout}   action execution with id @{Execution ID}[-1] canceled.
    [return]             ${result}

KEYWORD:Canceling Execution
     ${result}=           Run Process  st2  execution  get  @{Execution ID}[-1]      -j
     Should Contain       ${result.stdout}  ${RUNNING STATUS}
     Should Contain       ${result.stdout}  ${CANCELING STATUS}
     [return]             ${result}

KEYWORD:Canceled Execution
     ${result}=           Run Process  st2  execution  get  @{Execution ID}[-1]      -j
     Should Contain       ${result.stdout}  ${SUCCESS STATUS}
     Should Contain       ${result.stdout}  ${CANCELED STATUS}
     [return]             ${result}

KEYWORD:Final Execution
     ${result}=           Run Process  st2  execution  get  @{Execution ID}[-1]       -j
     Should Contain       ${result.stdout}  ${CANCELED STATUS}
     Should Contain       ${result.stdout}  ${SUCCESS STATUS}
     Should Not Contain   ${result.stdout}  ${RUNNING STATUS}
     [return]             ${result}

*** Settings ***
Library         Process
Library         String
Library         OperatingSystem
Resource        ../common/keywords.robot
Suite Setup     SETUP:Copy and Load Examples Pack
Suite Teardown  TEARDOWN:Uninstall Examples Pack
