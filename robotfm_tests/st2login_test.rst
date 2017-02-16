*** Test Cases ***
Attempt to log in using "st2 login"
    ${result}=         Run Process        st2 login st2admin --password Ch@ngeMe
    Log To Console     \n${result.stdout}
    Should Contain     ${result.stdout}   Successfully logged in as st2admin

Try running an action as the logged-in user
    ${result}=         Run Process        st2 run core.local 
    Log To Console     \n${result.stdout}
    Should Contain     ${result.stdout}   succeeded: true
