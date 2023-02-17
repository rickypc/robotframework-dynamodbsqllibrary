#!/usr/bin/env python
# -*- coding: utf-8 -*-

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

"""
Amazon DynamoDB SQL Library - an Amazon DynamoDB testing library with SQL-like DSL.
"""

from collections import namedtuple, OrderedDict
from decimal import Decimal
from json import dumps, JSONEncoder, loads
from operator import itemgetter
from re import split
from boto3.dynamodb.types import Binary
from dql.exceptions import EngineRuntimeError
from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn


class Assertion():
    """Assertion keywords for DynamoDB operations."""

    def __init__(self):
        self._builtin = BuiltIn()

    @staticmethod
    @keyword("DynamoDB Dumps Should Be Equal")
    def dynamodb_dumps_should_be_equal(dump1, dump2):
        # pylint: disable=line-too-long
        """Validate if the given operands are equal.

        Arguments:
        - ``label``: A case and space insensitive string to identify the DynamoDB session.
        - ``dump1``: The first table schema dump to be validated.
        - ``dump2``: The second table schema dump to be validated.

        Examples:
        | DynamoDB Dumps Should Be Equal | LABEL | CREATE TABLE dump1 (id STRING HASH KEY,bar NUMBER RANGE KEY) | CREATE TABLE dump1 (bar NUMBER RANGE KEY,id STRING HASH KEY) | # PASS |
        | DynamoDB Dumps Should Be Equal | LABEL | CREATE TABLE dump1 (id STRING HASH KEY,bar NUMBER RANGE KEY) | CREATE TABLE dump1 (id STRING HASH KEY) | # FAIL |
        """
        # pylint: disable=line-too-long
        dumps1 = sorted([i.strip() for i in split("[(),]", dump1) if i])
        dumps2 = sorted([i.strip() for i in split("[(),]", dump2) if i])
        if dumps1 != dumps2:
            raise AssertionError("DynamoDBSQLLibraryError: Table schema dumps are different")

    @keyword("DynamoDB Table Should Exist")
    def dynamodb_table_should_exist(self, label, table_name):
        """Validates if the given ``table_name`` exists in the requested DynamoDB session.

        Arguments:
        - ``label``: A case and space insensitive string to identify the DynamoDB session.
        - ``table_name``: The table name to be validated.

        Examples:
        | DynamoDB Table Should Exist | LABEL | my-table            | # PASS |
        | DynamoDB Table Should Exist | LABEL | non-existance-table | # FAIL |
        """
        # pylint: disable-next=no-member
        session = self._cache.switch(label)
        try:
            session.execute(f'DUMP SCHEMA {table_name}')
        except EngineRuntimeError as exception:
            if str(exception) == f"Table '{table_name}' not found":
                # pylint: disable-next=raise-missing-from
                raise AssertionError(f"DynamoDBSQLLibraryError: Table '{table_name}' "
                                     "does not exist in the requested DynamoDB session")
            raise

    @keyword("DynamoDB Table Should Not Exist")
    def dynamodb_table_should_not_exist(self, label, table_name):
        """Validates if the given ``table_name`` does not exist in the requested DynamoDB session.

        Arguments:
        - ``label``: A case and space insensitive string to identify the DynamoDB session.
        - ``table_name``: The table name to be validated.

        Examples:
        | DynamoDB Table Should Not Exist | LABEL | non-existance-table | # PASS |
        | DynamoDB Table Should Not Exist | LABEL | my-table            | # FAIL |
        """
        # pylint: disable=no-member
        session = self._cache.switch(label)
        try:
            session.execute(f'DUMP SCHEMA {table_name}')
            raise AssertionError(f"DynamoDBSQLLibraryError: Table '{table_name}' exists in "
                                 "the requested DynamoDB session")
        except EngineRuntimeError as exception:
            if str(exception) == f"Table '{table_name}' not found":
                pass
            else:
                raise  # pragma: no cover

    @keyword("Json Loads")
    def json_loads(self, text):
        # pylint: disable=line-too-long
        """Returns [http://goo.gl/o0X6Pp|JSON] object from [http://goo.gl/o0X6Pp|JSON] string
        with object restoration support.

        Arguments:
        - ``text``: JSON string.

        Supported object restoration:
        | `py/boto3.dynamodb.types.Binary` |
        | `py/dict`                        |
        | `py/tuple`                       |
        | `py/set`                         |
        | `py/collections.namedtuple`      |
        | `py/collections.OrderedDict`     |

        Examples:
        | @{var} = | JSON Loads | [{"key":"value"}] |
        | @{var} = | JSON Loads | [{"py/boto3.dynamodb.types.Binary":"value"}] |
        | @{var} = | JSON Loads | [{"py/dict":{"key":"value"}}] |
        | @{var} = | JSON Loads | [{"py/tuple":(1,2,3)}] |
        | @{var} = | JSON Loads | [{"py/set":[1,2,3]}] |
        | @{var} = | JSON Loads | [{"py/collections.namedtuple":{"fields":"a b c","type":"NAME","values":(0,1,2)}}] |
        | @{var} = | JSON Loads | [{"py/collections.OrderedDict":[("key2",2),("key1",1)]}] |
        """
        # pylint: disable=line-too-long
        return loads(text, object_hook=self._restore, parse_float=Decimal)

    @keyword("List And Json String Should Be Equal")
    def list_and_json_string_should_be_equal(self, actual, expected_text, order_by='id'):
        """Fails if deep compare of the given list and [http://goo.gl/o0X6Pp|JSON] string
        are unequal.

        Arguments:
        - ``actual``: The list to be compared to JSON object from given JSON string.
        - ``expected_text``: The JSON string to be compared to the given list.
                             Please see ``JSON Loads`` for more details.
        - ``order_by``: The key to be used to sort the list. (Default 'id')

        Examples:
        | ${dict} = | Create Dictionary | id | 1 | key | value |
        | @{list} = | Create List | ${dict} |
        | List And JSON String Should Be Equal | ${list} | [{"id":1,"key":"value"}] | # PASS |
        """
        expected = self.json_loads(expected_text)
        self.lists_deep_compare_should_be_equal(actual, expected, order_by)

    @keyword("Lists Deep Compare")
    def lists_deep_compare(self, list1, list2, order_by='id'):
        """Returns deep compare results of the given lists.

        Arguments:
        - ``list1``: The first list to be compared to second list.
        - ``list2``: The second list to be compared to first list.
        - ``order_by``: The key to be used to sort the list. (Default 'id')

        Examples:
        | ${dict1} = | Create Dictionary | id | 1 | key | value |
        | ${dict2} = | Create Dictionary | id | 1 | key | value |
        | @{list1} = | Create List | ${dict1} |
        | @{list2} = | Create List | ${dict2} |
        | ${var} = | Lists Deep Compare | ${list1} | ${list2} |
        """
        return Assertion._cmp(list1, list2, key=itemgetter(order_by))

    @keyword("Lists Deep Compare Should Be Equal")
    def lists_deep_compare_should_be_equal(self, list1, list2, order_by='id'):
        """Fails if deep compare of the given lists are unequal.

        Arguments:
        - ``list1``: The first list to be compare to second list.
        - ``list2``: The second list to be compare to first list.
        - ``order_by``: The key to be use to sort the list. (Default 'id')

        Examples:
        | ${dict1} = | Create Dictionary | id | 1 | key | value |
        | ${dict2} = | Create Dictionary | id | 1 | key | value |
        | @{list1} = | Create List | ${dict1} |
        | @{list2} = | Create List | ${dict2} |
        | Lists Deep Compare Should Be Equal | ${list1} | ${list2} | # PASS |
        """
        result = self.lists_deep_compare(list1, list2, order_by)
        # pylint: disable=no-member
        self._builtin.should_be_equal(result, 0)

    @staticmethod
    def _restore(dct):
        """Returns restored object."""
        response = dct
        if 'py/boto3.dynamodb.types.Binary' in dct:
            response = Binary(bytes(dct['py/boto3.dynamodb.types.Binary'], encoding='utf-8'))
        elif 'py/dict' in dct:
            response = dict(dct['py/dict'])
        elif 'py/tuple' in dct:
            response = tuple(dct['py/tuple'])
        elif 'py/set' in dct:
            response = set(dct['py/set'])
        elif 'py/collections.namedtuple' in dct:
            data = dct['py/collections.namedtuple']
            response = namedtuple(data['type'], data['fields'])(*data['values'])
        # elif 'py/numpy.ndarray' in dct:
        #     data = dct['py/numpy.ndarray']
        #     response = np.array(data['values'], dtype=data['dtype'])
        elif 'py/collections.OrderedDict' in dct:
            response = OrderedDict(dct['py/collections.OrderedDict'])
        return response

    @staticmethod
    def _cmp(val1, val2, **kwargs):
        try:
            sorted_val1 = Assertion._sorting(val1, **kwargs)
            sorted_val2 = Assertion._sorting(val2, **kwargs)
            return (sorted_val1 > sorted_val2) - (sorted_val1 < sorted_val2)
        # pylint: disable-next=broad-exception-caught
        except Exception:
            dumped_val1 = dumps(val1, cls=DecimalEncoder, sort_keys=True)
            dumped_val2 = dumps(val2, cls=DecimalEncoder, sort_keys=True)
            return 0 if dumped_val1 == dumped_val2 else 1

    @staticmethod
    def _sorting(item, **kwargs):
        if isinstance(item, dict):
            return sorted(((key, Assertion._sorting(values))
                          for key, values in item.items()), **kwargs)
        if isinstance(item, list):
            return sorted(Assertion._sorting(x) for x in item)
        return item


class DecimalEncoder(JSONEncoder):
    """JSON encoder with Decimal value support."""

    def default(self, o):
        if isinstance(o, Decimal):
            return int(o) if o % 1 == 0 else float(o)
        return super().default(o)  # pragma: no cover
