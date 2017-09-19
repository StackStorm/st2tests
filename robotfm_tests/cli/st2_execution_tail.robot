*** Variables ***
${EXECUTION RUN}    st2 run
${EXECUTION TAIL}   st2 execution tail

${CHILD EXECUTION 3 STARTED}    (?ims).*Child execution \\(task=task3\\) .*? has started\..*
${CHILD EXECUTION 3 FINISHED}   (?ims).*Child execution \\(task=task3\\) .*? has finished \\(status=succeeded\\)\.
${CHILD EXECUTION 10 STARTED}   (?ims).*Child execution \\(task=task10\\) .*? has started\..*
${CHILD EXECUTION 10 FINISHED}  (?ims).*Child execution \\(task=task10\\) .*? has finished \\(status=succeeded\\)\.
${PARENT EXECUTION FINISHED}    (?ims).*Execution .*? has completed \\(status=succeeded\\).

*** Test Cases ***
TEST:Verify st2 execution tail command works correctly
    ${result}=           Run  ${EXECUTION RUN} examples.action_chain_streaming_demo -a
    @{Execution ID}      Split String  ${result}
    Set Suite Variable   @{Execution ID}
    Log To Console       \nRUN EXECUTION:\n
    Log To Console       EXECUTION ID: @{Execution ID}[-1]\n

    ${tail_output}=       Run  ${EXECUTION TAIL} @{Execution ID}[-1]
    Log To Console       \nRUN EXECUTION TAIL (might take a while):\n
    Log To Console       \nRESULT:\n
    Log To Console       \n${tail_output}
    Should Match Regexp  ${tail_output}  ${CHILD EXECUTION 3 STARTED}
    Should Match Regexp  ${tail_output}  ${CHILD EXECUTION 3 FINISHED}
    Should Match Regexp  ${tail_output}  ${CHILD EXECUTION 10 STARTED}
    Should Match Regexp  ${tail_output}  ${CHILD EXECUTION 10 FINISHED}
    Should Match Regexp  ${tail_output}  ${PARENT EXECUTION FINISHED}

*** Settings ***
Library         Process
Library         String
Library         OperatingSystem
Resource        ../common/keywords.robot
#Suite Setup     SETUP:Copy and Load Examples Pack
#Suite Teardown  TEARDOWN:Uninstall Examples Pack
