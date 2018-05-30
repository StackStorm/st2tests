# **integration_packs_doc.rst**: This test suite covers same functionality as: `test_packs_pack.yaml <https://github.com/StackStorm/st2tests/blob/master/packs/tests/actions/chains/test_packs_pack.yaml>`_.

*** Test Cases ***
TEST:Verify packs are not present before a clean install
    ${result}=          Run Process    st2  action  list  --pack  ${PACK TO INSTALL 1}  --pack  ${PACK TO INSTALL 2}  -j
    # Process Log To Console     ${result}
    Should Not Contain  ${result.stdout}  ${PACK VAR 1}
    Should Not Contain  ${result.stdout}  ${PACK VAR 2}


TEST:NEW-Verify multiple packs can be installed from repo
    ${result}=          Run Process  st2  pack  install  ${PACK TO INSTALL 1}  ${PACK TO INSTALL 2}
    Process Log To Console     ${result}
    Should Not Contain  ${result.stdout}   ${FAIL STATUS}
    Should Not Contain  ${result.stdout}   ${TIMEOUT STATUS}
    Should Contain      ${result.stdout}   For the \"${PACK TO INSTALL 1}, ${PACK TO INSTALL 2}\" packs, the following content will be registered:
    Should Contain      ${result.stdout}   Installation may take a while for packs with many items.
    Should Contain      ${result.stdout}   rules     \|
    Should Contain      ${result.stdout}   sensors   \|
    Should Contain      ${result.stdout}   aliases   \|
    Should Contain      ${result.stdout}   actions   \|
    Should Contain      ${result.stdout}   triggers  \|
    ${result}=          Run Process    st2  action  list  --pack  ${PACK TO INSTALL 1}  -j
    Process Log To Console     ${result}
    Should Contain      ${result.stdout}  ${PACK VAR 1}
    # Process Log To Console    ${result}
    ${result}=          Run Process    st2  action  list  --pack  ${PACK TO INSTALL 2}  -j
    Should Contain      ${result.stdout}  ${PACK VAR 2}


TEST:NEW-Verify multiple packs can be removed
    ${result}=          Run Process  st2  pack  remove  ${PACK TO INSTALL 1}  ${PACK TO INSTALL 2}  -j
    # Log To Console     \nUninstalling Pack: ${PACK TO INSTALL 1} and ${PACK TO INSTALL 2} :\n${result.stdout}

    [Documentation]     Verify packs were uninstalled successfully in previous test step
    ${result}=          Run Process    st2  action  list  --pack  ${PACK TO INSTALL 1}  --pack  ${PACK TO INSTALL 2}  -j
    # Process Log To Console  ${result.stdout}
    Should Not Contain  ${result.stdout}  ${PACK VAR 1}
    Should Not Contain  ${result.stdout}  ${PACK VAR 2}
    Should Contain      ${result.stdout}  No matching items found


TEST:OLD-Verify packs can be downloaded using packs.download
    ${result}=          Run Process    st2  run  packs.download  packs\=${PACK TO INSTALL 1}  -j
    # Process Log To Console  ${result}
    Should Contain      ${result.stdout}  ${SUCCESS STATUS}
    Should Contain      ${result.stdout}  ${PACK 1 SUCCESS}


TEST:OLD-Verify "packs.setup_virtualenv" for a pack downloaded in previous step
    ${result}=          Run Process  st2  run  packs.setup_virtualenv  packs\=${PACK TO INSTALL 1}   -j
    Should Contain      ${result.stdout}  "result": "Successfuly set up virtualenv for the following packs: ${PACK TO INSTALL 1}"
    Should Contain      ${result.stdout}  ${SUCCESS STATUS}


TEST:NEW-Verify "packs register" to register all packs
    ${result}=          Run Process  st2  pack  register  -j
    Should Contain      ${result.stdout}  "actions":
    Should Contain      ${result.stdout}  "aliases":
    Should Contain      ${result.stdout}  "configs":
    Should Contain      ${result.stdout}  "policies":
    Should Contain      ${result.stdout}  "policy_types":
    Should Contain      ${result.stdout}  "rule_types":
    Should Contain      ${result.stdout}  "rules":
    Should Contain      ${result.stdout}  "runners":
    Should Contain      ${result.stdout}  "sensors":
    Should Contain      ${result.stdout}  "triggers":


TEST:OLD-Verify pack install with no config
    ${result}=          Run Process  st2  run  packs.download  packs\=${PACK TO INSTALL NO CONFIG}  -j
    Should Contain      ${result.stdout}  "${PACK TO INSTALL NO CONFIG}": "Success."
    # Should Contain      ${result.stdout}  DEBUG${SPACE*3}Moving pack from /root/st2contrib/packs/${PACK TO INSTALL NO CONFIG} to /opt/stackstorm/packs/.${\n}

TEST:OLD-Verify pack reinstall with no Config
    ${result}=          Run Process  st2  run  packs.download  packs\=${PACK TO INSTALL NO CONFIG}  -j
    Should Contain      ${result.stdout}  "${PACK TO INSTALL NO CONFIG}": "Success."
    # Should Contain      ${result.stdout}  DEBUG${SPACE*3}Removing existing pack bitcoin in /opt/stackstorm/packs/${PACK TO INSTALL NO CONFIG} to replace.${\n}

TEST:Verify "packs.setup_virtualenv" with python3 flag works
    ${result}=          Run Process  st2  run  packs.setup_virtualenv packs\=examples   python3\=true   -j
    Should Contain      ${result.stdout}  "result": "Successfuly set up virtualenv for the following packs: examples"
    Should Contain      ${result.stdout}  ${SUCCESS STATUS}
    ${result}=          Run Process  /opt/stackstorm/virtualenvs/examples/bin/python  --version
    Should Contain      ${result.stdout}  "Python 3."

TEST:Verify Python 3 virtual environment works
    ${result}=          Run Process  st2  run  examples.python_runner_print_python_version
    Should Contain      ${result.stdout}  "Using Python executable: /opt/stackstorm/virtualenvs/examples/bin/python"
    Should Contain      ${result.stdout}  "Using Python version: 3."
    Should Contain      ${result.stdout}  ${SUCCESS STATUS}

*** Keywords ***
SETUP:Check Installation Pack 1
    Log To Console    ___________________________SUITE SETUP___________________________
    ${result}=        Run Process    st2  action  list  --pack  ${PACK TO INSTALL 1}  -j
    # Log To Console    STDOUT:\n ${result.stdout}
    Run Keyword If    '${PACK VAR 1}' in '''${result.stdout}'''  KEYWORD:OLD-Uninstall Pack 1
    ...       ELSE    KEYWORD:Check Installation Pack 2
    Log To Console    ___________________________SUITE SETUP___________________________\n


KEYWORD:OLD-Uninstall Pack 1
    ${result}=        Run Process  st2  run  packs.uninstall  packs\=${PACK TO INSTALL 1}  -j
    # Log To Console    Uninstalling Pack: ${PACK TO INSTALL 1} :\n${result.stdout}
    Run Keyword       KEYWORD:Check Installation Pack 2

KEYWORD:Check Installation Pack 2
    ${result}=        Run Process    st2  action  list  --pack  ${PACK TO INSTALL 2}  -j
    # Log To Console    STDOUT:\n ${result.stdout}
    Run Keyword If    '${PACK VAR 2}' in '''${result.stdout}'''  KEYWORD:NEW-Uninstall Pack 2

KEYWORD:NEW-Uninstall Pack 2
    ${result}=        Run Process  st2  pack  remove  ${PACK TO INSTALL 2}  -j
    # Log To Console    Uninstalling Pack: ${PACK TO INSTALL 2} :\n${result.stdout}

TEARDOWN:Suite Cleanup
    Log To Console    ___________________________SUITE TEARDOWN___________________________
    Run Keyword       SETUP:Check Installation Pack 1
    ${result}=        Run Process  st2  run  packs.delete  packs\=${PACK TO INSTALL NO CONFIG}  -j
    # Log To Console    ${result.stdout}
    Should Contain    ${result.stdout}  ${SUCCESS STATUS}
    # Should Contain    ${result.stdout}  DEBUG${SPACE*3}Deleting pack directory "/opt/stackstorm/packs/${PACK TO INSTALL NO CONFIG}"${\n}
    Log To Console    ___________________________SUITE TEARDOWN___________________________\n

*** Settings ***
Library             Process
Variables           variables/integration_packs_doc.yaml
Resource            ../common/keywords.robot
Suite Setup         SETUP:Check Installation Pack 1
Suite Teardown      TEARDOWN:Suite Cleanup
