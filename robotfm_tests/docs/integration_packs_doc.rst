**integration_packs_doc.rst**: This test suite covers same functionality as: `test_packs_pack.yaml <https://github.com/StackStorm/st2tests/blob/master/packs/tests/actions/chains/test_packs_pack.yaml>`_.


.. code:: robotframework

    *** Test Cases ***
    Verify packs are not present before a clean install
        ${result}=          Run Process    st2  action  list  --pack  ${PACK TO INSTALL 1}  --pack  ${PACK TO INSTALL 2}  -j
        # Log To Console     CHECK: ${result.stdout}
        Should Not Contain  ${result.stdout}  ${PACK VAR 1}
        Should Not Contain  ${result.stdout}  ${PACK VAR 2}


    Verify multiple packs can be installed from repo
        ${result}=          Run Process  st2 pack install  ${PACK TO INSTALL 1} ${PACK TO INSTALL 2}  repo_url\=${BASE REPO URL}/${INSTALL FROM REPO}
        # Log To Console     \nINSTALL: ${result.stdout}
        Should Not Contain  ${result.stdout}   ${FAIL STATUS}
        ${result}=          Run Process    st2  action  list  --pack  ${PACK TO INSTALL 1}  -j
        # Log To Console     \nLIST: ${result.stdout}
        Should Contain      ${result.stdout}  ${PACK VAR 1}
        # Log To Console      \nLIST: ${result.stdout}
        ${result}=          Run Process    st2  action  list  --pack  ${PACK TO INSTALL 2}  -j
        Should Contain      ${result.stdout}  ${PACK VAR 2}


    Verify multiple packs can be uninstalled
        ${result}=          Run Process  st2 pack remove  ${PACK TO INSTALL 1} ${PACK TO INSTALL 2}
        # Log To Console     \nUninstalling Pack: ${PACK TO INSTALL 1} and ${PACK TO INSTALL 2} :\n${result.stdout}

        [Documentation]     Verify packs were uninstalled successfully in previous test step
        ${result}=          Run Process    st2  action  list  --pack  ${PACK TO INSTALL 1}  --pack  ${PACK TO INSTALL 2}  -j
        # Log To Console     \nCHECK: ${result.stdout}
        Should Not Contain  ${result.stdout}  ${PACK VAR 1}
        Should Not Contain  ${result.stdout}  ${PACK VAR 2}
        Should Contain      ${result.stdout}  No matching items found


    Verify "st2 pack register" works
        ${result}=          Run Process  st2  pack register
        Should Contain      ${result.stdout}  "failed": false,
        Should Contain      ${result.stdout}  "return_code": 0,


    Verify pack install with no config
        ${result}=          Run Process  st2 pack install ${PACK TO INSTALL NO CONFIG}
        Should Contain      ${result.stdout}  "${PACK TO INSTALL NO CONFIG}": "Success."
        # Should Contain      ${result.stdout}  DEBUG${SPACE*3}Moving pack from /root/st2contrib/packs/${PACK TO INSTALL NO CONFIG} to /opt/stackstorm/packs/.${\n}

    Verify pack reinstall with no Config
        ${result}=          Run Process  st2 pack install ${PACK TO INSTALL NO CONFIG}
        Should Contain      ${result.stdout}  "${PACK TO INSTALL NO CONFIG}": "Success."

    *** Keywords ***
    Check Installation Pack 1
        Log To Console    ___________________________SUITE SETUP___________________________
        ${result}=        Run Process    st2  action  list  --pack  ${PACK TO INSTALL 1}  -j
        # Log To Console    STDOUT:\n ${result.stdout}
        Run Keyword If    '${PACK VAR 1}' in '''${result.stdout}'''  Uninstall Pack 1
        ...       ELSE    Check Installation Pack 2
        Log To Console    ___________________________SUITE SETUP___________________________


    Uninstall Pack 1
        ${result}=        Run Process  st2  pack remove ${PACK TO INSTALL 1}  -j
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
        Log To Console    ___________________________SUITE TEARDOWN___________________________
        Run Keyword       Check Installation Pack 1
        ${result}=        Run Process  st2  run  packs.delete  packs\=${PACK TO INSTALL NO CONFIG}  -j
        # Log To Console    ${result.stdout}
        Should Contain    ${result.stdout}  ${SUCCESS STATUS}
        # Should Contain    ${result.stdout}  DEBUG${SPACE*3}Deleting pack directory "/opt/stackstorm/packs/${PACK TO INSTALL NO CONFIG}"${\n}
        Log To Console    ___________________________SUITE TEARDOWN___________________________

    *** Settings ***
    Library             Process
    Variables           variables/integration_packs_doc.yaml
    Suite Setup         Check Installation Pack 1
    Suite Teardown      Suite Cleanup
