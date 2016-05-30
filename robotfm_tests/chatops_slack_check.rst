.. code:: robotframework

    *** Variables ***
    ${SLACKCAT_TOKEN}     xoxb-45889459620-QwIbHtyKny4qi6sDbRRUh4vu
    ${HUBOT_SLACK_TOKEN}  xoxb-45631117332-JxnqYN0biXrGeKgVjg4Z6eaf
    ${BIN_DIR}            /usr/local/bin/
    ${ST2CHATOPS.ENV}     /opt/stackstorm/chatops/st2chatops.env


    *** Test Cases ***
    Installing SlackCat
        ${result}=       Run Keyword  Install Slackcat
        Run Process      sudo  mv  slackcat  ${BIN_DIR}
        File Should Exist  ${BIN_DIR}/slackcat
        Run Process      sudo  chmod  +x  ${BIN_DIR}/slackcat
        ${result}=       Run Process  ls  -al  ${BIN_DIR}/slackcat
        Should Contain   ${result.stdout}  -rwxrwxr-x
        Log To Console   \nOUTPUT: ${result.stdout}

    Configure Token for Slackcat
        ${result}=         Create File  ~/.slackcat   ${SLACKCAT_TOKEN} 
        File Should Exist  ~/.slackcat
        ${result}=         Get File  ~/.slackcat
        Log To Console     \nCONTENTS OF ~/.slackcat: ${result}
        Should Contain     ${result}  ${SLACKCAT_TOKEN}

    Configure ChatOps env with Slack token
       Run Keyword      Add slack token at ${ST2CHATOPS.ENV}
       ${result}=       Grep File    ${ST2CHATOPS.ENV}  export HUBOT_SLACK_TOKEN\=${HUBOT_SLACK_TOKEN}
       Log To Console   \nTOKEN: ${result}
       Should Contain   ${result}    export HUBOT_SLACK_TOKEN\=${HUBOT_SLACK_TOKEN}
       ${result}=       Grep File    ${ST2CHATOPS.ENV}  export HUBOT_ADAPTER\=slack
       Log To Console   \nADAPTER: ${result}
       Should Contain   ${result}    export HUBOT_ADAPTER\=slack

    Restart and check st2chatops service
        ${result}=         Run Process    sudo  service  st2chatops  restart
        Log To Console     \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        ${result}=         Run Process    service  st2chatops  status
        Log To Console     \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        Should Contain     ${result.stdout}    running  

    Check post_message execution and receive status
        ${channel}=       Generate Token
        # Log To Console   \nCHANNEL: ${channel}
        ${result}=       Run Keyword  Hubot Post  ${channel}
        # Log To Console   \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        Should Contain   ${result.stdout}   Chatops message received
        Should Contain   ${result.stdout}   ${channel}
 
    Execution success    
        ${result}=         Run Keyword  Get last post_message execution id for slackcat
        Sleep  10s
        Should Contain     ${result.stdout}  slackcat posted 1 message lines to chatopsci
        Log To Console     SLACKCAT: \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        #${result}=         Run Keyword  Get last post_message execution id for slackcat          




    *** Keyword ***
    Hubot Post
        [Arguments]    ${channel}
        ${result}=     Run Process    {  echo  -n;  sleep  5;  st2  action  execute  chatops.post_message  channel\=${channel}
        ...                           message\='Debug. If you see this you are incredibly lucky but please ignore.'
        ...                           >\/dev\/null;  echo;  sleep  2;}  |  bin\/hubot  \-\-test
        ...                           cwd=/opt/stackstorm/chatops/    shell=True
        [return]       ${result}

    Generate Token
        ${token}=      Generate Random String  32
        [return]       ${token}
    
    Install Slackcat
        ${result}=      Run Process  wget  https://github.com/vektorlab/slackcat/releases/download/v1.0/slackcat-1.0-linux-amd64  -O  slackcat
        Sleep  5s
        # Log To Console   \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        # Should Contain  ${result.stderr}  ‘slackcat’ saved
        File Should Exist  slackcat 

    Add slack token at ${ST2CHATOPS.ENV}
        ${result}=       Run Process  sudo  sed  -i  -e  's/#  export  HUBOT_ADAPTER\=slack/export  HUBOT_ADAPTER\=slack/g'
        ...              ${ST2CHATOPS.ENV}  shell=True
        ${result}=       Run Process  sudo  sed  -i  -e  's/export  HUBOT_ADAPTER\=shell/export  HUBOT_ADAPTER\=slack/g'
        ...              ${ST2CHATOPS.ENV}  shell=True
        ${result}=       Run Process  sudo  sed  -i  -e  's/#  export  HUBOT_SLACK_TOKEN\=xoxb-CHANGE-ME-PLEASE/
        ...              export  HUBOT_SLACK_TOKEN\=${HUBOT_SLACK_TOKEN}/g'
        ...              ${ST2CHATOPS.ENV}  shell=True
    
     ID Execution List Action
        [Arguments]      ${action_name}
        ${result}=       Run Process  st2  execution  list  --action\=${action_name}  -a  id  -n  1  -j
        @{instance id}   Split String      ${result.stdout}    separator="
        Log To Console   \nINSTANCE ID: @{instance id}[3]
        [return]         @{instance id}[3]

    Get last post_message execution id for slackcat
        ${id}=           Run Keyword    ID Execution List Action    chatops.post_message 
        ${result}=       Run Process    {  echo  '!st2  get  execution  {id}';}  |  slackcat  --channel\=chatopsci
        ...              --plain  --stream  shell=True
        [return]         ${result} 

    *** Settings ***
    Documentation    Hubot Slack Adapter Test with SlackCat
    Library          Process
    Library          String
    Library          OperatingSystem
