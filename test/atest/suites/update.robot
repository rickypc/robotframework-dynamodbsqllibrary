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
Update Table
    [Documentation]  Can update attribute sets in a table
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO foobar (id, bar, baz) VALUES ('a', 1, 1), ('b', 2, 2)
    Should Be Equal As Strings  ${response}  2
    Query DynamoDB  ${LABEL}  UPDATE foobar SET baz=3
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM foobar
    Length Should Be  ${actual}  2
    ${expected} =  Set Variable  [{"id":"a","bar":1,"baz":3},{"id":"b","bar":2,"baz":3}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DELETE FROM foobar WHERE id = 'a'
    Query DynamoDB  ${LABEL}  DELETE FROM foobar WHERE id = 'b'

Update Table Where
    [Documentation]  Can update attribute sets in a table with WHERE clause
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO foobar (id, bar, baz) VALUES ('a', 1, 1), ('b', 2, 2)
    Should Be Equal As Strings  ${response}  2
    Query DynamoDB  ${LABEL}  UPDATE foobar SET baz=3 WHERE id='a'
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM foobar
    Length Should Be  ${actual}  2
    ${expected} =  Set Variable  [{"id":"a","bar":1,"baz":3},{"id":"b","bar":2,"baz":2}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DELETE FROM foobar WHERE id = 'a'
    Query DynamoDB  ${LABEL}  DELETE FROM foobar WHERE id = 'b'

Update Table Where Keys In
    [Documentation]  Can update attribute sets in a table with KEYS IN in WHERE clause
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO foobar (id, bar, baz) VALUES ('a', 1, 1), ('b', 2, 2)
    Should Be Equal As Strings  ${response}  2
    Query DynamoDB  ${LABEL}  UPDATE foobar SET baz=3 KEYS IN ('a', 1), ('b', 2)
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM foobar
    Length Should Be  ${actual}  2
    ${expected} =  Set Variable  [{"id":"a","bar":1,"baz":3},{"id":"b","bar":2,"baz":3}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DELETE FROM foobar WHERE id = 'a'
    Query DynamoDB  ${LABEL}  DELETE FROM foobar WHERE id = 'b'

Update Table Increment
    [Documentation]  Can increment attribute sets in a table
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO foobar (id, bar, baz) VALUES ('a', 1, 1), ('b', 2, 2)
    Should Be Equal As Strings  ${response}  2
    Query DynamoDB  ${LABEL}  UPDATE foobar SET baz = baz + 2
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM foobar
    Length Should Be  ${actual}  2
    ${expected} =  Set Variable  [{"id":"a","bar":1,"baz":3},{"id":"b","bar":2,"baz":4}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  UPDATE foobar SET baz = baz - 1
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM foobar
    Length Should Be  ${actual}  2
    ${expected} =  Set Variable  [{"id":"a","bar":1,"baz":2},{"id":"b","bar":2,"baz":3}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DELETE FROM foobar WHERE id = 'a'
    Query DynamoDB  ${LABEL}  DELETE FROM foobar WHERE id = 'b'

Update Table Add To Set
    [Documentation]  Can add elements to the set in a table
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM foobar
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO foobar (id, bar, baz) VALUES ('a', 1, ())
    Should Be Equal As Strings  ${response}  1
    Query DynamoDB  ${LABEL}  UPDATE foobar SET baz = list_append([], [2])
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM foobar
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":"a","bar":1,"baz":[2]}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  UPDATE foobar SET baz = list_append(baz, [1, 3])
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM foobar
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":"a","bar":1,"baz":[1,2,3]}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DELETE FROM foobar WHERE id = 'a'

Update Table Remove From Set
    [Documentation]  Can remove elements from the set in a table
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO foobar (id, bar, baz) VALUES ('a', 1, (1, 2, 3, 4))
    Should Be Equal As Strings  ${response}  1
    Query DynamoDB  ${LABEL}  UPDATE foobar DELETE baz (2)
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM foobar
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":"a","bar":1,"baz":{"py/set":[1,3,4]}}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  UPDATE foobar DELETE baz (1, 3)
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM foobar
    Length Should Be  ${actual}  1
    ${expected} =  Set Variable  [{"id":"a","bar":1,"baz":{"py/set":[4]}}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DELETE FROM foobar WHERE id = 'a'

Update Table Remove Attribute
    [Documentation]  Can remove attribute in a table
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO foobar (id, bar, baz) VALUES ('a', 1, 1), ('b', 2, 2)
    Should Be Equal As Strings  ${response}  2
    Query DynamoDB  ${LABEL}  UPDATE foobar REMOVE baz
    @{actual} =  Query DynamoDB  ${LABEL}  SCAN * FROM foobar
    Length Should Be  ${actual}  2
    ${expected} =  Set Variable  [{"id":"a","bar":1},{"id":"b","bar":2}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DELETE FROM foobar WHERE id = 'a'
    Query DynamoDB  ${LABEL}  DELETE FROM foobar WHERE id = 'b'

Update Table And Returns
    [Documentation]  Can update attribute sets in a table and returns
    ${response} =  Query DynamoDB  ${LABEL}
    ...  INSERT INTO foobar (id, bar, baz) VALUES ('a', 1, 1), ('b', 2, 2)
    Should Be Equal As Strings  ${response}  2
    @{actual} =  Query DynamoDB  ${LABEL}  UPDATE foobar REMOVE baz RETURNS ALL NEW
    Length Should Be  ${actual}  2
    ${expected} =  Set Variable  [{"id":"a","bar":1},{"id":"b","bar":2}]
    List And JSON String Should Be Equal  ${actual}  ${expected}
    Query DynamoDB  ${LABEL}  DELETE FROM foobar WHERE id = 'a'
    Query DynamoDB  ${LABEL}  DELETE FROM foobar WHERE id = 'b'
