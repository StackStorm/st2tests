.. code:: robotframework

     *** Variables ***
     ${SLEEP}             8
     ${SUCCESS STATUS}    "status": "succeeded
     ${RUNNING STATUS}    "status": "running
     ${CANCELED STATUS}   "status": "canceled"
     ${FAILED STATUS}     "status": "failed"

     *** Test Cases ***
     Run examples.mistral-test-cancel
         ${result}=           Run Process  st2  run  examples.mistral-test-cancel  sleep\=${SLEEP}  -j  -a
         @{Execution ID}      Split String  ${result.stdout}
         Set Suite Variable   @{Execution ID}
         Log To Console       \nRUN EXECUTION: \n ${result.stdout}
         Log To Console       Execution ID: @{Execution ID}[-1]

     Get Execution Result
         ${result}=  Wait Until Keyword Succeeds  10s  1s  Execution Result
         Log To Console      \nGET EXECUTION: \n ${result.stdout}

     Cancel examples.mistral-test-cancel
         ${result}=  Wait Until Keyword Succeeds  10s  1s  Execution Cancel
         Log To Console       \nEXECUTION CANCEL: \n ${result.stdout}

     Check Canceled Execution
         ${Sleep}=   Evaluate  ${SLEEP}+8
         ${result}=  Wait Until Keyword Succeeds  ${Sleep}s  1s         Canceled Execution
         Log To Console       \nGET EXECUTION AFTER CANCELLATION:\n ${result.stdout}

     Executed successfully examples.mistral-test-cancel
         ${Sleep}=   Evaluate  ${SLEEP}+8
         ${result}=  Wait Until Keyword Succeeds  ${Sleep}s  1s  Final Execution
         Log To Console       \nGET EXECUTION AFTER COMPLETION: \n ${result.stdout}



    *** Keywords ***
    Execution Result
        ${result}=          Run Process  st2  execution  get  @{Execution ID}[-1]  -j
        Should Contain X Times   ${result.stdout}  ${RUNNING STATUS}  2
        [return]            ${result}

    Execution Cancel
        ${result}=           Run Process  st2  execution  cancel  @{Execution ID}[-1]  -j
        Should Contain  ${result.stdout}   action execution with id @{Execution ID}[-1] canceled.
        [return]             ${result}

    Canceled Execution
         ${result}=           Run Process  st2  execution  get  @{Execution ID}[-1]      -j
         Should Contain X Times   ${result.stdout}  ${RUNNING STATUS}  1
         Should Contain       ${result.stdout}  ${CANCELED STATUS}
         [return]             ${result}

    Final Execution
         ${result}=           Run Process  st2  execution  get  @{Execution ID}[-1]       -j
         Should Contain       ${result.stdout}  ${CANCELED STATUS}
         Should Contain       ${result.stdout}  ${SUCCESS STATUS}
         Should Not Contain   ${result.stdout}  ${RUNNING STATUS}
         [return]             ${result}

    Copy and Load Examples Pack
        Log To Console   ___________________________SUITE SETUP___________________________
        ${result}=    Run Process     sudo  cp  \-r  /usr/share/doc/st2/examples/  /opt/stackstorm/packs/
        Should Be Equal As Integers   ${result.rc}  0
        # Copy Directory   /usr/share/doc/st2/examples/   /opt/stackstorm/packs/
        Directory Should Exist        /opt/stackstorm/packs/examples/
        ${result}=    Run Process     st2  run  packs.setup_virtualenv  packs\=examples  -j
        Should Contain                ${result.stdout}  ${SUCCESS STATUS}
        ${result}=    Run Process     st2ctl  reload  \-\-register\-all
        Log To Console    \nSETUP:\n\tOUTPUT:\n${result.stdout}\n\tERR:\n${result.stderr}\n\tRC:\n${result.rc}
        Log To Console   ___________________________SUITE SETUP___________________________

    Uninstall Examples Pack
        Log To Console   ___________________________SUITE TEARDOWN___________________________
        ${result}=                   Run Process  st2  run  packs.uninstall  packs\=examples  -j
        Should Contain X Times       ${result.stdout}  ${SUCCESS STATUS}  3
        Directory Should Not Exist  /opt/stackstorm/packs/examples/

    *** Settings ***
    Library         Process
    Library         String
    Library         OperatingSystem
    Suite Setup     Copy and Load Examples Pack
    Suite Teardown  Uninstall Examples Pack
