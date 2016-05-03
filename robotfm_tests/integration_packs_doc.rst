**integration_packs_doc.rst** verifies functionality provided by doc at: `Getting a Pack <http://docs.stackstorm.com/packs.html#getting-a-pack>`_

.. code:: robotframework

    *** Variables ***
    ${BASE REPO URL}               https://github.com/StackStorm
    ${PACK TO INSTALL 1}           libcloud
    ${PACK TO INSTALL 2}           chef
    ${PACK TO INSTALL NO CONFIG}   bitcoin
    ${INSTALL FROM REPO}           st2contrib
    ${PACK VAR 1}                  "pack": "${PACK TO INSTALL 1}"
    ${PACK VAR 2}                  "pack": "${PACK TO INSTALL 2}"
    ${FAIL STATUS}                 "status": "failed"
    ${SUCCESS STATUS}              "status": "succeeded"
    ${PACK 1 SUCCESS}              "${PACK TO INSTALL 1}": "Success."

    *** Test Cases ***
    Verify packs are not present for clean install
        ${result}=          Run Process    st2  action  list  --pack  ${PACK TO INSTALL 1}  --pack  ${PACK TO INSTALL 2}  -j
        # Log To Console     CHECK: ${result.stdout}
        Should Not Contain  ${result.stdout}  ${PACK VAR 1}
        Should Not Contain  ${result.stdout}  ${PACK VAR 2}


    Test packs install multiple packs from repo
        ${result}=          Run Process  st2  run  packs.install  packs\=${PACK TO INSTALL 1},${PACK TO INSTALL 2}  repo_url\=${BASE REPO URL}/${INSTALL FROM REPO}  -j
        Log To Console      INSTALL: ${result.stdout}
        Should Not Contain  ${result.stdout}   ${FAIL STATUS}
        ${result}=          Run Process    st2  action  list  --pack  ${PACK TO INSTALL 1}  -j
        # Log To Console      LIST: ${result.stdout}
        Should Contain      ${result.stdout}  ${PACK VAR 1}
        # Log To Console      LIST: ${result.stdout}
        ${result}=          Run Process    st2  action  list  --pack  ${PACK TO INSTALL 2}  -j
        Should Contain      ${result.stdout}  ${PACK VAR 2}


     Test packs uninstall multiple packs
        ${result}=          Run Process  st2  run  packs.uninstall  packs\=${PACK TO INSTALL 1},${PACK TO INSTALL 2}  -j
        Log To Console      Uninstalling Pack: ${PACK TO INSTALL 1} and ${PACK TO INSTALL 2} :\n${result.stdout}


     Verify packs are properly uninstalled
         ${result}=          Run Process    st2  action  list  --pack  ${PACK TO INSTALL 1}  --pack  ${PACK TO INSTALL 2}  -j
         # Log To Console    CHECK: ${result.stdout}
         Should Not Contain  ${result.stdout}  ${PACK VAR 1}
         Should Not Contain  ${result.stdout}  ${PACK VAR 2}
         Should Contain      ${result.stdout}  No matching items found


     Test Packs Download
         ${result}=          Run Process    st2  run  packs.download  packs\=${PACK TO INSTALL 1}  -j
         Log To Console      DOWNLOAD: ${result.stdout}
         Should Contain      ${result.stdout}  ${SUCCESS STATUS}
         Should Contain      ${result.stdout}  ${PACK 1 SUCCESS}


     Test Packs Setup Virtualenv
         ${result}=          Run Process  st2  run  packs.setup_virtualenv  packs\=${PACK TO INSTALL 1}   -j
         Should Contain      ${result.stdout}  "result": "Successfuly set up virtualenv for the following packs: ${PACK TO INSTALL 1}"
         Should Contain      ${result.stdout}  ${SUCCESS STATUS}


     Test Packs Load Register All
         ${result}=          Run Process  st2  run  packs.load  register\=all  -j
         Should Contain      ${result.stdout}  "failed": false,
         Should Contain      ${result.stdout}  "return_code": 0,


     Test Pack Install With No Config
         ${result}=          Run Process  st2  run  packs.download  packs\=${PACK TO INSTALL NO CONFIG}  -j
         Should Contain      ${result.stdout}  "${PACK TO INSTALL NO CONFIG}": "Success."
         # Should Contain      ${result.stdout}  DEBUG${SPACE*3}Moving pack from /root/st2contrib/packs/${PACK TO INSTALL NO CONFIG} to /opt/stackstorm/packs/.${\n}

     Test Pack Reinstall With No Config
         ${result}=          Run Process  st2  run  packs.download  packs\=${PACK TO INSTALL NO CONFIG}  -j
         Should Contain      ${result.stdout}  "${PACK TO INSTALL NO CONFIG}": "Success."
         # Should Contain      ${result.stdout}  DEBUG${SPACE*3}Removing existing pack bitcoin in /opt/stackstorm/packs/${PACK TO INSTALL NO CONFIG} to replace.${\n}




    *** Keywords ***
    Check Installation Pack 1
        Log To Console    "###### Suite Setup/Teardown ######"
        ${result}=        Run Process    st2  action  list  --pack  ${PACK TO INSTALL 1}  -j
        # Log To Console    STDOUT:\n ${result.stdout}
        Run Keyword If    '${PACK VAR 1}' in '''${result.stdout}'''  Uninstall Pack 1
        ...       ELSE    Check Installation Pack 2


    Uninstall Pack 1
        ${result}=        Run Process  st2  run  packs.uninstall  packs\=${PACK TO INSTALL 1}  -j
        # Log To Console    Uninstalling Pack: ${PACK TO INSTALL 1} :\n${result.stdout}
        Run Keyword       Check Installation Pack 2

    Check Installation Pack 2
        ${result}=        Run Process    st2  action  list  --pack  ${PACK TO INSTALL 2}  -j
        # Log To Console    STDOUT:\n ${result.stdout}
        Run Keyword If    '${PACK VAR 2}' in '''${result.stdout}'''  Uninstall Pack 2

    Uninstall Pack 2
        ${result}=        Run Process  st2  run  packs.uninstall  packs\=${PACK TO INSTALL 2}  -j
        # Log To Console    Uninstalling Pack: ${PACK TO INSTALL 2} :\n${result.stdout}

    Suite Cleanup
        Run Keyword       Check Installation Pack 1
        ${result}=        Run Process  st2  run  packs.delete  packs\=${PACK TO INSTALL NO CONFIG}  -j
        # Log To Console    ${result.stdout}
        Should Contain      ${result.stdout}  ${SUCCESS STATUS}
        # Should Contain    ${result.stdout}  DEBUG${SPACE*3}Deleting pack directory "/opt/stackstorm/packs/${PACK TO INSTALL NO CONFIG}"${\n}


    *** Settings ***
    Library             Process
    Suite Setup         Check Installation Pack 1
    Suite Teardown      Suite Cleanup
