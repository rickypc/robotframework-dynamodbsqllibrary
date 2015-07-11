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
Suite Setup     Suite Prepare With Default Table
Suite Teardown  Suite Cleanup With Default Table

*** Variables ***
${LABEL} =      local
${REGION} =     us-west-2

*** Test Cases ***
Select Hash Key
    [Documentation]  Can select with filter by hash key
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO foobar (id, bar) VALUES ('a', 1), ('b', 2)
    Should Be Equal  ${response}  Inserted 2 items
    @{actual} =  Query DynamoDB  ${LABEL}  SELECT * FROM foobar WHERE id='a'
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":"a","bar":1}]
    List And JSON String Should Be Equal  ${actual}  ${expected}

Select Hash And Range Keys
    [Documentation]  Can select with filter by hash and range keys
    Query DynamoDB  ${LABEL}  CREATE TABLE range (id STRING HASH KEY, bar NUMBER RANGE KEY)
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO range (id, bar) VALUES ('a', 1), ('b', 2)
    Should Be Equal  ${response}  Inserted 2 items
    @{actual} =  Query DynamoDB  ${LABEL}  SELECT * FROM range WHERE id='a' AND bar=1
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":"a","bar":1}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS range

Select Keys In
    [Documentation]  Can fetch items directly with KEYS IN
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO foobar (id, bar) VALUES ('e', 1), ('f', 2)
    Should Be Equal  ${response}  Inserted 2 items
    @{actual} =  Query DynamoDB  ${LABEL}  SELECT * FROM foobar WHERE KEYS IN ('e', 1), ('f', 2)
    Length Should Be  ${actual}  2
    ${expected} =  Set Variable  [{"id":"e","bar":1},{"id":"f","bar":2}]
    List And JSON String Should Be Equal  ${actual}  ${expected}

Select With Reverse Order
    [Documentation]  Can select with reverse order results
    Query DynamoDB  ${LABEL}  CREATE TABLE reverse (id STRING HASH KEY, bar NUMBER RANGE KEY)
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO reverse (id, bar) VALUES ('a', 1), ('a', 2)
    Should Be Equal  ${response}  Inserted 2 items
    @{actual_asc} =  Query DynamoDB  ${LABEL}  SELECT * FROM reverse WHERE id='a' ASC
    @{actual_desc} =  Query DynamoDB  ${LABEL}  SELECT * FROM reverse WHERE id='a' DESC
    Length Should Be  ${actual_asc}  2
    Length Should Be  ${actual_desc}  2
    ${expected_asc} =  Set Variable  [{"id":"a","bar":1},{"id":"a","bar":2}]
    ${expected_desc} =  Set Variable  [{"id":"a","bar":2},{"id":"a","bar":1}]
    List And JSON String Should Be Equal  ${actual_asc}  ${expected_asc}
    List And JSON String Should Be Equal  ${actual_desc}  ${expected_desc}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS reverse

Select Hash Index
    [Documentation]  Can select with filter by indexes
    Query DynamoDB  ${LABEL}
    ...  CREATE TABLE indexes (id STRING HASH KEY, bar NUMBER RANGE KEY, ts NUMBER INDEX('ts-index'))
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO indexes (id, bar, ts) VALUES ('a', 1, 100), ('a', 2, 200)
    Should Be Equal  ${response}  Inserted 2 items
    @{actual} =  Query DynamoDB  ${LABEL}
    ...  SELECT * FROM indexes WHERE id='a' AND ts < 150 USING 'ts-index'
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":"a","bar":1,"ts":100}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS indexes

Select Smart Index
    [Documentation]  Can select with correct index
    Query DynamoDB  ${LABEL}
    ...  CREATE TABLE smart-index (id STRING HASH KEY, bar NUMBER RANGE KEY, ts NUMBER INDEX('ts-index'))
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO smart-index (id, bar, ts) VALUES ('a', 1, 100), ('a', 2, 200)
    Should Be Equal  ${response}  Inserted 2 items
    @{actual} =  Query DynamoDB  ${LABEL}
    ...  SELECT * FROM smart-index WHERE id='a' AND ts < 150
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":"a","bar":1,"ts":100}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS smart-index

Select Smart Global Index
    [Documentation]  Can select with correct global index
    ${commands} =  Catenate  CREATE TABLE smart-global
    ...  (id STRING HASH KEY, foo STRING RANGE KEY, bar NUMBER INDEX('bar-index'), baz STRING)
    ...  GLOBAL INDEX ('baz-index', baz)
    Query DynamoDB  ${LABEL}  ${commands}
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO smart-global (id, foo, bar, baz) VALUES ('a', 'a', 1, 'a'), ('b', 'b', 2, 'b')
    Should Be Equal  ${response}  Inserted 2 items
    @{actual} =  Query DynamoDB  ${LABEL}  SELECT * FROM smart-global WHERE baz='a'
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":"a","foo":"a","bar":1,"baz":"a"}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS smart-global

Select Limit
    [Documentation]  Can select with limit
    Query DynamoDB  ${LABEL}
    ...  CREATE TABLE limit (id STRING HASH KEY, bar NUMBER RANGE KEY, ts NUMBER INDEX('ts-index'))
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO limit (id, bar, ts) VALUES ('a', 1, 100), ('a', 2, 200)
    Should Be Equal  ${response}  Inserted 2 items
    @{actual} =  Query DynamoDB  ${LABEL}  SELECT * FROM limit WHERE id='a' LIMIT 1
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":"a","bar":1,"ts":100}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS limit

Select Attributes
    [Documentation]  Can select certain attributes
    Query DynamoDB  ${LABEL}
    ...  CREATE TABLE attributes (id STRING HASH KEY, bar NUMBER RANGE KEY)
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO attributes (id, bar, order) VALUES ('a', 1, 'first'), ('a', 2, 'second')
    Should Be Equal  ${response}  Inserted 2 items
    @{actual} =  Query DynamoDB  ${LABEL}
    ...  SELECT order FROM attributes WHERE id='a' AND bar=1
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"order":"first"}]
    List And JSON String Should Be Equal  ${actual}  ${expected}  order
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS attributes

Select Begins With
    [Documentation]  Can select with BEGINS WITH filter
    Query DynamoDB  ${LABEL}
    ...  CREATE TABLE begins-with (id NUMBER HASH KEY, bar STRING RANGE KEY)
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO begins-with (id, bar) VALUES (1, 'abc'), (1, 'def')
    Should Be Equal  ${response}  Inserted 2 items
    @{actual} =  Query DynamoDB  ${LABEL}
    ...  SELECT * FROM begins-with WHERE id=1 AND bar BEGINS WITH 'a'
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":1,"bar":"abc"}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS begins-with

Select Between
    [Documentation]  Can select with BETWEEN filter
    Query DynamoDB  ${LABEL}
    ...  CREATE TABLE between (id STRING HASH KEY, bar NUMBER RANGE KEY)
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO between (id, bar) VALUES ('a', 5), ('a', 10)
    Should Be Equal  ${response}  Inserted 2 items
    @{actual} =  Query DynamoDB  ${LABEL}
    ...  SELECT * FROM between WHERE id='a' AND bar BETWEEN (1, 8)
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":"a","bar":5}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS between

Select Filter
    [Documentation]  Can select with FILTER
    Query DynamoDB  ${LABEL}
    ...  CREATE TABLE filter (id STRING HASH KEY, bar NUMBER RANGE KEY)
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO filter (id, bar, baz) VALUES ('a', 1, 1), ('a', 2, 2)
    Should Be Equal  ${response}  Inserted 2 items
    @{actual} =  Query DynamoDB  ${LABEL}
    ...  SELECT * FROM filter WHERE id='a' FILTER baz=1
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":"a","bar":1,"baz":1}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS filter

Select And Filter
    [Documentation]  Can select with AND multi-conditional FILTER
    Query DynamoDB  ${LABEL}
    ...  CREATE TABLE filter-and (id STRING HASH KEY, bar NUMBER RANGE KEY)
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO filter-and (id, foo, bar, baz) VALUES ('a', 1, 1, 1), ('a', 2, 2, 1)
    Should Be Equal  ${response}  Inserted 2 items
    @{actual} =  Query DynamoDB  ${LABEL}
    ...  SELECT * FROM filter-and WHERE id='a' FILTER baz=1 AND foo=1
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":"a","foo":1,"bar":1,"baz":1}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS filter-and

Select Or Filter
    [Documentation]  Can select with OR multi-conditional FILTER
    Query DynamoDB  ${LABEL}
    ...  CREATE TABLE filter-or (id STRING HASH KEY, bar NUMBER RANGE KEY)
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO filter-or (id, foo, bar, baz) VALUES ('a', 1, 1, 1), ('a', 2, 2, 2)
    Should Be Equal  ${response}  Inserted 2 items
    @{actual} =  Query DynamoDB  ${LABEL}
    ...  SELECT * FROM filter-or WHERE id='a' FILTER baz=1 OR foo=2
    Length Should Be  ${actual}  2
    ${expected} =  Set Variable
    ...  [{"id":"a","foo":1,"bar":1,"baz":1},{"id":"a","foo":2,"bar":2,"baz":2}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS filter-or

Select Same Key Filter
    [Documentation]  Can not filter on the same key twice
    ${expected} =  Set Variable  SyntaxError: Cannot use a field more than once in a FILTER clause
    Run Keyword And Expect Error  ${expected}  Query DynamoDB  ${LABEL}
    ...  SELECT * FROM foobar WHERE id='a' FILTER foo=1 OR foo=2
