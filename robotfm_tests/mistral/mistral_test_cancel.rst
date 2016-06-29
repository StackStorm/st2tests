.. code:: robotframework

     *** Variables ***
     ${SLEEP}           30
     ${HALF SLEEP}      15
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
         Sleep  5s

     Get Execution Result
         ${result}=          Run Process  st2  execution  get  @{Execution ID}[-1]  -j
         Log To Console      \nEXECUTION GET: \n ${result.stdout}
         Sleep  1s
         Should Contain X Times   ${result.stdout}  ${RUNNING STATUS}  2

     Cancel examples.mistral-test-cancel
         ${result}=           Run Process  st2  execution  cancel  @{Execution ID}[-1]  -j
         Sleep  2s
         Log To Console       \nEXECUTION CANCEL: \n ${result.stdout}
         Should Contain       ${result.stdout}   action execution with id @{Execution ID}[-1] canceled.
         ${Sleep}=            Evaluate  ${SLEEP} - ${HALF SLEEP}
         Sleep  ${Sleep}s     Wait for the ${Sleep} seconds

     Check Canceled Execution
         ${result}=           Run Process  st2  execution  get  @{Execution ID}[-1]      -j
         Log To Console       \nEXECUTION GET AFTER CANCELLATION:\n ${result.stdout}
         Should Contain X Times   ${result.stdout}  ${RUNNING STATUS}  1
         Should Contain       ${result.stdout}  ${CANCELED STATUS}
         ${Sleep}=            Evaluate  ${HALF SLEEP}+2
         Sleep  ${Sleep}s     Wait for the ${Sleep} seconds

     Executed successfully examples.mistral-test-cancel
         ${result}=           Run Process  st2  execution  get  @{Execution ID}[-1]       -j
         Log To Console       \nEXECUTION GET AFTER COMPLETION: \n ${result.stdout}
         Should Contain       ${result.stdout}  ${CANCELED STATUS}
         Should Contain       ${result.stdout}  ${SUCCESS STATUS}
         Should Not Contain   ${result.stdout}  ${RUNNING STATUS}


    *** Keywords ***
    Copy and Load Examples Pack
        ${result}=    Run Process     sudo  cp  \-r  /usr/share/doc/st2/examples/  /opt/stackstorm/packs/
        Should Be Equal As Integers   ${result.rc}  0
        # Copy Directory   /usr/share/doc/st2/examples/   /opt/stackstorm/packs/
        Directory Should Exist        /opt/stackstorm/packs/examples/
        ${result}=    Run Process     st2  run  packs.setup_virtualenv  packs\=examples  -j
        Should Contain                ${result.stdout}  ${SUCCESS STATUS}
        ${result}=    Run Process     st2ctl  reload  \-\-register\-all
        # Log To Console    SETUP: ${result.stdout} ___ ${result.stderr} ___ ${result.rc}
        Sleep  5s

    Uninstall Examples Pack
        ${result}=                   Run Process  st2  run  packs.uninstall  packs\=examples  -j
        Should Contain X Times       ${result.stdout}  ${SUCCESS STATUS}  4
        # Run Process                 sudo  rm  \-rf  /opt/stackstorm/packs/examples/
        # Remove Directory        /opt/stackstorm/packs/examples/
        Directory Should Not Exist  /opt/stackstorm/packs/examples/

    *** Settings ***
    Library         Process
    Library         String
    Library         OperatingSystem
    Suite Setup     Copy and Load Examples Pack
    Suite Teardown  Uninstall Examples Pack
