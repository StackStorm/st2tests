*** Variables ***
${EXECUTION RUN}    st2 run
${EXECUTION TAIL}   st2 execution tail

${EXECUTION STDOUT LINE 6}   stdout -> Line: 6
${EXECUTION STDOUT LINE 10}  stdout -> Line: 10
${EXECUTION STDERR LINE 7}   stderr -> Line: 7
${EXECUTION STDERR LINE 9}   stderr -> Line: 9

${CHILD EXECUTION 3 STARTED}    (?ims).*Child execution \\(task=task3\\) .*? has started\..*
${CHILD EXECUTION 3 FINISHED}   (?ims).*Child execution \\(task=task3\\) .*? has finished \\(status=succeeded\\)\.
${CHILD EXECUTION 10 STARTED}   (?ims).*Child execution \\(task=task10\\) .*? has started\..*
${CHILD EXECUTION 10 FINISHED}  (?ims).*Child execution \\(task=task10\\) .*? has finished \\(status=succeeded\\)\.
${PARENT EXECUTION FINISHED}    (?ims).*Execution .*? has completed \\(status=succeeded\\).

*** Test Cases ***
TEST:Verify st2 execution tail command works correctly simple ations
    ${result}=           Run  ${EXECUTION RUN} examples.python_runner_print_to_stdout_and_stderr count=10 sleep_delay=0.1 -a
    @{Execution ID}      Split String  ${result}
    Set Suite Variable   @{Execution ID}
    Log To Console       \nRUN EXECUTION:\n
    Log To Console       \nRESULT:\n: ${result}
    Log To Console       EXECUTION ID: @{Execution ID}[-1]\n

    ${tail_output}=       Run  ${EXECUTION TAIL} @{Execution ID}[-1]
    Log To Console       \nRUN EXECUTION TAIL (might take a while):\n
    Log To Console       \nRESULT:\n
    Log To Console       \n${tail_output}
    Should Contain       ${tail_output}  ${EXECUTION STDOUT LINE 6}
    Should Contain       ${tail_output}  ${EXECUTION STDOUT LINE 10}
    Should Contain       ${tail_output}  ${EXECUTION STDERR LINE 7}
    Should Contain       ${tail_output}  ${EXECUTION STDERR LINE 9}

TEST:Verify st2 execution tail command works correctly for workflows
    ${result}=           Run  ${EXECUTION RUN} examples.action_chain_streaming_demo -a
    @{Execution ID}      Split String  ${result}
    Set Suite Variable   @{Execution ID}
    Log To Console       \nRUN EXECUTION:\n
    Log To Console       \nRESULT:\n: ${result}
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
Suite Setup     SETUP:Copy and Load Examples Pack
Suite Teardown  TEARDOWN:Uninstall Examples Pack
