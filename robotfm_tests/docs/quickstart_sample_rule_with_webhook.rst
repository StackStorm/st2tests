.. code:: robotframework

    *** Variables ***
    ${PACK EXAMPLES}        "pack": "examples"
    ${UID SAMPLE WEBHOOK}   "uid": "rule:examples:sample_rule_with_webhook"
    ${REF SAMPLE WEBHOOK}   "ref": "examples.sample_rule_with_webhook"
    ${ENABLED}          "enabled": true
    ${DISABLED}         "enabled": false

    *** Test Cases ***
    Verify rule creation
        ${result}=       Run Process    st2  rule  create  /usr/share/doc/st2/examples/rules/sample_rule_with_webhook.yaml  -j
        Log To Console   \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        Should Contain   ${result.stdout}  ${UID SAMPLE WEBHOOK}
        Should Contain   ${result.stdout}  ${ENABLED}

        ${result}=       Run Process    st2  rule  get  examples.sample_rule_with_webhook   -j
        Should Contain   ${result.stdout}  ${UID SAMPLE WEBHOOK}
        Should Contain   ${result.stdout}  ${ENABLED}

        ${result}=       Run Process    st2  rule  list  --pack  examples  -j
        Should Contain   ${result.stdout}  ${REF SAMPLE WEBHOOK}
        Should Contain   ${result.stdout}  ${PACK EXAMPLES}
        Should Contain   ${result.stdout}  ${ENABLED}

    Verify rule disable/enable
        ${result}=       Run Process    st2  rule  disable  examples.sample_rule_with_webhook   -j
        Should Contain   ${result.stdout}  ${UID SAMPLE WEBHOOK}
        Should Contain   ${result.stdout}  ${DISABLED}
        ${result}=       Run Process    st2  rule  enable  examples.sample_rule_with_webhook   -j
        Should Contain   ${result.stdout}  ${UID SAMPLE WEBHOOK}
        Should Contain   ${result.stdout}  ${ENABLED}

    Verify error message for duplicate rule
        ${result}=       Run Process    st2  rule  create  /usr/share/doc/st2/examples/rules/sample_rule_with_webhook.yaml  -j
        Should Contain   ${result.stdout}  ERROR: 409 Client Error: Conflict
        Should Contain   ${result.stdout}  MESSAGE: Tried to save duplicate unique keys
        Should Contain   ${result.stdout}  duplicate key error index: st2.rule_d_b.$uid_1  dup key: { : "rule:examples:sample_rule_with_webhook" }) for url:

    Verify rule status
        ${TOKEN}=        Run Process    st2  auth  -p  Ch@ngeMe  st2admin  -t  shell=True
        Log To Console   \nTOKEN: ${TOKEN.stdout} \nSTDERR: ${TOKEN.stderr} \nRC ${TOKEN.rc}
        ${result}=       Run  curl -k https://localhost/api/v1/webhooks/sample -d '{"foo": "bar", "name": "st2"}' -H 'Content-Type: application/json' -H 'X-Auth-Token: ${TOKEN.stdout}'
        Log To Console   \nOUTPUT: ${result}
        Should Contain   ${result}      {"foo": "bar", "name": "st2"}
        ${result}=       Run  sudo tail -n 1 /home/stanley/st2.webhook_sample.out
        Should Contain   ${result}     {'foo': 'bar', 'name': 'st2'
        ${result}=       Run  sudo rm -rf /home/stanley/st2.webhook_sample.out
        File Should Not Exist   /home/stanley/st2.webhook_sample.out

    Verify rule deletion(and error message)
        ${result}=       Run Process    st2  rule  delete  examples.sample_rule_with_webhook  -j
        Should Contain   ${result.stdout}  Resource with id "examples.sample_rule_with_webhook" has been successfully deleted
        ${result}=       Run Process    st2  rule  list  --pack  examples  -j
        Should Contain   ${result.stdout}  No matching items found
        ${result}=       Run Process    st2  rule  delete  examples.sample_rule_with_webhook  -j
        Should Contain   ${result.stdout}  Rule "examples.sample_rule_with_webhook" is not found.

    Verify examples pack installation and setup
        ${result}=       Run Process    sudo  cp  -r  /usr/share/doc/st2/examples/  /opt/stackstorm/packs/
        Directory Should Exist  /opt/stackstorm/packs/examples
        ${result}=       Run Process    st2  run  packs.setup_virtualenv  packs\=examples  -j
        Should Contain   ${result.stdout}  "result": "Successfuly set up virtualenv for the following packs: examples"
        Should Contain   ${result.stdout}  "status": "succeeded"
        ${result}=       Run Process    st2  action  list  -p  examples
        Should Contain   ${result.stdout}  No matching items found
        ${result}=       Run Process  st2ctl  reload  --register-all
        Log To Console   \nSTDOUT: ${result.stdout} \nSTDERR: ${result.stderr} \nRC ${result.rc}
        ${result}=       Run Process    st2  action  list  -p  examples  -j
        Should Contain   ${result.stdout}  ${PACK EXAMPLES}

    Verify examples pack uninstall
        ${result}=       Run Process  st2  run  packs.uninstall  packs\=examples  -j
        Should Contain X Times   ${result.stdout}  "status": "succeeded  4
        Should Contain   ${result.stdout}    "action": "packs.unload"
        Should Contain   ${result.stdout}    "action": "packs.delete"
        Should Contain   ${result.stdout}    "action": "packs.restart_component"
        ${result}=       Run Process    st2  action  list  -p  examples
        Should Contain   ${result.stdout}  No matching items found

    *** Settings ***
    Library            Process
    Library            OperatingSystem
    Suite Setup        Check examples pack

    *** Keywords ***
    Check examples pack
        [Documentation]  This is only for CI setup
        ${result}=       Run Process    st2  action  list  -p  examples
        Run Keyword Unless  '''${result.stdout}''' == 'No matching items found'    Remove the examples pack
    Remove the examples pack
        ${result}=       Run Process  st2  run  packs.uninstall  packs\=examples  -j
        Should Contain X Times   ${result.stdout}  "status": "succeeded  4
        Should Contain   ${result.stdout}    "action": "packs.unload"
        Should Contain   ${result.stdout}    "action": "packs.delete"
        Should Contain   ${result.stdout}    "action": "packs.restart_component"
        ${result}=       Run Process    st2  action  list  -p  examples
        Should Contain   ${result.stdout}  No matching items found
