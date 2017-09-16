*** Keyword ***
Process Log To Console
    [Arguments]    ${result}
    Log            \n______________DEBUG LOG___________________\n__________________________________________\n\n----------\nLOG_STDOUT:\n----------\n ${result.stdout}\n----------\nLOG_STDERR:\n----------\n ${result.stderr}\n----------\nLOG_STDRC: \n----------\n ${result.rc}\n___________________________________________\n_________________END LOG___________________\n\n  console=True
