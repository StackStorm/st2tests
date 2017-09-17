*** Variables ***
${CORE LOCAL}       "ref": "core.local"
${CORE REMOTE}      "ref": "core.remote"
${CORE HTTP}        "ref": "core.http"
${SUCCESS STATUS}   "status": "succeeded"
${PACK LINUX}       "pack": "linux"
${PACK CORE}        "pack": "core"

*** Test Cases ***
Verify st2 version and help
    ${result}=       Run Process       st2  --version
    Process Log To Console             ${result}
    Should Contain   ${result.stderr}  st2
    ${result}=       Run Process       st2  -h
    Process Log To Console             ${result}
    Should Contain   ${result.stdout}  usage
    Should Contain   ${result.stdout}  CLI for StackStorm event-driven automation platform.
    Should Contain   ${result.stdout}  Enable debug mode

Verify action list for core.local and core.remote action
    ${result}=       Run Process        st2  action  list  -j  --pack\=core
    Process Log To Console             ${result}
    Should Contain   ${result.stdout}   ${CORE LOCAL}
    Should Contain   ${result.stdout}   ${CORE REMOTE}

Verify core.http action
    ${result}=       Run Process       st2  action  get  -j  core.http
    Process Log To Console             ${result}
    Should Contain   ${result.stdout}  ${CORE HTTP}
    Should Contain   ${result.stdout}  "runner_type": "http-request"
    Should Contain   ${result.stdout}  "uid": "action:core:http"

Run core.local's "date" action and check execution list
    ${result}=       Run Process       st2  run  -j  core.local  --  date  -R
    Process Log To Console             ${result}
    Should Contain   ${result.stdout}  ${SUCCESS STATUS}
    Should Contain   ${result.stdout}  "cmd": "date -R"
    ${result}=       Wait Until Keyword Succeeds  2s  1s  Execution List
    Process Log To Console             ${result}

Verify sensor list and trigger list
    ${result}=       Run Process       st2  sensor  list  -j
    Process Log To Console             ${result}
    Should Contain   ${result.stdout}  ${PACK LINUX}
    ${result}=       Run Process       st2  trigger  list  -j  -a\=all
    # Process Log To Console             ${result}
    Should Contain   ${result.stdout}  ${PACK CORE}
    @{instance id}   Split String      ${result.stdout}    separator="
    Log To Console   \nINSTANCE ID: @{instance id}[7]
    ${result}=       Run Process       st2  trigger  get  -j  @{instance id}[7]
    Should Contain   ${result.stdout}  "id": "@{instance id}[7]"

Verify core.remote action
    ${result}=       Run Process       st2  run  -j  core.remote  hosts\=localhost  --  uname  -a
    Process Log To Console             ${result}
    Should Contain   ${result.stdout}  ${SUCCESS STATUS}
    Should Contain   ${result.stdout}  "cmd": "uname -a"
    Should Contain   ${result.stdout}  "hosts": "localhost"

*** Keywords ***
Execution List
    ${result}=       Run Process       st2  execution  list  -n  1  -j
    Should Contain   ${result.stdout}  ${SUCCESS STATUS}
    Should Contain   ${result.stdout}  ${CORE LOCAL}
    [return]         ${result}

*** Settings ***
Library            Process
Library            String
Resource           ../common/keywords.robot
