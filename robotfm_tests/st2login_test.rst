.. code:: robotframework

    *** Settings ***
    Library          Process
    Library          String 
    Library      OperatingSystem 
 
    *** Test Cases ***
    Verify st2 is installed
    ${result}=         Run Process        st2  --version
    Log To Console     \nOUTPUT: ${result.stdout}

    Attempt to log in using "st2 login"
    ${result}=         Run Process        st2  login  st2admin  --password  Ch@ngeMe
        Log To Console     \n${result.stdout}
        Should Contain     ${result.stdout}   Logged in as st2admin

    Try running an action as the logged-in user
        ${result}=         Run Process        st2  run  core.local  date
        Log To Console     \n${result.stdout}
        Should Contain     ${result.stdout}   succeeded: true

