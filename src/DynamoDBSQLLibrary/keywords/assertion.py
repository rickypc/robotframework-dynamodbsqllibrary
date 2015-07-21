#!/usr/bin/env python
# -*- coding: utf-8 -*-

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

"""
Amazon DynamoDB SQL Library - an Amazon DynamoDB testing library with SQL-like DSL.
"""

from collections import namedtuple, OrderedDict
from decimal import Decimal
from dynamo3.exception import DynamoDBError
from json import loads
from operator import itemgetter
from re import split
# import numpy as np


class Assertion(object):
    """Assertion keywords for DynamoDB operations."""

    @staticmethod
    def dynamodb_dumps_should_be_equal(dump1, dump2):
        # pylint: disable=line-too-long
        """Validate if the given operands are equal.

        :param str `label`: Session label, a case and space insensitive string.

        :param str `dump1`: First table schema dump to be validated.

        :param str `dump2`: Second table schema dump to be validated.

        Examples:
        | DynamoDB Dumps Should Be Equal | LABEL | CREATE TABLE dump1 (id STRING HASH KEY,bar NUMBER RANGE KEY) | CREATE TABLE dump1 (bar NUMBER RANGE KEY,id STRING HASH KEY) | # PASS |
        | DynamoDB Dumps Should Be Equal | LABEL | CREATE TABLE dump1 (id STRING HASH KEY,bar NUMBER RANGE KEY) | CREATE TABLE dump1 (id STRING HASH KEY)                          | # FAIL |
        """
        # pylint: disable=line-too-long
        dumps1 = sorted([i.strip() for i in split("[(),]", dump1) if i])
        dumps2 = sorted([i.strip() for i in split("[(),]", dump2) if i])
        if dumps1 != dumps2:
            raise AssertionError("DynamoDBSQLLibraryError: Table schema dumps are different")

    def dynamodb_table_should_exist(self, label, table_name):
        """Validates if the given `table_name` exists in the requested DynamoDB session.

        :param str `label`: Session label, a case and space insensitive string.

        :param str `table_name`: Table name to be validated.

        Examples:
        | DynamoDB Table Should Exist | LABEL | my-table            | # PASS |
        | DynamoDB Table Should Exist | LABEL | non-existance-table | # FAIL |
        """
        # pylint: disable=no-member
        session = self._cache.switch(label)
        try:
            session.execute("DUMP SCHEMA %s" % table_name)
        except DynamoDBError as exception:
            if exception.kwargs['Code'] == 'ResourceNotFoundException':
                raise AssertionError("DynamoDBSQLLibraryError: Table '%s' does not exist "
                                     "in the requested DynamoDB session" % table_name)
            else:
                raise

    def dynamodb_table_should_not_exist(self, label, table_name):
        """Validates if the given `table_name` does not exist in the requested DynamoDB session.

        :param str `label`: Session label, a case and space insensitive string.

        :param str `table_name`: Table name to be validated.

        Examples:
        | DynamoDB Table Should Not Exist | LABEL | non-existance-table | # PASS |
        | DynamoDB Table Should Not Exist | LABEL | my-table            | # FAIL |
        """
        # pylint: disable=no-member
        session = self._cache.switch(label)
        try:
            session.execute("DUMP SCHEMA %s" % table_name)
            raise AssertionError("DynamoDBSQLLibraryError: Table '%s' exists in "
                                 "the requested DynamoDB session" % table_name)
        except DynamoDBError as exception:
            if exception.kwargs['Code'] == 'ResourceNotFoundException':
                pass
            else:
                raise

    def json_loads(self, text):
        """Returns JSON from JSON string.

        :param str `text`: JSON string.

        Examples:
        | @{var} = | JSON Loads | [{"key":"value"}] |
        """
        return loads(text, object_hook=self._restore, parse_float=Decimal)

    def list_and_json_string_should_be_equal(self, actual, expected_text, order_by='id'):
        """Fails if deep compare of the given list and JSON string are unequal.

        :param list `actual`: The list to be compare to JSON object from given JSON string.

        :param str `expected_text`: The JSON string to be compare to the given list.

        :param str `order_by`: The key to be use to sort the list. (Default 'id')

        Examples:
        | ${dict} = | Create Dictionary | id | 1 | key | value |
        | @{list} = | Create List | ${dict} |
        | List And JSON String Should Be Equal | ${list} | [{"id":1,"key":"value"}] | # PASS |
        """
        expected = self.json_loads(expected_text)
        self.lists_deep_compare_should_be_equal(actual, expected, order_by)

    @staticmethod
    def lists_deep_compare(list1, list2, order_by='id'):
        """Returns deep compare results of the given lists.

        :param list `list1`: First list to be compare to second list.

        :param list `list2`: Second list to be compare to first list.

        :param str `order_by`: The key to be use to sort the list. (Default 'id')

        Examples:
        | ${dict1} = | Create Dictionary | id | 1 | key | value |
        | ${dict2} = | Create Dictionary | id | 1 | key | value |
        | @{list1} = | Create List | ${dict1} |
        | @{list2} = | Create List | ${dict2} |
        | ${var} = | Lists Deep Compare | ${list1} | ${list2} | # 0 |
        """
        list1, list2 = [sorted(l, key=itemgetter(order_by)) for l in (list1, list2)]
        return cmp(list1, list2)

    def lists_deep_compare_should_be_equal(self, list1, list2, order_by='id'):
        """Fails if deep compare of the given lists are unequal.

        :param list `list1`: First list to be compare to second list.

        :param list `list2`: Second list to be compare to first list.

        :param str `order_by`: The key to be use to sort the list. (Default 'id')

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
        if "py/dict" in dct:
            return dict(dct["py/dict"])
        if "py/tuple" in dct:
            return tuple(dct["py/tuple"])
        if "py/set" in dct:
            return set(dct["py/set"])
        if "py/collections.namedtuple" in dct:
            data = dct["py/collections.namedtuple"]
            return namedtuple(data["type"], data["fields"])(*data["values"])
        # if "py/numpy.ndarray" in dct:
        #     data = dct["py/numpy.ndarray"]
        #     return np.array(data["values"], dtype=data["dtype"])
        if "py/collections.OrderedDict" in dct:
            return OrderedDict(dct["py/collections.OrderedDict"])
        return dct
