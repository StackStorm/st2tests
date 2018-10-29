*** Variables ***
${EXECUTION LIST}         st2 execution list
${ACTION LIST}            st2 action list


*** Test Cases ***
TEST:Verify include attributes works as expected for st2 execution list
    ${result}=           Run  ${EXECUTION LIST} --attr id
    Log To Console       \nRESULT:\n${result}
    Should Contain       ${result}  id
    Should Not Contain   ${result}  status
    Should Not Contain   ${result}  context
    Should Not Contain   ${result}  start_timestamp
    Should Not Contain   ${result}  end_timestamp
    Should Not Contain   ${result}  action.ref

    ${result}=           Run  ${EXECUTION LIST} --attr doesntexist
    Log To Console       \nRESULT:\n${result}
    Should Contain       ${result}  Invalid or unsupported include attribute specified

TEST:Verify include attributes works as expected for st2 action list
    ${result}=           Run  ${ACTION LIST} --attr name
    Log To Console       \nRESULT:\n${result}
    Should Contain       ${result}  | name
    Should Contain       ${result}  name
    Should Not Contain   ${result}  | pack
    Should Not Contain   ${result}  | description
    Should Not Contain   ${result}  description

    ${result}=           Run  ${ACTION LIST} --attr doesntexist
    Log To Console       \nRESULT:\n${result}
    Should Contain       ${result}  Invalid or unsupported include attribute specified


*** Settings ***
Library            Process
Library            OperatingSystem
Resource           ../common/keywords.robot
