.. code:: robotframework

     *** Variables ***
     ${SLEEP}           10
     ${HALF SLEEP}      5
     ${SUCCESS STATUS}    "status": "succeeded 
     ${RUNNING STATUS}    "status": "running
     ${CANCELED STATUS}   "status": "canceled"
    
     *** Test Cases ***
     Start Execution 
         ${result}=           Run Process  st2  run  examples.mistral-test-cancel  sleep\=${SLEEP}  -j  -a
         @{Execution ID}      Split String  ${result.stdout}
         Set Suite Variable   @{Execution ID}
         Log To Console       \nRUN EXECUTION: \n ${result.stdout}
         Log To Console       Execution ID: @{Execution ID}[-1]
         Sleep  1s

     Get Execution Result
         ${result}=          Run Process  st2  execution  get  @{Execution ID}[-1]  -j 
         Log To Console      \nEXECUTION GET: \n ${result.stdout}  
         Sleep  1s
         Should Contain X Times   ${result.stdout}  ${RUNNING STATUS}  2
   
     Cancel st2 Execution
         ${result}=           Run Process  st2  execution  cancel  @{Execution ID}[-1]  -j
         Sleep  2s
         Log To Console       \nEXECUTION CANCEL: \n ${result.stdout}
         Should Contain       ${result.stdout}   action execution with id @{Execution ID}[-1] canceled.
         ${Sleep}=            Evaluate  ${SLEEP} - ${HALF SLEEP}
         Sleep  ${Sleep}s     Wait for the ${Sleep} seconds
      
     Check Canceled Execution       
         ${result}=           Run Process  st2  execution  get  @{Execution ID}[-1]      -j
         Log To Console       \nEXECUTION GET AFTER CANCEL RUNNING:\n ${result.stdout}
         Should Contain X Times   ${result.stdout}  ${RUNNING STATUS}  1
         Should Contain       ${result.stdout}  ${CANCELED STATUS}
         ${Sleep}=            Evaluate  ${HALF SLEEP}+2
         Sleep  ${Sleep}s     Wait for the ${Sleep} seconds
    
     Cancellation Success
         ${result}=           Run Process  st2  execution  get  @{Execution ID}[-1]       -j
         Log To Console       \nGET EXECUTION AFTER CANCEL SUCCESS: \n ${result.stdout}
         Should Contain       ${result.stdout}  ${CANCELED STATUS}
         Should Contain       ${result.stdout}  ${SUCCESS STATUS}
         Should Not Contain   ${result.stdout}  ${RUNNING STATUS}  
         

    *** Settings ***
    Library    Process
    Library    String
