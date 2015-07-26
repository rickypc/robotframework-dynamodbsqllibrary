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
Resource        ${CURDIR}${/}..${/}resources${/}common.robot
Suite Setup     Suite Prepare
Suite Teardown  Suite Cleanup

*** Variables ***
${LABEL} =      local
${REGION} =     us-west-2

*** Test Cases ***
Schema Dumps Equal
    [Documentation]  Can compare schema dumps equality
    DynamoDB Dumps Should Be Equal
    ...  CREATE TABLE x (id STRING HASH KEY, THROUGHPUT (2, 6))
    ...  CREATE TABLE x (THROUGHPUT (2, 6), id STRING HASH KEY)

Throw Error When Schema Dumps Not Equal
    [Documentation]  Should throw an error when schema dumps not equal
    Run Keyword And Expect Error  DynamoDBSQLLibraryError: Table schema dumps are different
    ...  DynamoDB Dumps Should Be Equal
    ...  CREATE TABLE x (id STRING HASH KEY, THROUGHPUT (2, 6), bar NUMBER RANGE KEY)
    ...  CREATE TABLE x (id STRING HASH KEY, THROUGHPUT (2, 6), baz NUMBER RANGE KEY)

Table Exists
    [Documentation]  Can validate table existance, otherwise throw an error
    Run Keyword And Expect Error
    ...  DynamoDBSQLLibraryError: Table 'exists' does not exist in the requested DynamoDB session
    ...  DynamoDB Table Should Exist  ${LABEL}  exists
    Query DynamoDB  ${LABEL}  CREATE TABLE exists (id STRING HASH KEY)
    DynamoDB Table Should Exist  ${LABEL}  exists
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS exists

Table Does Not Exist
    [Documentation]  Can validate table non existance, otherwise throw an error
    Query DynamoDB  ${LABEL}  CREATE TABLE non-exists (id STRING HASH KEY)
    Run Keyword And Expect Error
    ...  DynamoDBSQLLibraryError: Table 'non-exists' exists in the requested DynamoDB session
    ...  DynamoDB Table Should Not Exist  ${LABEL}  non-exists
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS non-exists
    DynamoDB Table Should Not Exist  ${LABEL}  non-exists
