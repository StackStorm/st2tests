*** Settings ***
Documentation    Hubot Slack Adapter Test with SlackCat
Library          Process
Library          String
Library          OperatingSystem
Resource         ../common/keywords.robot
Suite Setup      SETUP:Add slack token in st2chatops_env
Suite Teardown   TEARDOWN:Cleaning the env file and uninstalling slackcat


*** Variables ***
${BIN_DIR}               /usr/local/bin/
${ST2CHATOPS.ENV}        /opt/stackstorm/chatops/st2chatops.env
${SLACK_TOKEN_FILE}      slack-grobgobglobgrod.token
${SLACKCAT_TOKEN_FILE}   slackcat-abe.token

*** Test Cases ***
TEST:Installing SlackCat
    ${result}=          Run Keyword  KEYWORD:Install Slackcat
    Run Process         sudo  mv  slackcat  ${BIN_DIR}
    File Should Exist   ${BIN_DIR}/slackcat
    Run Process         sudo  chmod  +x  ${BIN_DIR}/slackcat
    ${result}=          Run Process  ls  -al  ${BIN_DIR}/slackcat
    Should Contain      ${result.stdout}  xr-x
    Process Log To Console  ${result}

TEST:Configure Token for Slackcat
    ${result}=         Create File  ~/.slackcat   ${SLACKCAT_TOKEN}
    File Should Exist  ~/.slackcat
    ${result}=         Get File  ~/.slackcat
    Log To Console     \n\nCONTENTS OF ~/.slackcat: ${result}\n
    Should Contain     ${result}  ${SLACKCAT_TOKEN}

TEST:Restart and check st2chatops service
    ${result}=        Run Process  sudo  service  st2chatops  restart   shell=True  stdout=subprocess.PIPE  stderr=subprocess.PIPE
    Process Log To Console  ${result}
    ${result}=        Run Process  sudo  service  st2chatops  status    shell=True  stdout=subprocess.PIPE  stderr=subprocess.PIPE
    Process Log To Console  ${result}
    Should Contain     ${result.stdout}    running
    Run Process        sudo  rm  -rf  subprocess.PIPE
    File Should Not Exist    subprocess.PIPE



TEST:Check post_message execution and receive status
    ${random}=        KEYWORD:Generate Token
    Log To Console   \nRANDOM: ${random}
    ${result}=        Wait Until Keyword Succeeds  3x  5s   KEYWORD:Hubot Post  ${random}

TEST:Post message on the channel and verify
    [Documentation]    ID FOR POST MESSAGE
    ${result}=          Wait Until Keyword Succeeds  3x  5s  KEYWORD:Get post_message execution id for slackcat
    Should Contain     ${result.stdout}  slackcat posted 1 message lines to chatops_ci

TEST:Execution from hubot with slackcat token in st2chatops_env
    [Documentation]     Hubot execution result for post message
    ...                 Needs slackcat-abe.token and slack-grobgobglobgrod.token in /opt/stackstorm/chatops/

    Run Keyword         KEYWORD:Replace the token for slack with slackcat in st2chatops.env
    Log To Console      \n<===============================>\nCHATOPS.POST_MESSAGE EXECUTION ID: ${EXECUTION ID}\n<===============================>\n

    ${result}=          Wait Until Keyword Succeeds  3x  5s   KEYWORD:Execution logs from hubot

*** Keyword ***
KEYWORD:Verify Correct Substring
    [Arguments]     ${ELEMENT}
    Log To Console   \nMATCHED SUBSTRING:\n===================>:\n${ELEMENT}\n:<===================\n
    Should Contain   ${ELEMENT}  in channel: chatops_ci, from: bot
    Should Contain   ${ELEMENT}  ref : chatops.post_message
    Should Contain   ${ELEMENT}  id : ${EXECUTION ID}
    Set Suite Variable   ${status}  Valid chatops.post_message ID

KEYWORD:Replace the token for slack with slackcat in st2chatops.env
   ${result}=       Run Process  sudo  sed  -i  -e  's/export  HUBOT_SLACK_TOKEN\=${HUBOT_SLACK_TOKEN}/
   ...              export  HUBOT_SLACK_TOKEN\=${SLACKCAT_TOKEN}/g'
   ...              ${ST2CHATOPS.ENV}  shell=True
   ${result}=       Grep File    ${ST2CHATOPS.ENV}  export HUBOT_SLACK_TOKEN\=${SLACKCAT_TOKEN}
   Log To Console   \n\nREPLACING SLACK TOKEN with SLACKCAT's: ${result}\n
   Should Contain   ${result}    export HUBOT_SLACK_TOKEN\=${SLACKCAT_TOKEN}

KEYWORD:Execution logs from hubot
    [Documentation]     EXECUTION ID is from Keyword: Get post_message execution id

    ${result}=          Run Process    {  sleep  5;  echo  '!st2  get  execution  ${EXECUTION ID}'
    ...                                |  slackcat  --channel\=chatops_ci  --stream  --plain;}
    ...                                |  timeout  25s  bin/hubot  cwd=/opt/stackstorm/chatops/  shell=True
    Log To Console      \n<===================> COMPLETE HUBOT STDOUT START <===================>
    Process Log To Console      ${result}
    Log To Console      \n===================== COMPLETE HUBOT STDOUT END =======================\n
    Should Contain      ${result.stdout}  details available at
    Should Contain      ${result.stdout}  in channel: chatops_ci, from: bot

    ${regex_value}      Set Variable   (?ms)result :\n--------\nresult :(.*?)in channel: chatops_ci, from: bot
    @{output}  Get Regexp Matches   ${result.stdout}  ${regex_value}

    Set Suite Variable  ${status}  Invalid chatops.post_message ID
    :FOR    ${ELEMENT}    IN    @{output}
    \    Log To Console  \n<========== MATCH ==========>\n
    \    ${regex}=      Get Lines Containing String  ${ELEMENT}  matched regex
    \    ${length}=  Get Length  ${regex}
    \    Run Keyword if    ${length} == 0 and "id : ${EXECUTION ID}" in '''${ELEMENT}'''  KEYWORD:Verify Correct Substring  ${ELEMENT}
    \    Log To console  STATUS: ${status}\n

    Should Be Equal  ${status}  Valid chatops.post_message ID

KEYWORD:Hubot Post
    [Arguments]    ${random}
    ${result}=     Run Process    {  echo  -n;  sleep  5;  st2  action  execute  chatops.post_message  channel\=#chatops_ci
    ...                           message\='Debug. Please ignore. ${random}'
    ...                           >\/dev\/null;  echo;  sleep  10;}  |  bin\/hubot  \-\-test
    ...                           cwd=/opt/stackstorm/chatops/    shell=True
    Should Contain     ${result.stdout}   Chatops message received
    Should Contain     ${result.stdout}   ${random}

KEYWORD:Generate Token
    ${token}=      Generate Random String  32
    [return]       ${token}

KEYWORD:Install Slackcat
    ${result}=      Run Process  wget  https://github.com/vektorlab/slackcat/releases/download/v1.0/slackcat-1.0-linux-amd64  -O  slackcat  >  /dev/null
    # Process Log To Console      ${result}
    Should Contain  ${result.stderr}  saved
    File Should Exist  slackcat

KEYWORD:ID Execution List Action
    [Arguments]      ${action_name}
    ${result}=       Run Process  st2  execution  list  --action\=${action_name}  -a  id  -n  1  -j
    @{instance id}   Split String      ${result.stdout}    separator="
    Log To Console   \n\nACTION: ${action_name}, ID: @{instance id}[3]\n
    [return]         @{instance id}[3]

KEYWORD:Get post_message execution id for slackcat
    ${id}=           Run Keyword    KEYWORD:ID Execution List Action    chatops.post_message
    Set Suite Variable  ${EXECUTION ID}        ${id}
    ${result}=       Run Process    {  echo  '!st2  get  execution  {id}';  sleep  10;}  |  slackcat  --channel\=chatops_ci
    ...              --plain  --stream  shell=True
    Process Log To Console      ${result}
    [return]         ${result}




SETUP:Getting token from /opt/stackstorm/chatops/
    ${token1}=   Grep File  /opt/stackstorm/chatops/${SLACK_TOKEN_FILE}  xoxb
    Set Suite Variable  ${HUBOT_SLACK_TOKEN}  ${token1}
    Log To Console      \nSLACK_GROBGOBGLOBGORD_BOT_TOKEN: ${HUBOT_SLACK_TOKEN}
    ${token2}=   Grep File  /opt/stackstorm/chatops/${SLACKCAT_TOKEN_FILE}  xoxb
    Set Suite Variable  ${SLACKCAT_TOKEN}  ${token2}
    Log To Console      \nSLACKCAT_ABE_BOT_TOKEN: ${SLACKCAT_TOKEN}

SETUP:Add slack token in st2chatops_env
    [Documentation]  Suite Setup
    Log To Console   _____________________SUITE SETUP_____________________
    Run Keyword      SETUP:Getting token from /opt/stackstorm/chatops/
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
    Log To Console   \nTOKEN: ${result}\n
    Should Contain   ${result}    export HUBOT_SLACK_TOKEN\=${HUBOT_SLACK_TOKEN}
    ${result}=       Grep File    ${ST2CHATOPS.ENV}  export HUBOT_ADAPTER\=slack
    Log To Console   \nADAPTER: ${result}\n
    Should Contain   ${result}    export HUBOT_ADAPTER\=slack
    Log To Console   _____________________________________________________\n

TEARDOWN:Cleaning the env file and uninstalling slackcat
   [Documentation]  Suite Teardown
   Log To Console   ____________________SUITE TEARDOWN____________________
   Run Process      sudo  mv  ${ST2CHATOPS.ENV}.orig  ${ST2CHATOPS.ENV}
   File Should Not Exist  ${ST2CHATOPS.ENV}.orig
   Run Process      sudo  rm  -rf  ${BIN_DIR}/slackcat
   File Should Not Exist    ${BIN_DIR}/slackcat
   ${result}=       Grep File    ${ST2CHATOPS.ENV}  \export HUBOT_SLACK_TOKEN\=
   Log To Console   \nORIGINAL TOKEN: ${result}\n
   ${result}=       Grep File    ${ST2CHATOPS.ENV}  \export HUBOT_ADAPTER\=slack
   Log To Console   \nORIGINAL ADAPTER: ${result}\n
   Log To Console   ______________________________________________________\n

