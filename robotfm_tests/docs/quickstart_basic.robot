*** Variables ***
${CORE LOCAL}       "ref": "core.local"
${CORE REMOTE}      "ref": "core.remote"
${CORE HTTP}        "ref": "core.http"
${SUCCESS STATUS}   "status": "succeeded"
${PACK LINUX}       "pack": "linux"
${PACK CORE}        "pack": "core"

*** Test Cases ***
TEST:Verify st2 version and usage / help
    ${result}=       Run Process       st2  --version
    Log To Console   \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
    Should Contain   ${result.stderr}  st2
    ${result}=       Run Process       st2
    Log To Console   \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
    Should Contain   ${result.stderr}  usage
    Should Contain   ${result.stderr}  CLI for StackStorm event-driven automation platform.
    Should Contain   ${result.stderr}  Enable debug mode
    ${result}=       Run Process       st2  -h
    Log To Console   \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
    Should Contain   ${result.stdout}  usage
    Should Contain   ${result.stdout}  CLI for StackStorm event-driven automation platform.
    Should Contain   ${result.stdout}  Enable debug mode

TEST:Verify action list for core.local and core.remote action
    ${result}=       Run Process        st2  action  list  -j  --pack\=core
    Process Log To Console             ${result}
    Should Contain   ${result.stdout}   ${CORE LOCAL}
    Should Contain   ${result.stdout}   ${CORE REMOTE}

TEST:Verify core.http action
    ${result}=       Run Process       st2  action  get  -j  core.http
    Process Log To Console             ${result}
    Should Contain   ${result.stdout}  ${CORE HTTP}
    Should Contain   ${result.stdout}  "runner_type": "http-request"
    Should Contain   ${result.stdout}  "uid": "action:core:http"

TEST:Run core.local's "date" action and check execution list
    ${result}=       Run Process       st2  run  -j  core.local  --  date  -R
    Process Log To Console             ${result}
    Should Contain   ${result.stdout}  ${SUCCESS STATUS}
    Should Contain   ${result.stdout}  "cmd": "date -R"
    ${result}=       Wait Until Keyword Succeeds  2s  1s  KEYWORD:Execution List
    Process Log To Console             ${result}

TEST:Verify sensor list and trigger list
    ${result}=       Run Process       st2  sensor  list  -j
    Process Log To Console             ${result}
    Should Contain   ${result.stdout}  ${PACK LINUX}
    ${result}=       Run Process       st2  trigger  list  -j  -a\=all
    # Process Log To Console             ${result}
    Should Contain   ${result.stdout}  ${PACK CORE}
    @{instance id}   Split String      ${result.stdout}    separator="
    Log To Console   \nINSTANCE ID: @{instance id}[7]\n
    ${result}=       Run Process       st2  trigger  get  -j  @{instance id}[7]
    Should Contain   ${result.stdout}  "id": "@{instance id}[7]"

TEST:Verify core.remote action
    ${result}=       Run Process       st2  run  -j  core.remote  hosts\=localhost  --  uname  -a
    Process Log To Console             ${result}
    Should Contain   ${result.stdout}  ${SUCCESS STATUS}
    Should Contain   ${result.stdout}  "cmd": "uname -a"
    Should Contain   ${result.stdout}  "hosts": "localhost"

*** Keywords ***
KEYWORD: Execution List
    ${result}=       Run Process       st2  execution  list  -n  1  -j
    Should Contain   ${result.stdout}  ${SUCCESS STATUS}
    Should Contain   ${result.stdout}  ${CORE LOCAL}
    [return]         ${result}

*** Settings ***
Library            Process
Library            String
Resource           ../common/keywords.robot
