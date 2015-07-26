*** Settings ***
Resource        ${CURDIR}${/}..${/}resources${/}common.robot
Suite Setup     Suite Prepare
Suite Teardown  Suite Cleanup

*** Variables ***
${LABEL} =      local
${REGION} =     us-west-2

*** Test Cases ***
Create Table
    [Documentation]  Can create a table
    ${commands} =  Catenate  CREATE TABLE create
    ...  (owner STRING HASH KEY, id BINARY RANGE KEY, ts NUMBER INDEX('ts-index'))
    Query DynamoDB  ${LABEL}  ${commands}
    ${actual} =  Query DynamoDB  ${LABEL}  DUMP SCHEMA create
    ${expected} =  Catenate  CREATE TABLE create
    ...  (owner STRING HASH KEY, id BINARY RANGE KEY, ts NUMBER ALL INDEX('ts-index'),
    ...  THROUGHPUT (5, 5));
    Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS create

Create Table With Throughput
    [Documentation]  Can create a table with specified throughput
    Query DynamoDB  ${LABEL}  CREATE TABLE throughput (id STRING HASH KEY, THROUGHPUT (1, 2))
    ${actual} =  Query DynamoDB  ${LABEL}  DUMP SCHEMA throughput
    ${expected} =  Set Variable  CREATE TABLE throughput (id STRING HASH KEY, THROUGHPUT (1, 2));
    Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS throughput

Create Table If Not Exists
    [Documentation]  Can create a table if not exists should not throw exception 
    Query DynamoDB  ${LABEL}  CREATE TABLE not-exists (id STRING HASH KEY)
    DynamoDB Table Should Exist  ${LABEL}  not-exists
    Query DynamoDB  ${LABEL}  CREATE TABLE IF NOT EXISTS not-exists (id STRING HASH KEY)
    DynamoDB Table Should Exist  ${LABEL}  not-exists
    ${actual} =  Query DynamoDB  ${LABEL}  DUMP SCHEMA not-exists
    ${expected} =  Set Variable  CREATE TABLE not-exists (id STRING HASH KEY, THROUGHPUT (5, 5));
    Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS not-exists

Create Table With Keys Index
    [Documentation]  Can create a table with specified throughput
    ${commands} =  Catenate  CREATE TABLE keys-index (owner STRING HASH KEY,
    ...  id BINARY RANGE KEY, ts NUMBER KEYS INDEX('ts-index'))
    Query DynamoDB  ${LABEL}  ${commands}
    ${actual} =  Query DynamoDB  ${LABEL}  DUMP SCHEMA keys-index
    ${expected} =  Catenate  CREATE TABLE keys-index (owner STRING HASH KEY,
    ...  id BINARY RANGE KEY, ts NUMBER KEYS INDEX('ts-index'), THROUGHPUT (5, 5));
    Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS keys-index

Create Table Include Index
    [Documentation]  Can create a table with include index
    ${commands} =  Catenate  CREATE TABLE include-index (owner STRING HASH KEY,
    ...  id BINARY RANGE KEY, ts NUMBER INCLUDE INDEX('ts-index', ['foo', 'bar']))
    Query DynamoDB  ${LABEL}  ${commands}
    ${actual} =  Query DynamoDB  ${LABEL}  DUMP SCHEMA include-index
    ${expected} =  Catenate  CREATE TABLE include-index (owner STRING HASH KEY,
    ...  id BINARY RANGE KEY, ts NUMBER INCLUDE INDEX('ts-index', ['foo', 'bar']),
    ...  THROUGHPUT (5, 5));
    Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS include-index

Create Table Global Index
    [Documentation]  Can create a table with global indexes
    ${commands} =  Catenate  CREATE TABLE global-indexes (id STRING HASH KEY,
    ...  foo NUMBER RANGE KEY) GLOBAL INDEX ('global-index', foo, id, THROUGHPUT (1, 2))
    Query DynamoDB  ${LABEL}  ${commands}
    ${actual} =  Query DynamoDB  ${LABEL}  DUMP SCHEMA global-indexes
    ${expected} =  Catenate  CREATE TABLE global-indexes (id STRING HASH KEY,
    ...  foo NUMBER RANGE KEY, THROUGHPUT (5, 5))
    ...  GLOBAL ALL INDEX ('global-index', foo, id, THROUGHPUT (1, 2));
    Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS global-indexes

Create Table Global Index Without Range Key
    [Documentation]  Can create a table without range key with global indexes
    ${commands} =  Catenate  CREATE TABLE no-range (id STRING HASH KEY,
    ...  foo NUMBER) GLOBAL INDEX ('global-index', foo, THROUGHPUT (1, 2))
    Query DynamoDB  ${LABEL}  ${commands}
    ${actual} =  Query DynamoDB  ${LABEL}  DUMP SCHEMA no-range
    ${expected} =  Catenate  CREATE TABLE no-range (id STRING HASH KEY,
    ...  foo NUMBER, THROUGHPUT (5, 5))
    ...  GLOBAL ALL INDEX ('global-index', foo, THROUGHPUT (1, 2));
    Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS no-range

Create Table Global Keys Index
    [Documentation]  Can create a table with global keys index
    ${commands} =  Catenate  CREATE TABLE global-keys (id STRING HASH KEY,
    ...  foo NUMBER) GLOBAL KEYS INDEX ('global-index', foo, THROUGHPUT (1, 2))
    Query DynamoDB  ${LABEL}  ${commands}
    ${actual} =  Query DynamoDB  ${LABEL}  DUMP SCHEMA global-keys
    ${expected} =  Catenate  CREATE TABLE global-keys (id STRING HASH KEY,
    ...  foo NUMBER, THROUGHPUT (5, 5))
    ...  GLOBAL KEYS INDEX ('global-index', foo, THROUGHPUT (1, 2));
    Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS global-keys

Create Table Global Include Index
    [Documentation]  Can create a table with global include index
    ${commands} =  Catenate  CREATE TABLE global-include (id STRING HASH KEY,
    ...  foo NUMBER) GLOBAL INCLUDE INDEX ('global-index', foo, ['bar', 'baz'],
    ...  THROUGHPUT (1, 2))
    Query DynamoDB  ${LABEL}  ${commands}
    ${actual} =  Query DynamoDB  ${LABEL}  DUMP SCHEMA global-include
    ${expected} =  Catenate  CREATE TABLE global-include (id STRING HASH KEY,
    ...  foo NUMBER, THROUGHPUT (5, 5))
    ...  GLOBAL INCLUDE INDEX ('global-index', foo, ['bar', 'baz'], THROUGHPUT (1, 2));
    Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DROP TABLE IF EXISTS global-include
