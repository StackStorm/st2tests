# **integration_packs_doc.rst**: This test suite covers same functionality as: `test_packs_pack.yaml <https://github.com/StackStorm/st2tests/blob/master/packs/tests/actions/chains/test_packs_pack.yaml>`_.

*** Test Cases ***

TEST:Verify "pack install" with python3 flag works
    ${result}=          Run Process  st2  pack  install  examples  --python3
    Should Contain      ${result.stdout}  "examples": "Success."
    Should Contain      ${result.stdout}  ${SUCCESS STATUS}
    ${result}=          Run Process  /opt/stackstorm/virtualenvs/examples/bin/python  --version
    Should Contain      ${result.stdout}  "Python 3."


TEST:Verify Python 3 virtual environment works
    ${result}=          Run Process  st2  run  examples.python_runner_print_python_version
    Should Contain      ${result.stdout}  "Using Python executable: /opt/stackstorm/virtualenvs/examples/bin/python"
    Should Contain      ${result.stdout}  "Using Python version: 3."
    Should Contain      ${result.stdout}  ${SUCCESS STATUS}

*** Settings ***
Library         Process
Library         String
Library         OperatingSystem
Resource        ../common/keywords.robot
Suite Setup     SETUP:Copy and Load Examples Pack
Suite Teardown  TEARDOWN:Uninstall Examples Pack
