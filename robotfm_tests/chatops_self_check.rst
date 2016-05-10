.. code:: robotframework


    *** Variables ***
    ${ST2}                /usr/bin/st2 
    ${SUCCESS}            Everything seems to be fine!!
    ${FAILURE}            Uh oh! Something went wrong! 
    ${HUBOT HELP}          {  echo  -n;  sleep  5;  echo  'hubot  help';  echo;  sleep  2;}  |  bin\/hubot  \-\-test 
    
    
    *** Test Cases ***
    Stackstorm client's connection
        ${result}=       Run Process    st2  action  execute  core.local   cmd\=echo
        Log To Console   \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}    
        Should Contain   ${result.stdout}    st2 execution get
        # Run Keyword If   ${result.rc} != 0   Fatal Error    ST2 NOT RUNNING

    Check Hubot installation and status
        ${result}=       Run Process    service  st2chatops  status
        Log To Console   \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        Should Contain   ${result.stdout}  st2chatops start/running
        # Run Keyword If   ${result.rc} != 0   Fatal Error    HUBOT NOT RUNNING ON THIS MACHINE   

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
        ${result}=       Run Process     ${HUBOT HELP}   cwd=/opt/stackstorm/chatops/  shell=True
        Sleep  15s
        Log To Console   \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        Should Contain   ${result.stdout}    ! help - Displays all of the help commands
        Should Contain   ${result.stdout}    commands are loaded
        # Run Keyword If   ${result.rc} != 0   Fatal Error  HUBOT DOESN'T RESPOND TO THE "HELP" COMMAND OR DOESN'T TRY TO LOAD COMMANDS FROM STACKSTORM. 


    Check post_message execution and receive status
        ${channel}=       Generate Random String  32
        Log To Console   \nCHANNEL: ${channel}
        ${result}=       Run Process  st2  action  execute  chatops.post_message  channel\=${channel}  message\=Debug. If you see this you're incredibly lucky but please ignore.
        Log To Console   \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        Should Contain   ${result.stdout}   execution get
        # Run Keyword If   ${result.rc} != 0    Fatal Error  CHATOPS.POST_MESSAGE DOESN'T WORK. 
        Sleep  2s
        ${result}=       Run Process  tail  \/var\/log\/st2\/st2chatops.log  shell=True
        Log To Console   \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        Should Contain   ${result.stdout}   ${channel}
        # Run Keyword If   ${result.rc} != 0    Fatal Error  CHATOPS.POST_MESSAGE HASN'T BEEN RECEIVED. 


    *** Settings ***
    Documentation    Nine-Step Hubot Self-Check Program
    Library          Process
    Library          String
