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
Resource        test/atest/resources/common.robot
Suite Setup     Suite Prepare With Default Table
Suite Teardown  Suite Cleanup With Default Table
Test Template   Return Value Should Be

*** Variables ***
${REGION} =     us-west-2

*** Test Cases ***
Insert String
    [Documentation]  Can insert string literals
    INSERT INTO foobar (id) VALUES ('a')
    ...  Inserted 1 items  a  [{"id": "a"}]

Insert Integer
    [Documentation]  Can insert integer literals
    INSERT INTO foobar (id, bar) VALUES ('b', 5)
    ...  Inserted 1 items  b  [{"id": "b", "bar": 5}]

Insert Float
    [Documentation]  Can insert float literals
    INSERT INTO foobar (id, bar) VALUES ('c', 1.2345)
    ...  Inserted 1 items  c  [{"id": "c", "bar": 1.2345}]

Insert Boolean
    [Documentation]  Can insert boolean literals
    INSERT INTO foobar (id, bar) VALUES ('d', false)
    ...  Inserted 1 items  d  [{"id": "d", "bar": false}]

Insert Binary
    [Documentation]  Can insert binary literals
    INSERT INTO foobar (id, bar) VALUES ('e', b'abc')
    ...  Inserted 1 items  e  [{"id": "e", "bar": "abc"}]

Insert List
    [Documentation]  Can insert list literals
    INSERT INTO foobar (id, bar) VALUES ('f', [1, null, 'a'])
    ...  Inserted 1 items  f  [{"id": "f", "bar": [1, null, "a"]}]

Insert Empty List
    [Documentation]  Can insert empty list literals
    INSERT INTO foobar (id, bar) VALUES ('g', [])
    ...  Inserted 1 items  g  [{"id": "g", "bar": []}]

Insert Nested List
    [Documentation]  Can insert nested list literals
    INSERT INTO foobar (id, bar) VALUES ('h', [1, [2, 3]])
    ...  Inserted 1 items  h  [{"id": "h", "bar": [1, [2, 3]]}]

Insert Dictionary
    [Documentation]  Can insert dict literals
    INSERT INTO foobar (id, bar) VALUES ('i', {'a': 2})
    ...  Inserted 1 items  i  [{"id": "i", "bar": {"a": 2}}]

Insert Empty Dictionary
    [Documentation]  Can insert empty dict literals
    INSERT INTO foobar (id, bar) VALUES ('j', {})
    ...  Inserted 1 items  j  [{"id": "j", "bar": {}}]

Insert Nested Dictionary
    [Documentation]  Can insert nested dict literals
    INSERT INTO foobar (id, bar) VALUES ('k', {'a': {'b': null}})
    ...  Inserted 1 items  k  [{"id": "k", "bar": {"a": {"b": null}}}]
