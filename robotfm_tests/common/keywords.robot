*** Keyword ***
Process Log To Console
    [Arguments]    ${result}
    Log            \n\n______________DEBUG LOG___________________\n__________________________________________\n----------\nLOG_STDOUT:\n----------\n ${result.stdout}\n----------\nLOG_STDERR:\n----------\n ${result.stderr}\n----------\nLOG_STDRC: \n----------\n ${result.rc}\n___________________________________________\n_________________END LOG___________________\n\n\n  console=True
