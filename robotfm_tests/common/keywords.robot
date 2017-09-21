*** Variables ***
${SUCCESS STATUS}    "status": "succeeded

*** Keyword ***
Process Log To Console
    [Arguments]    ${result}
    Log            \n\n______________DEBUG LOG___________________\n__________________________________________\n----------\nLOG_STDOUT:\n----------\n ${result.stdout}\n----------\nLOG_STDERR:\n----------\n ${result.stderr}\n----------\nLOG_STDRC: \n----------\n ${result.rc}\n___________________________________________\n_________________END LOG___________________\n\n  console=True

SETUP:Copy and Load Examples Pack
    Log To Console   ___________________________SUITE SETUP___________________________
    Log To Console   _________________________________________________________________
    ${result}=    Run Process     sudo  cp  \-r  /usr/share/doc/st2/examples/  /opt/stackstorm/packs/
    Should Be Equal As Integers   ${result.rc}  0
    # Copy Directory   /usr/share/doc/st2/examples/   /opt/stackstorm/packs/
    Directory Should Exist        /opt/stackstorm/packs/examples/
    ${result}=    Run Process     st2  run  packs.setup_virtualenv  packs\=examples  -j
    Should Contain                ${result.stdout}  ${SUCCESS STATUS}
    ${result}=    Run Process     st2ctl  reload  \-\-register\-all
    Log To Console    \nSETUP:\n
    Process Log To Console  ${result}
    Log To Console   ___________________________SUITE SETUP___________________________
    Log To Console   _________________________________________________________________\n

SETUP:Copy and Load Examples Pack and Enable Streaming
    Log To Console   ___________________________SUITE SETUP___________________________
    Log To Console   _________________________________________________________________
    ${result}=    Run Process     sudo  crudini  \-\-set  /etc/st2/st2.conf  actionrunner  stream_output  'True'
    ${result}=    Run Process     sudo  st2ctl  restart
    ${result}=    Run Process     sudo  cp  \-r  /usr/share/doc/st2/examples/  /opt/stackstorm/packs/
    Should Be Equal As Integers   ${result.rc}  0
    # Copy Directory   /usr/share/doc/st2/examples/   /opt/stackstorm/packs/
    Directory Should Exist        /opt/stackstorm/packs/examples/
    ${result}=    Run Process     st2  run  packs.setup_virtualenv  packs\=examples  -j
    Should Contain                ${result.stdout}  ${SUCCESS STATUS}
    ${result}=    Run Process     st2ctl  reload  \-\-register\-all
    Log To Console    \nSETUP:\n
    Process Log To Console  ${result}
    Log To Console   ___________________________SUITE SETUP___________________________
    Log To Console   _________________________________________________________________\n

TEARDOWN:Uninstall Examples Pack
    Log To Console   ___________________________SUITE TEARDOWN_________________________
    Log To Console   __________________________________________________________________
    ${result}=                   Run Process  st2  run  packs.uninstall  packs\=examples  -j
    Should Contain X Times       ${result.stdout}  ${SUCCESS STATUS}  3
    Directory Should Not Exist  /opt/stackstorm/packs/examples/
    Log To Console   ___________________________SUITE TEARDOWN_________________________
    Log To Console   __________________________________________________________________\n
