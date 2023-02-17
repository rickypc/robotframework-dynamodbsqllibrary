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
Suite Setup     Suite Prepare With Default Table
Suite Teardown  Suite Cleanup With Default Table

*** Variables ***
${LABEL} =      local
${REGION} =     us-west-2

*** Test Cases ***
Alter Throughput
    [Documentation]  Can alter table throughput
    Query DynamoDB  ${LABEL}
    ...  CREATE TABLE throughput (id STRING HASH KEY, THROUGHPUT (1, 1))
    Query DynamoDB  ${LABEL}  ALTER TABLE throughput SET THROUGHPUT (2, 2)
    ${actual} =  Query DynamoDB  ${LABEL}  DUMP SCHEMA throughput
    ${expected} =  Set Variable
    ...  CREATE TABLE throughput (id STRING HASH KEY, THROUGHPUT (2, 2));
    Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS throughput

Alter Throughput Partially
    [Documentation]  Can alter table throughput partially on read or write only
    Query DynamoDB  ${LABEL}
    ...  CREATE TABLE throughput-partial (id STRING HASH KEY, THROUGHPUT (1, 1))
    Query DynamoDB  ${LABEL}  ALTER TABLE throughput-partial SET THROUGHPUT (2, 1)
    ${actual} =  Query DynamoDB  ${LABEL}  DUMP SCHEMA throughput-partial
    ${expected} =  Set Variable
    ...  CREATE TABLE throughput-partial (id STRING HASH KEY, THROUGHPUT (2, 1));
    Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS throughput-partial

Alter Throughput Star
    [Documentation]  Can alter table throughput partially on read or write only using '*'
    Query DynamoDB  ${LABEL}
    ...  CREATE TABLE throughput-star (id STRING HASH KEY, THROUGHPUT (1, 1))
    Query DynamoDB  ${LABEL}  ALTER TABLE throughput-star SET THROUGHPUT (2, *)
    ${actual} =  Query DynamoDB  ${LABEL}  DUMP SCHEMA throughput-star
    ${expected} =  Set Variable
    ...  CREATE TABLE throughput-star (id STRING HASH KEY, THROUGHPUT (2, 1));
    Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS throughput-star

Alter Index Throughput
    [Documentation]  Can alter table global index
    ${commands} =  Catenate  CREATE TABLE throughput-index (id STRING HASH KEY, foo NUMBER)
    ...  GLOBAL INDEX ('foo_index', foo, THROUGHPUT (1, 1))
    Query DynamoDB  ${LABEL}  ${commands}
    Query DynamoDB  ${LABEL}  ALTER TABLE throughput-index SET INDEX foo_index THROUGHPUT (2, 2)
    ${actual} =  Query DynamoDB  ${LABEL}  DUMP SCHEMA throughput-index
    ${expected} =  Catenate  CREATE TABLE throughput-index
    ...  (id STRING HASH KEY, foo NUMBER, THROUGHPUT (0, 0))GLOBAL ALL INDEX ('foo_index', foo, THROUGHPUT (2, 2));
    Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS throughput-index

Drop Table
    [Documentation]  Can drop table
    Query DynamoDB  ${LABEL}  CREATE TABLE drop-table (id STRING HASH KEY)
    DynamoDB Table Should Exist  ${LABEL}  drop-table
    Query DynamoDB  ${LABEL}  DROP TABLE drop-table
    DynamoDB Table Should Not Exist  ${LABEL}  drop-table

Drop Table If Exists
    [Documentation]  Can drop table if exists should not throw exception
    Query DynamoDB  ${LABEL}  CREATE TABLE drop-table-if-exists (id STRING HASH KEY)
    DynamoDB Table Should Exist  ${LABEL}  drop-table-if-exists
    Query DynamoDB  ${LABEL}  DROP TABLE drop-table-if-exists
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS drop-table-if-exists
    DynamoDB Table Should Not Exist  ${LABEL}  drop-table-if-exists

Insert Multi Rows
    [Documentation]  Can insert multi rows at once
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO foobar (id, bar) VALUES ('a', 1), ('b', 1)
    Should Be Equal As Strings  ${response}  2
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM foobar
    Length Should Be  ${actual}  2
    ${expected} =  Set Variable  [{"id":"a","bar":1},{"id":"b","bar":1}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS foobar

Insert Binary Hash Key
    [Documentation]  Can insert binary hash key
    Query DynamoDB  ${LABEL}  CREATE TABLE binary (id BINARY HASH KEY)
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO binary (id) VALUES (b'a')
    Should Be Equal As Strings  ${response}  1
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM binary
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":{"py/boto3.dynamodb.types.Binary":"a"}}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS binary

Count Rows
    [Documentation]  Can count rows in DynamoDB table
    Query DynamoDB  ${LABEL}  CREATE TABLE count (id STRING HASH KEY, bar NUMBER RANGE KEY)
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO count (id, bar) VALUES ('a', 1), ('a', 2)
    Should Be Equal As Strings  ${response}  2
    ${actual} =  Query DynamoDB  ${LABEL}  SELECT count(*) FROM count WHERE id='a'
    Should Be Equal  '${actual}'  'Count(2)'
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS count

Count Smart Index
    [Documentation]  Can count with correct index
    Query DynamoDB  ${LABEL}
    ...  CREATE TABLE smart (id STRING HASH KEY, bar NUMBER RANGE KEY, ts NUMBER INDEX('ts-index'))
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO smart (id, bar, ts) VALUES ('a', 1, 100), ('a', 2, 200)
    Should Be Equal As Strings  ${response}  2
    ${actual} =  Query DynamoDB  ${LABEL}  SELECT count(*) FROM smart WHERE id='a' AND ts < 150
    Should Be Equal  '${actual}'  'Count(1)'
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS smart

Count Filter
    [Documentation]  Can use conditional filter on results
    Query DynamoDB  ${LABEL}
    ...  CREATE TABLE filter (id STRING HASH KEY, bar NUMBER RANGE KEY)
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO filter (id, foo, bar) VALUES ('a', 1, 1), ('a', 2, 2)
    Should Be Equal As Strings  ${response}  2
    ${actual} =  Query DynamoDB  ${LABEL}  SELECT count(*) FROM filter WHERE id='a' AND foo=1
    Should Be Equal  '${actual}'  'Count(1)'
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS filter

Delete From Table
    [Documentation]  Can delete rows
    ${commands} =  Catenate  CREATE TABLE delete-table
    ...  (id STRING HASH KEY, bar NUMBER RANGE KEY, ts NUMBER INDEX('ts-index'))
    Query DynamoDB  ${LABEL}  ${commands}
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO delete-table (id, bar) VALUES ('a', 1), ('b', 2)
    Should Be Equal As Strings  ${response}  2
    Query DynamoDB  ${LABEL}  DELETE FROM delete-table WHERE id='a' AND bar=1
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM delete-table
    ${expected} =  Set Variable  [{"id":"b","bar":2}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS delete-table

Delete From Table With KEYS IN Filter
    [Documentation]  Can delete rows with KEYS IN filter
    ${commands} =  Catenate  CREATE TABLE delete-table-in
    ...  (id STRING HASH KEY, bar NUMBER RANGE KEY, ts NUMBER INDEX('ts-index'))
    Query DynamoDB  ${LABEL}  ${commands}
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO delete-table-in (id, bar) VALUES ('a', 1), ('b', 2)
    Should Be Equal As Strings  ${response}  2
    Query DynamoDB  ${LABEL}  DELETE FROM delete-table-in KEYS IN ('a', 1)
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM delete-table-in
    ${expected} =  Set Variable  [{"id":"b","bar":2}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS delete-table-in

Delete From Table With Smart Index
    [Documentation]  Can delete rows with correct index
    ${commands} =  Catenate  CREATE TABLE delete-table-index
    ...  (id STRING HASH KEY, bar NUMBER RANGE KEY, ts NUMBER INDEX('ts-index'))
    Query DynamoDB  ${LABEL}  ${commands}
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO delete-table-index (id, bar, ts) VALUES ('a', 1, 100), ('a', 2, 200)
    Should Be Equal As Strings  ${response}  2
    Query DynamoDB  ${LABEL}  DELETE FROM delete-table-index WHERE id='a' AND ts > 150
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM delete-table-index
    ${expected} =  Set Variable  [{"id":"a","bar":1,"ts":100}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS delete-table-index

Delete From Table Using Specific Index
    [Documentation]  Can delete rows using specific index
    ${commands} =  Catenate  CREATE TABLE delete-table-using
    ...  (id STRING HASH KEY, bar NUMBER RANGE KEY, ts NUMBER INDEX('ts-index'))
    Query DynamoDB  ${LABEL}  ${commands}
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO delete-table-using (id, bar, ts) VALUES ('a', 1, 100), ('a', 2, 200)
    Should Be Equal As Strings  ${response}  2
    Query DynamoDB  ${LABEL}  DELETE FROM delete-table-using WHERE id='a' AND ts > 150 USING ts-index
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM delete-table-using
    ${expected} =  Set Variable  [{"id":"a","bar":1,"ts":100}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS delete-table-using

Dump Schema
    [Documentation]  Can dump table schema
    ${commands} =  Catenate  CREATE TABLE dump (id STRING HASH KEY, bar NUMBER RANGE KEY,
    ...  ts NUMBER INDEX('ts-index'), baz STRING KEYS INDEX('baz-index'),
    ...  bag NUMBER INCLUDE INDEX('bag-index', ['foo']), THROUGHPUT (2, 6))
    ...  GLOBAL INDEX ('my-index', bar, baz, THROUGHPUT (1, 2))
    ...  GLOBAL KEYS INDEX ('my-keys', id, THROUGHPUT (1, 2))
    Query DynamoDB  ${LABEL}  ${commands}
    ${actual} =  Query DynamoDB  ${LABEL}  DUMP SCHEMA dump
    Query DynamoDB  ${LABEL}  DROP TABLE dump
    Query DynamoDB  ${LABEL}  ${actual}
    ${expected} =  Query DynamoDB  ${LABEL}  DUMP SCHEMA dump
    DynamoDB Dumps Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE dump

Multiple Statements
    [Documentation]  Can execute multiple statements separated by ';'
    ${commands} =  Catenate  CREATE TABLE multiple (id STRING HASH KEY);
    ...  INSERT INTO multiple (id, foo) VALUES ('a', 1), ('b', 2);
    ...  SCAN * FROM multiple
    @{actual} =  Query DynamoDB  ${LABEL}  ${commands}
    ${expected} =  Set Variable  [{"id":"a","foo":1},{"id":"b","foo":2}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS multiple

Get Session Host
    [Documentation]  Can get session host endpoint URL
    ${response} =  DynamoDB Host  ${LABEL}
    Should Be Equal  ${response}  http://127.0.0.1:8000

Get Session Region
    [Documentation]  Can get session region
    ${response} =  DynamoDB Region  ${LABEL}
    Should Be Equal  ${response}  ${REGION}

List Tables
    [Documentation]  Can list all tables
    ${commands} =  Catenate  CREATE TABLE something1 (id STRING HASH KEY);
    ...  CREATE TABLE thing1 (id STRING HASH KEY);
    Query DynamoDB  ${LABEL}  ${commands}
    @{actual} =  List DynamoDB Tables  ${LABEL}  ExclusiveStartTableName=some  Limit=1
    ${expected} =  Set Variable  ["something1"]
    ${order_number} =  Convert To Integer  0
    List And JSON String Should Be Equal  ${actual}  ${expected}  ${order_number}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS something1
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS thing1
