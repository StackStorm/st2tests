.. code:: robotframework


    *** Test Cases ***
    Stackstorm client's connection
        ${result}=       Run Process    st2  action  execute  core.local   cmd\=echo
        Log To Console   \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        Should Contain   ${result.stdout}    st2 execution get
        # Run Keyword If   ${result.rc} != 0   Fatal Error    ST2 NOT RUNNING

    Hubot npm
        ${result}=       Run Process    npm   list    \|  grep  hubot-stackstorm  cwd=/opt/stackstorm/chatops
        Log To Console   \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        Should Contain   ${result.stdout}  hubot-stackstorm@
        # Run Keyword If   ${result.rc} != 0   Fatal Error  HUBOT-STACKSTORM IS NOT INSTALLED

    Check for enabled StackStorm aliases
        ${result}=       Run Process      st2  action-alias   list  -a  enabled  -j
        Log To Console   \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        Should Contain   ${result.stdout}  "enabled": true
        # Run Keyword If   ${result.rc} != 0   Fatal Error  StackStorm doesn't seem to have registered and enabled aliases.

    Check chatops.notify rule
        ${result}=       Run Process   st2  rule  list  -p  chatops  -j
        Log To Console   \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        Should Contain   ${result.stdout}  "ref": "chatops.notify"
        Should Contain   ${result.stdout}  "enabled": true
        # Run Keyword If   ${result.rc} != 0   Fatal Error   CHATOPS.NOTIFY RULE NOT PRESENT/ENABLED

    Check Hubot help and load commands
        ${result}=       Run Keyword  Hubot Help 
        Log To Console   \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        Should Contain   ${result.stdout}    ! help - Displays all of the help commands
        Should Contain   ${result.stdout}    commands are loaded
        # Run Keyword If   ${result.rc} != 0   Fatal Error  HUBOT DOESN'T RESPOND TO THE "HELP" COMMAND OR DOESN'T TRY TO LOAD COMMANDS FROM STACKSTORM.


    Check post_message execution and receive status
        ${channel}=       Generate Token
        Log To Console   \nCHANNEL: ${channel}
        ${result}=       Run Keyword  Hubot Post  ${channel}
        Log To Console   \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        Should Contain   ${result.stdout}   Chatops message received
        Should Contain   ${result.stdout}   ${channel}
        # Run Keyword If   ${result.rc} != 0    Fatal Error  CHATOPS.POST_MESSAGE HASN'T BEEN RECEIVED.

    Check the complete request-response flow
        ${channel}=      Generate Token
        Log To Console   \nCHANNEL: ${channel}
        ${result}=       Run Keyword  Complete Flow  ${channel} 
        Log To Console   \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        Should Contain   ${result.stdout}   Give me just a moment to find the actions for you
        Should Contain   ${result.stdout}   st2.actions.list - Retrieve a list of available StackStorm actions.
        # Run Keyword If   ${result.rc} != 0    Fatal Error  END-TO-END TEST FAILED.


    *** Keyword ***
    Hubot Help
        ${result}=     Run Process    {  echo  -n;  sleep  5;  echo  'hubot  help';  echo;  sleep  2;}  |  bin\/hubot  \-\-test
        ...                           cwd=/opt/stackstorm/chatops/  shell=True
        [return]      ${result}

    Hubot Post
        [Arguments]    ${channel}
        ${result}=     Run Process    {  echo  -n;  sleep  5;  st2  action  execute  chatops.post_message  channel\=${channel}
        ...                           message\='Debug. If you see this you are incredibly lucky but please ignore.'
        ...                           >\/dev\/null;  echo;  sleep  2;}  |  bin\/hubot  \-\-test
        ...                           cwd=/opt/stackstorm/chatops/    shell=True
        [return]       ${result}

    Complete Flow
        [Arguments]    ${channel}
        ${result}=     Run Process  {  echo  -n;  sleep  5;  echo  'hubot  st2  list  5  actions  pack\=st2';  echo;  sleep  10;}
        ...                         |  bin\/hubot  \-\-test   cwd=/opt/stackstorm/chatops/    shell=True
        [return]       ${result}

    Generate Token
        ${token}=       Generate Random String  32
        [return]        ${token}


    *** Settings ***
    Documentation    Nine-Step Hubot Self-Check Program
    Library          Process
    Library          String
