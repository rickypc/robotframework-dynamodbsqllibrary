#    Amazon DynamoDB SQL Library - an Amazon DynamoDB testing library with SQL-like DSL.
#    Copyright (C) 2014 - 2015  Richard Huang <rickypc@users.noreply.github.com>
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
Library  ${CURDIR}${/}..${/}..${/}..${/}src${/}DynamoDBSQLLibrary

*** Keywords ***
Return Value Should Be
    [Arguments]  ${commands}  ${message}  ${filter}  ${expected}
    ...  ${name}=foobar  ${label}=local  ${key}=id
    ${response} =  Query DynamoDB  ${label}  ${commands}
    Should Be Equal  ${response}  ${message}
    @{actual} =  Query DynamoDB  ${label}
    ...  SELECT * FROM ${name} WHERE ${key}='${filter}'
    List And JSON String Should Be Equal  ${actual}  ${expected}

Suite Cleanup
    [Documentation]  Remove all DynamoDB sessions
    Delete All DynamoDB Sessions

Suite Cleanup With Default Table
    [Arguments]  ${name}=foobar  ${label}=local
    [Documentation]  Delete default table and all DynamoDB sessions
    Query DynamoDB  ${label}  DROP TABLE IF EXISTS ${name}
    Suite Cleanup

Suite Prepare
    [Arguments]  ${label}=local  ${host}=127.0.0.1  ${port}=8000  ${secure}=${false}
    [Documentation]  Create DynamoDB session
    Log  ${label}
    ${is_secure} =  Convert To Boolean  ${secure}
    ${port_number} =  Convert To Integer  ${port}
    Run Keyword If  '${label}' == '${EMPTY}'  Create DynamoDB Session  ${REGION}
    ...  host=${host}  port=${port_number}  access_key=key  secret_key=secret
    ...  is_secure=${is_secure}
    Run Keyword Unless  '${label}' == '${EMPTY}'  Create DynamoDB Session  ${REGION}
    ...  host=${host}  port=${port_number}  access_key=key  secret_key=secret
    ...  is_secure=${is_secure}  label=${label}

Suite Prepare With Default Table
    [Arguments]  ${name}=foobar  ${label}=local  ${host}=127.0.0.1  ${port}=8000  ${secure}=${false}
    [Documentation]  Create DynamoDB session and create default table in it
    Suite Prepare  ${label}  ${host}  ${port}  ${secure}
    Query DynamoDB  ${label}  CREATE TABLE ${name} (id STRING HASH KEY)
