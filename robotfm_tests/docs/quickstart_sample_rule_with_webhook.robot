*** Variables ***
${PACK EXAMPLES}        "pack": "examples"
${UID SAMPLE WEBHOOK}   "uid": "rule:examples:sample_rule_with_webhook"
${REF SAMPLE WEBHOOK}   "ref": "examples.sample_rule_with_webhook"
${ENABLED}          "enabled": true
${DISABLED}         "enabled": false

*** Test Cases ***
TEST:Verify rule creation
    ${result}=       Run Process    st2  rule  create  /usr/share/doc/st2/examples/rules/sample_rule_with_webhook.yaml  -j
    Process Log To Console             ${result}
    Should Contain   ${result.stdout}  ${UID SAMPLE WEBHOOK}
    Should Contain   ${result.stdout}  ${ENABLED}

    ${result}=       Run Process    st2  rule  get  examples.sample_rule_with_webhook   -j
    Should Contain   ${result.stdout}  ${UID SAMPLE WEBHOOK}
    Should Contain   ${result.stdout}  ${ENABLED}

    ${result}=       Run Process    st2  rule  list  --pack  examples  -j
    Should Contain   ${result.stdout}  ${REF SAMPLE WEBHOOK}
    Should Contain   ${result.stdout}  ${PACK EXAMPLES}
    Should Contain   ${result.stdout}  ${ENABLED}

TEST:Verify rule disable/enable
    ${result}=       Run Process    st2  rule  disable  examples.sample_rule_with_webhook   -j
    Should Contain   ${result.stdout}  ${UID SAMPLE WEBHOOK}
    Should Contain   ${result.stdout}  ${DISABLED}
    ${result}=       Run Process    st2  rule  enable  examples.sample_rule_with_webhook   -j
    Should Contain   ${result.stdout}  ${UID SAMPLE WEBHOOK}
    Should Contain   ${result.stdout}  ${ENABLED}

TEST:Verify error message for duplicate rule
    ${result}=       Run Process    st2  rule  create  /usr/share/doc/st2/examples/rules/sample_rule_with_webhook.yaml  -j
    Should Contain   ${result.stdout}  ERROR: 409 Client Error: Conflict
    Should Contain   ${result.stdout}  MESSAGE: Tried to save duplicate unique keys
    Should Contain   ${result.stdout}  duplicate key error
    Should Contain   ${result.stdout}  sample_rule_with_webhook

TEST:Verify rule status
    ${TOKEN}=        Run Process    st2  auth  -p  Ch@ngeMe  st2admin  -t  shell=True
    Process Log To Console             ${TOKEN}
    ${result}=       Run  curl -k https://localhost/api/v1/webhooks/sample -d '{"foo": "bar", "name": "st2"}' -H 'Content-Type: application/json' -H 'X-Auth-Token: ${TOKEN.stdout}'
    Log To Console   \nOUTPUT: ${result}
    Should Contain   ${result}      {\n    "foo": "bar",\n    "name": "st2"\n}
    ${result}=       Wait Until Keyword Succeeds  5s  1s  KEYWORD:Check Tail
    Process Log To Console             ${result}

TEST:Verify rule deletion(and error message)
    ${result}=       Run Process    st2  rule  delete  examples.sample_rule_with_webhook  -j
    Should Contain   ${result.stdout}  Resource with id "examples.sample_rule_with_webhook" has been successfully deleted
    ${result}=       Run Process    st2  rule  list  --pack  examples  -j
    Should Contain   ${result.stdout}  No matching items found
    ${result}=       Run Process    st2  rule  delete  examples.sample_rule_with_webhook  -j
    Should Contain   ${result.stdout}  Rule "examples.sample_rule_with_webhook" is not found.

TEST:Verify examples pack installation and setup
    ${result}=       Run Process    sudo  cp  -r  /usr/share/doc/st2/examples/  /opt/stackstorm/packs/
    Directory Should Exist  /opt/stackstorm/packs/examples
    ${result}=       Run Process    st2  run  packs.setup_virtualenv  packs\=examples  -j
    Should Contain   ${result.stdout}  "result": "Successfully set up virtualenv for the following packs: examples"
    Should Contain   ${result.stdout}  "status": "succeeded"
    ${result}=       Run Process    st2  action  list  -p  examples
    Should Contain   ${result.stdout}  No matching items found
    ${result}=       Run Process  st2ctl  reload  --register-all
    Process Log To Console             ${result}
    ${result}=       Run Process    st2  action  list  -p  examples  -j
    Should Contain   ${result.stdout}  ${PACK EXAMPLES}

TEST:Verify examples pack uninstall
    ${result}=       Run Process  st2  run  packs.uninstall  packs\=examples  -j
    Should Contain X Times   ${result.stdout}  "status": "succeeded  3
    Should Contain   ${result.stdout}    "action": "packs.unload"
    Should Contain   ${result.stdout}    "action": "packs.delete"
    ${result}=       Run Process    st2  action  list  -p  examples
    Should Contain   ${result.stdout}  No matching items found

*** Settings ***
Library            Process
Library            OperatingSystem
Resource           ../common/keywords.robot
Suite Setup        SETUP:Check examples pack
Suite Teardown     TEARDOWN:Clean files

*** Keywords ***
SETUP:Check examples pack
    Log To Console   ___________________________SUITE SETUP___________________________
    Log To Console   _________________________________________________________________\n
    [Documentation]  CI setup
    ${result}=       Run Process    st2  action  list  -p  examples
    Run Keyword Unless  '''${result.stdout}''' == 'No matching items found'    KEYWORD:Remove the examples pack
    ${file exist}    Run Process    sudo  ls   /home/stanley/st2.webhook_sample.out  shell=True
    Log To Console   \nINITIAL FILE STATUS:\n
    Process Log To Console             ${file exist}
    Run Keyword If   ${file exist.rc} == 0  KEYWORD:Delete st2.webhook_sample.out
    Log To Console   ___________________________SUITE SETUP___________________________
    Log To Console   _________________________________________________________________\n

KEYWORD:Remove the examples pack
    ${result}=       Run Process  st2  run  packs.uninstall  packs\=examples  -j
    Should Contain X Times   ${result.stdout}  "status": "succeeded  3
    Should Contain   ${result.stdout}    "action": "packs.unload"
    Should Contain   ${result.stdout}    "action": "packs.delete"
    ${result}=       Run Process    st2  action  list  -p  examples
    Should Contain   ${result.stdout}  No matching items found

KEYWORD:Delete st2.webhook_sample.out
    ${result}=       Run Process  sudo  rm  -rf  /home/stanley/st2.webhook_sample.out  shell=True
    File Should Not Exist   /home/stanley/st2.webhook_sample.out
    Log To Console   FILE DELETED\n

KEYWORD:Check Tail
    ${result}=  Run Process  sudo  tail  -n  1  /home/stanley/st2.webhook_sample.out  shell=True
    Should Contain   ${result.stdout}     {u'foo': u'bar', u'name': u'st2'}
    [return]    ${result}

TEARDOWN:Clean Files
    Log To Console   ___________________________SUITE TEARDOWN________________________
    Log To Console   _________________________________________________________________\n
    Run Keyword      KEYWORD:Delete st2.webhook_sample.out
    Log To Console   ___________________________SUITE TEARDOWN________________________
    Log To Console   _________________________________________________________________\n
