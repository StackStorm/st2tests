.. code:: robotframework

    *** Settings ***
    Documentation    Hubot Slack Adapter Test with SlackCat
    Library          Process
    Library          String
    Library          OperatingSystem
    Suite Setup      Add slack token in st2chatops_env
    Suite Teardown   Cleaning the env file and uninstalling slackcat


    *** Variables ***
    ${BIN_DIR}               /usr/local/bin/
    ${ST2CHATOPS.ENV}        /opt/stackstorm/chatops/st2chatops.env
    ${SLACK_TOKEN_FILE}      slack-grobgobglobgrod.token
    ${SLACKCAT_TOKEN_FILE}   slackcat-abe.token

    *** Test Cases ***
    Installing SlackCat
        ${result}=          Run Keyword  Install Slackcat
        Run Process         sudo  mv  slackcat  ${BIN_DIR}
        File Should Exist   ${BIN_DIR}/slackcat
        Run Process         sudo  chmod  +x  ${BIN_DIR}/slackcat
        ${result}=          Run Process  ls  -al  ${BIN_DIR}/slackcat
        Should Contain      ${result.stdout}  xr-x
        Log To Console      \nOUTPUT: ${result.stdout}

    Configure Token for Slackcat
        ${result}=         Create File  ~/.slackcat   ${SLACKCAT_TOKEN}
        File Should Exist  ~/.slackcat
        ${result}=         Get File  ~/.slackcat
        Log To Console     \nCONTENTS OF ~/.slackcat: ${result}
        Should Contain     ${result}  ${SLACKCAT_TOKEN}

    Restart and check st2chatops service
        ${result}=        Run Process  sudo  service  st2chatops  restart   shell=True  stdout=subprocess.PIPE  stderr=subprocess.PIPE
        Log To Console     \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        ${result}=        Run Process  sudo  service  st2chatops  status    shell=True  stdout=subprocess.PIPE  stderr=subprocess.PIPE
        Log To Console     \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        Should Contain     ${result.stdout}    running
        Run Process        sudo  rm  -rf  subprocess.PIPE
        File Should Not Exist    subprocess.PIPE



    Check post_message execution and receive status
        ${random}=        Generate Token
        # Log To Console   \nRandom: ${random}
        ${result}=         Run Keyword  Hubot Post  ${random}
        # Log To Console   \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        Should Contain     ${result.stdout}   Chatops message received
        Should Contain     ${result.stdout}   ${random}

    Post message on the channel and verify
        [Documentation]    ID FOR POST MESSAGE
        ${result}=         Run Keyword  Get post_message execution id
        Should Contain     ${result.stdout}  slackcat posted 1 message lines to chatopsci
        Log To Console     SLACKCAT: \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}

    Execution from hubot with slackcat token in st2chatops_env
        [Documentation]     Hubot execution result for post message
        ...                 Needs slackcat-abe.token and slack-grobgobglobgrod.token in /opt/stackstorm/chatops/
        Run Keyword         Replace the token for slack with slackcat in st2chatops.env
        Log To Console      \n==========\nID CHATOPS.POST_MESSAGE: ${EXECUTION ID}\n==========\n
        ${result}=          Run Keyword    Execution logs from hubot
        Should Contain      ${result.stdout}  details available at
        Should Contain      ${result.stdout}  in channel: chatopsci, from: bot
        @{output}  Get Regexp Matches   ${result.stdout}  (?ms)result :\n--------\nresult :(.*?)in channel: chatopsci, from: bot
        Set Suite Variable  ${status}  Invalid chatops.post_message ID
        :FOR    ${ELEMENT}    IN    @{output}
        \    Log To Console  \n++=========++\n
        \    ${regex}=      Get Lines Containing String  ${ELEMENT}  matched regex
        \    ${length}=  Get Length  ${regex}
        \    Run Keyword if    ${length} == 0 and "id : ${EXECUTION ID}" in '''${ELEMENT}'''  Verify Correct Substring  ${ELEMENT}
        \    Log To console  Status: ${status}
        Pass execution if  '''${status}''' == "Valid chatops.post_message ID"  PASS
        Should Be Equal  ${status}  Valid chatops.post_message ID




    *** Keyword ***
    Verify Correct Substring
        [Arguments]     ${ELEMENT}
        Log To Console   \nSUBSTRING:\n------------\n${ELEMENT}\n------------\n
        Should Contain   ${ELEMENT}  in channel: chatopsci, from: bot
        Should Contain   ${ELEMENT}  ref : chatops.post_message
        Should Contain   ${ELEMENT}  id : ${EXECUTION ID}
        Set Suite Variable   ${status}  Valid chatops.post_message ID

    Replace the token for slack with slackcat in st2chatops.env
       ${result}=       Run Process  sudo  sed  -i  -e  's/export  HUBOT_SLACK_TOKEN\=${HUBOT_SLACK_TOKEN}/
       ...              export  HUBOT_SLACK_TOKEN\=${SLACKCAT_TOKEN}/g'
       ...              ${ST2CHATOPS.ENV}  shell=True
       ${result}=       Grep File    ${ST2CHATOPS.ENV}  export HUBOT_SLACK_TOKEN\=${SLACKCAT_TOKEN}
       Log To Console   \nREPLACING SLACK TOKEN with SLACKCAT's: ${result}
       Should Contain   ${result}    export HUBOT_SLACK_TOKEN\=${SLACKCAT_TOKEN}

    Execution logs from hubot
        [Documentation]     EXECUTION ID is from Keyword: Get post_message execution id
        ${output}=          Run Process    {  sleep  5;  echo  '!st2  get  execution  ${EXECUTION ID}'
        ...                                |  slackcat  --channel\=chatopsci  --stream  --plain;}
        ...                                |  timeout  25s  bin/hubot  cwd=/opt/stackstorm/chatops/  shell=True
        Log To Console      \n======+++++++++++============= COMPLETE STDOUT ====================+++++++++++++\n
        Log To Console      \nSTDOUT: ${output.stdout} \nSTDERR: ${output.stderr} \nRC ${output.rc}
        Log To Console      \n======+++++++++++=============+++++++++++++++++====================+++++++++++++\n
        [return]            ${output}

    Hubot Post
        [Arguments]    ${random}
        ${result}=     Run Process    {  echo  -n;  sleep  5;  st2  action  execute  chatops.post_message  channel\=#chatopsci
        ...                           message\='Debug. Please ignore. ${random}'
        ...                           >\/dev\/null;  echo;  sleep  5;}  |  bin\/hubot  \-\-test
        ...                           cwd=/opt/stackstorm/chatops/    shell=True
        [return]       ${result}

    Generate Token
        ${token}=      Generate Random String  32
        [return]       ${token}

    Install Slackcat
        ${result}=      Run Process  wget  https://github.com/vektorlab/slackcat/releases/download/v1.0/slackcat-1.0-linux-amd64  -O  slackcat
        Log To Console   \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        Should Contain  ${result.stderr}  saved
        File Should Exist  slackcat

    ID Execution List Action
        [Arguments]      ${action_name}
        ${result}=       Run Process  st2  execution  list  --action\=${action_name}  -a  id  -n  1  -j
        @{instance id}   Split String      ${result.stdout}    separator="
        Log To Console   \nACTION ${action_name} ID: @{instance id}[3]
        [return]         @{instance id}[3]

    Get post_message execution id
        ${id}=           Run Keyword    ID Execution List Action    chatops.post_message
        Set Suite Variable  ${EXECUTION ID}        ${id}
        ${result}=       Run Process    {  echo  '!st2  get  execution  {id}';}  |  slackcat  --channel\=chatopsci
        ...              --plain  --stream  shell=True
        [return]         ${result}




    Getting token from /opt/stackstorm/chatops/
        ${token1}=   Grep File  /opt/stackstorm/chatops/${SLACK_TOKEN_FILE}  xoxb
        Set Suite Variable  ${HUBOT_SLACK_TOKEN}  ${token1}
        Log To Console      \nSLACK_GROBGOBGLOBGORD_BOT_TOKEN: ${HUBOT_SLACK_TOKEN}
        ${token2}=   Grep File  /opt/stackstorm/chatops/${SLACKCAT_TOKEN_FILE}  xoxb
        Set Suite Variable  ${SLACKCAT_TOKEN}  ${token2}
        Log To Console      \nSLACKCAT_ABE_BOT_TOKEN: ${SLACKCAT_TOKEN}

    Add slack token in st2chatops_env
        [Documentation]  Suite Setup
        Log To Console   ==========SUITE SETUP==========
        Run Keyword      Getting token from /opt/stackstorm/chatops/
        Run Process      sudo  cp  ${ST2CHATOPS.ENV}  ${ST2CHATOPS.ENV}.orig
        File Should Exist  ${ST2CHATOPS.ENV}.orig
        ${result}=       Run Process  sudo  sed  -i  -e  's/#  export  HUBOT_ADAPTER\=slack/export  HUBOT_ADAPTER\=slack/g'
        ...              ${ST2CHATOPS.ENV}  shell=True
        ${result}=       Run Process  sudo  sed  -i  -e  's/export  HUBOT_ADAPTER\=shell/export  HUBOT_ADAPTER\=slack/g'
        ...              ${ST2CHATOPS.ENV}  shell=True
        ${result}=       Run Process  sudo  sed  -i  -e  's/#  export  HUBOT_SLACK_TOKEN\=xoxb-CHANGE-ME-PLEASE/export
        ...              HUBOT_SLACK_TOKEN\=${HUBOT_SLACK_TOKEN}/g'
        ...              ${ST2CHATOPS.ENV}  shell=True
        ${result}=       Grep File    ${ST2CHATOPS.ENV}  export HUBOT_SLACK_TOKEN\=${HUBOT_SLACK_TOKEN}
        Log To Console   \nTOKEN: ${result}
        Should Contain   ${result}    export HUBOT_SLACK_TOKEN\=${HUBOT_SLACK_TOKEN}
        ${result}=       Grep File    ${ST2CHATOPS.ENV}  export HUBOT_ADAPTER\=slack
        Log To Console   \nADAPTER: ${result}
        Should Contain   ${result}    export HUBOT_ADAPTER\=slack
        Log To Console   ===============================

    Cleaning the env file and uninstalling slackcat
       [Documentation]  Suite Teardown
       Log To Console   ==========SUITE TEARDOWN==========
       Run Process      sudo  mv  ${ST2CHATOPS.ENV}.orig  ${ST2CHATOPS.ENV}
       File Should Not Exist  ${ST2CHATOPS.ENV}.orig
       Run Process      sudo  rm  -rf  ${BIN_DIR}/slackcat
       File Should Not Exist    ${BIN_DIR}/slackcat
       ${result}=       Grep File    ${ST2CHATOPS.ENV}  \export HUBOT_SLACK_TOKEN\=
       Log To Console   \nORIGINAL TOKEN: ${result}
       ${result}=       Grep File    ${ST2CHATOPS.ENV}  \export HUBOT_ADAPTER\=slack
       Log To Console   \nORIGINAL ADAPTER: ${result}
       Log To Console   =================================
