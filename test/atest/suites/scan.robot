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
Suite Setup     Scan Suite Prepare
Suite Teardown  Suite Cleanup With Default Table

*** Variables ***
${LABEL} =      local
${REGION} =     us-west-2

*** Test Cases ***
Scan Table
    [Documentation]  Can scan a table
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM foobar
    Length Should Be  ${actual}  2
    ${expected} =  Set Variable  [{"id":"a","bar":1},{"id":"b","bar":2}]
    List And JSON String Should Be Equal  ${actual}  ${expected}

Scan Filter
    [Documentation]  Can scan a table with FILTER
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM foobar WHERE id='a'
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":"a","bar":1}]
    List And JSON String Should Be Equal  ${actual}  ${expected}

Scan Limit
    [Documentation]  Can scan a table with LIMIT
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM foobar LIMIT 1
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":"b","bar":2}]
    List And JSON String Should Be Equal  ${actual}  ${expected}

Scan Begins With
    [Documentation]  Can scan a table with BEGINS WITH
    Query DynamoDB  ${LABEL}  CREATE TABLE begins-with (id NUMBER HASH KEY, bar STRING RANGE KEY)
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO begins-with (id, bar) VALUES (1, 'abc'), (1, 'def')
    Should Be Equal As Strings  ${response}  2
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM begins-with WHERE id=1 AND begins_with(bar, 'a')
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":1,"bar":"abc"}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS begins-with

Scan Between
    [Documentation]  Can scan a table with BETWEEN
    Query DynamoDB  ${LABEL}  CREATE TABLE between (id STRING HASH KEY, bar NUMBER RANGE KEY)
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO between (id, bar) VALUES ('a', 5), ('a', 10)
    Should Be Equal As Strings  ${response}  2
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM between WHERE id='a' AND bar BETWEEN 1 AND 8
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":"a","bar":5}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS between

Scan Null Attribute
    [Documentation]  Can scan a table with IS NULL
    Query DynamoDB  ${LABEL}  CREATE TABLE null (id STRING HASH KEY, bar NUMBER RANGE KEY)
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO null (id, bar) VALUES ('a', 5)
    Should Be Equal As Strings  ${response}  1
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO null (id, bar, baz) VALUES ('a', 1, 1)
    Should Be Equal As Strings  ${response}  1
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM null WHERE id='a' AND attribute_not_exists(baz)
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":"a","bar":5}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS null

Scan Not Null Attribute
    [Documentation]  Can scan a table with IS NOT NULL
    Query DynamoDB  ${LABEL}  CREATE TABLE not-null (id STRING HASH KEY, bar NUMBER RANGE KEY)
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO not-null (id, bar) VALUES ('a', 5)
    Should Be Equal As Strings  ${response}  1
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO not-null (id, bar, baz) VALUES ('a', 1, 1)
    Should Be Equal As Strings  ${response}  1
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM not-null WHERE id='a' AND attribute_exists(baz)
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":"a","bar":1,"baz":1}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS not-null

Scan In Attribute
    [Documentation]  Can scan a table with IN
    Query DynamoDB  ${LABEL}  CREATE TABLE filter-in (id STRING HASH KEY, bar NUMBER RANGE KEY, baz NUMBER)
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO filter-in (id, bar, baz) VALUES ('a', 5, 1), ('a', 2, 4)
    Should Be Equal As Strings  ${response}  2
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM filter-in WHERE id='a' AND baz IN (1, 3, 5)
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":"a","bar":5,"baz":1}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS filter-in

Scan Contains
    [Documentation]  Can scan a table with CONTAINS
    Query DynamoDB  ${LABEL}  CREATE TABLE contains (id STRING HASH KEY, bar NUMBER RANGE KEY)
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO contains (id, bar, baz) VALUES ('a', 5, (1, 2, 3)), ('a', 1, (4, 5, 6))
    Should Be Equal As Strings  ${response}  2
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM contains WHERE id='a' AND contains(baz, 2)
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":"a","bar":5,"baz":{"py/set":[1,2,3]}}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS contains

Scan Does Not Contain
    [Documentation]  Can scan a table with NOT CONTAINS
    Query DynamoDB  ${LABEL}  CREATE TABLE not-contains (id STRING HASH KEY, bar NUMBER RANGE KEY)
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO not-contains (id, bar, baz) VALUES ('a', 5, (1, 2, 3)), ('a', 1, (4, 5, 6))
    Should Be Equal As Strings  ${response}  2
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM not-contains WHERE id='a' AND NOT contains(baz, 5)
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":"a","bar":5,"baz":{"py/set":[1,2,3]}}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS not-contains

Scan And Filter
    [Documentation]  Can scan a table with AND multi-conditional FILTER
    Query DynamoDB  ${LABEL}  CREATE TABLE filter-and (id STRING HASH KEY, bar NUMBER RANGE KEY)
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO filter-and (id, foo, bar) VALUES ('a', 1, 1), ('b', 1, 2)
    Should Be Equal As Strings  ${response}  2
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM filter-and WHERE foo=1 AND bar=1
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":"a","foo":1,"bar":1}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS filter-and

Scan Or Filter
    [Documentation]  Can scan a table with OR multi-conditional FILTER
    Query DynamoDB  ${LABEL}  CREATE TABLE filter-or (id STRING HASH KEY, bar NUMBER RANGE KEY)
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO filter-or (id, foo, bar) VALUES ('a', 1, 1), ('b', 2, 2)
    Should Be Equal As Strings  ${response}  2
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM filter-or WHERE foo=1 OR bar=2
    Length Should Be  ${actual}  2
    ${expected} =  Set Variable  [{"id":"a","foo":1,"bar":1},{"id":"b","foo":2,"bar":2}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS filter-or

*** Keywords ***
Scan Suite Prepare
    Suite Prepare With Default Table
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO foobar (id, bar) VALUES ('a', 1), ('b', 2)
    Should Be Equal As Strings  ${response}  2
