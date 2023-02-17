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
Test Template   Return Value Should Be

*** Variables ***
${REGION} =     us-west-2

*** Test Cases ***
Insert String
    [Documentation]  Can insert string literals
    INSERT INTO foobar (id) VALUES ('a')  1  a  [{"id": "a"}]

Insert Integer
    [Documentation]  Can insert integer literals
    INSERT INTO foobar (id, bar) VALUES ('b', 5)  1  b  [{"id": "b", "bar": 5}]

Insert Float
    [Documentation]  Can insert float literals
    INSERT INTO foobar (id, bar) VALUES ('c', 1.2345)  1  c  [{"id": "c", "bar": 1.2345}]

Insert Boolean
    [Documentation]  Can insert boolean literals
    INSERT INTO foobar (id, bar) VALUES ('d', false)  1  d  [{"id": "d", "bar": false}]

Insert Binary
    [Documentation]  Can insert binary literals
    INSERT INTO foobar (id, bar) VALUES ('e', b'abc')  1  e  [{"id": "e", "bar": {"py/boto3.dynamodb.types.Binary": "abc"}}]

Insert List
    [Documentation]  Can insert list literals
    INSERT INTO foobar (id, bar) VALUES ('f', [1, null, 'a'])  1  f  [{"id": "f", "bar": [1, null, "a"]}]

Insert Empty List
    [Documentation]  Can insert empty list literals
    INSERT INTO foobar (id, bar) VALUES ('g', [])  1  g  [{"id": "g", "bar": []}]

Insert Nested List
    [Documentation]  Can insert nested list literals
    INSERT INTO foobar (id, bar) VALUES ('h', [1, [2, 3]])  1  h  [{"id": "h", "bar": [1, [2, 3]]}]

Insert Dictionary
    [Documentation]  Can insert dict literals
    INSERT INTO foobar (id, bar) VALUES ('i', {'a': 2})  1  i  [{"id": "i", "bar": {"a": 2}}]

Insert Empty Dictionary
    [Documentation]  Can insert empty dict literals
    INSERT INTO foobar (id, bar) VALUES ('j', {})  1  j  [{"id": "j", "bar": {}}]

Insert Nested Dictionary
    [Documentation]  Can insert nested dict literals
    INSERT INTO foobar (id, bar) VALUES ('k', {'a': {'b': null}})  1  k  [{"id": "k", "bar": {"a": {"b": null}}}]
