#    Amazon DynamoDB SQL Library - an Amazon DynamoDB testing library with SQL-like DSL.
#    Copyright (C) 2014 - 2023  Richard Huang <rickypc@users.noreply.github.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

*** Settings ***
Resource        ${CURDIR}${/}..${/}resources${/}common.robot

*** Variables ***
${LABEL} =      local
${REGION} =     us-west-2

*** Test Cases ***
Session Exists
    [Documentation]  Can validate session existance, otherwise throw an error
    Run Keyword And Expect Error
    ...  Non-existing index or alias '${LABEL}'.
    ...  Query DynamoDB  ${LABEL}  CREATE TABLE session (id STRING HASH KEY)
    Suite Prepare
    Query DynamoDB  ${LABEL}  CREATE TABLE session (id STRING HASH KEY)
    Query DynamoDB  ${LABEL}  DROP TABLE session
    Suite Cleanup

Session Does Not Exist
    [Documentation]  Can validate session non-existance, otherwise throw an error
    Suite Prepare
    Query DynamoDB  ${LABEL}  CREATE TABLE session (id STRING HASH KEY)
    Query DynamoDB  ${LABEL}  DROP TABLE session
    Suite Cleanup
    Run Keyword And Expect Error
    ...  Non-existing index or alias '${LABEL}'.
    ...  Query DynamoDB  ${LABEL}  CREATE TABLE session (id STRING HASH KEY)

Session Exists With Default Label
    [Documentation]  Can validate session with default label existance, otherwise throw an error
    Suite Prepare  ${EMPTY}
    Query DynamoDB  ${REGION}  CREATE TABLE session (id STRING HASH KEY)
    Query DynamoDB  ${REGION}  DROP TABLE session
    Suite Cleanup

Session Exists With All Default Values
    [Documentation]  Can validate session with all default values existance, otherwise throw an error
    ${port} =  Convert To Integer  8000
    Create DynamoDB Session  host=127.0.0.1  port=${port}  is_secure=${false}
    Query DynamoDB  us-east-1  CREATE TABLE session (id STRING HASH KEY)
    Query DynamoDB  us-east-1  DROP TABLE session
    Suite Cleanup

Session Exists With Default Keys
    [Documentation]  Can validate session with default keys existance, otherwise throw an error
    ${port} =  Convert To Integer  8000
    Create DynamoDB Session  ${REGION}  host=127.0.0.1  port=${port}  is_secure=${false}
    Query DynamoDB  ${REGION}  CREATE TABLE session (id STRING HASH KEY)
    Query DynamoDB  ${REGION}  DROP TABLE session
    Suite Cleanup

Session Exists With Specified Profile
    [Documentation]  Can validate session with specified profile existance, otherwise throw an error
    ${port} =  Convert To Integer  8000
    Create DynamoDB Session  profile=profile1  host=127.0.0.1  port=${port}  is_secure=${false}
    Query DynamoDB  us-west-1  CREATE TABLE session (id STRING HASH KEY)
    Query DynamoDB  us-west-1  DROP TABLE session
    Suite Cleanup

Session Is Removed
    [Documentation]  Can remove existing session, otherwise throw an error
    Suite Prepare
    Suite Prepare  local1
    Delete DynamoDB Session  ${LABEL}
    Run Keyword And Expect Error
    ...  Non-existing index or alias '${LABEL}'.
    ...  Query DynamoDB  ${LABEL}  CREATE TABLE session (id STRING HASH KEY)
    Query DynamoDB  local1  CREATE TABLE session (id STRING HASH KEY)
    Query DynamoDB  local1  DROP TABLE session
    Suite Cleanup

Multi Sessions Query Context
    [Documentation]  Can executes query across multiple sessions
    ${expected_frankfurt} =  Set Variable  [{"id":"frankfurt","bar":1},{"id":"frankfurt","bar":2}]
    ${expected_oregon} =  Set Variable  [{"id":"oregon","bar":1},{"id":"oregon","bar":2}]
    ${expected_singapore} =  Set Variable  [{"id":"singapore","bar":1},{"id":"singapore","bar":2}]

    Session Should Not Exist  oregon
    Session Should Not Exist  singapore
    Session Should Not Exist  frankfurt

    Create Session  oregon  us-west-2
    Create Session  singapore  ap-southeast-1
    Create Session  frankfurt  eu-central-1

    Provision Session Table  oregon
    Session Table Should Be  oregon  2  ${expected_oregon}
    DynamoDB Table Should Not Exist  singapore  session
    DynamoDB Table Should Not Exist  frankfurt  session

    Provision Session Table  singapore
    Session Table Should Be  oregon  2  ${expected_oregon}
    Session Table Should Be  singapore  2  ${expected_singapore}
    DynamoDB Table Should Not Exist  frankfurt  session

    Provision Session Table  frankfurt
    Session Table Should Be  oregon  2  ${expected_oregon}
    Session Table Should Be  singapore  2  ${expected_singapore}
    Session Table Should Be  frankfurt  2  ${expected_frankfurt}

    Query DynamoDB  oregon  DROP TABLE session
    DynamoDB Table Should Not Exist  oregon  session
    Session Table Should Be  singapore  2  ${expected_singapore}
    Session Table Should Be  frankfurt  2  ${expected_frankfurt}

    Query DynamoDB  singapore  DROP TABLE session
    DynamoDB Table Should Not Exist  oregon  session
    DynamoDB Table Should Not Exist  singapore  session
    Session Table Should Be  frankfurt  2  ${expected_frankfurt}

    Query DynamoDB  frankfurt  DROP TABLE session
    DynamoDB Table Should Not Exist  oregon  session
    DynamoDB Table Should Not Exist  singapore  session
    DynamoDB Table Should Not Exist  frankfurt  session

    Suite Cleanup

    Session Should Not Exist  oregon
    Session Should Not Exist  singapore
    Session Should Not Exist  frankfurt

*** Keywords ***
Create Session
    [Arguments]  ${label}  ${region}
    [Documentation]  Create DynamoDB session base on specified label and region
    ${port} =  Convert To Integer  8000
    Create DynamoDB Session  ${region}  host=127.0.0.1  port=${port}
    ...  access_key=key  secret_key=secret  is_secure=${false}  label=${label}

Provision Session Table
    [Arguments]  ${label}
    [Documentation]  Create session table and insert with default rows
    Query DynamoDB  ${label}  CREATE TABLE session (id STRING HASH KEY, bar NUMBER RANGE KEY)
    DynamoDB Table Should Exist  ${label}  session
    ${response} =  Query DynamoDB  ${label}
    ...  INSERT INTO session (id, bar) VALUES ('${label}', 1), ('${label}', 2)
    Should Be Equal As Strings  ${response}  2

Session Table Should Be
    [Arguments]  ${label}  ${total}  ${expected}
    [Documentation]  Validate session table should match expected
    DynamoDB Table Should Exist  ${label}  session
    @{actual} =  Query DynamoDB  ${label}  SCAN * FROM session
    Length Should Be  ${actual}  ${total}
    List And JSON String Should Be Equal  ${actual}  ${expected}

Session Should Not Exist
    [Arguments]  ${label}
    [Documentation]  Validate session does not exist
    Run Keyword And Expect Error
    ...  Non-existing index or alias '${label}'.
    ...  Query DynamoDB  ${label}  CREATE TABLE session (id STRING HASH KEY)
