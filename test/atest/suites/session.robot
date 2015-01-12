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
Resource        atest/resources/common.robot

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
