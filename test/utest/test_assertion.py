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
from dql import Engine
from dynamo3.exception import DynamoDBError
from sys import path
path.append('src')
from DynamoDBSQLLibrary.keywords import Assertion
import mock
import unittest


class AssertionTests(unittest.TestCase):
    """Assertion keyword test class."""

    def setUp(self):
        """Instantiate the assertion class."""
        self.assertion = Assertion()
        self.assertion._builtin = mock.Mock()
        self.assertion._cache = mock.Mock()
        self.engine = mock.create_autospec(Engine)
        self.label = 'MY-LABEL'
        self.table_name = 'MY-TABLE-NAME'

    def test_schema_dumps_should_be_equal(self):
        """Schema dumps should be equal."""
        try:
            self.assertion.dynamodb_dumps_should_be_equal(
                'CREATE TABLE dump1 (id STRING HASH KEY,bar NUMBER RANGE KEY)',
                'CREATE TABLE dump1 (bar NUMBER RANGE KEY,id STRING HASH KEY)')
        except AssertionError:
            self.fail("Assertion.dynamodb_dumps_should_be_equal() "
                      "raised AssertionError unexpectedly")

    def test_schema_dumps_should_be_unequal(self):
        """Schema dumps should raise AssertionError exception."""
        with self.assertRaises(AssertionError) as context:
            self.assertion.dynamodb_dumps_should_be_equal(
                'CREATE TABLE dump1 (id STRING HASH KEY,bar NUMBER RANGE KEY)',
                'CREATE TABLE dump1 (id STRING HASH KEY)')
        self.assertTrue('DynamoDBSQLLibraryError: Table schema dumps are different'
                        in context.exception)

    def test_table_should_be_exist(self):
        """Table exist validation should return table existance."""
        self.assertion._cache.switch.return_value = self.engine
        self.assertion.dynamodb_table_should_exist(self.label, self.table_name)
        self.assertion._cache.switch.assert_called_with(self.label)
        try:
            self.engine.execute.assert_called_with("DUMP SCHEMA %s" % self.table_name)
        except AssertionError:
            self.fail("Assertion.dynamodb_table_should_exist() "
                      "raised AssertionError unexpectedly")

    def test_table_exist_raise_assertion_error(self):
        """Table exist validation should raise AssertionError."""
        self.engine.execute = mock.Mock(side_effect=DynamoDBError(None, None, args=None,
                                        Code='ResourceNotFoundException', Message=''))
        self.assertion._cache.switch.return_value = self.engine
        with self.assertRaises(AssertionError) as context:
            self.assertion.dynamodb_table_should_exist(self.label, self.table_name)
        self.assertion._cache.switch.assert_called_with(self.label)
        self.assertTrue("DynamoDBSQLLibraryError: Table '%s' does not exist "
                        "in the requested DynamoDB session" % self.table_name
                        in context.exception)

    def test_table_exist_raise_other_error(self):
        """Table exist validation should raise Exception."""
        self.engine.execute = mock.Mock(side_effect=DynamoDBError(None, None, args=None,
                                        Code='Exception', Message='MY-EXCEPTION'))
        self.assertion._cache.switch.return_value = self.engine
        with self.assertRaises(DynamoDBError) as context:
            self.assertion.dynamodb_table_should_exist(self.label, self.table_name)
        self.assertion._cache.switch.assert_called_with(self.label)
        self.assertTrue("Exception: MY-EXCEPTION\nArgs: None" in context.exception)

    def test_table_should_not_exist(self):
        """Table not exist validation should return table non-existance."""
        self.engine.execute = mock.Mock(side_effect=DynamoDBError(None, None, args=None,
                                        Code='ResourceNotFoundException', Message=''))
        self.assertion._cache.switch.return_value = self.engine
        self.assertion.dynamodb_table_should_not_exist(self.label, self.table_name)
        self.assertion._cache.switch.assert_called_with(self.label)
        try:
            self.engine.execute.assert_called_with("DUMP SCHEMA %s" % self.table_name)
        except AssertionError:
            self.fail("Assertion.dynamodb_table_should_not_exist() "
                      "raised AssertionError unexpectedly")

    def test_table_not_exist_raise_assertion_error(self):
        """Table not exist validation should raise AssertionError."""
        self.assertion._cache.switch.return_value = self.engine
        with self.assertRaises(AssertionError) as context:
            self.assertion.dynamodb_table_should_not_exist(self.label, self.table_name)
        self.assertion._cache.switch.assert_called_with(self.label)
        self.assertTrue("DynamoDBSQLLibraryError: Table '%s' exists in "
                        "the requested DynamoDB session" % self.table_name
                        in context.exception)

    def test_table_not_exist_raise_other_error(self):
        """Table not exist validation should raise Exception."""
        self.engine.execute = mock.Mock(side_effect=DynamoDBError(None, None, args=None,
                                        Code='Exception', Message='MY-EXCEPTION'))
        self.assertion._cache.switch.return_value = self.engine
        with self.assertRaises(DynamoDBError) as context:
            self.assertion.dynamodb_table_should_not_exist(self.label, self.table_name)
        self.assertion._cache.switch.assert_called_with(self.label)
        self.assertTrue("Exception: MY-EXCEPTION\nArgs: None" in context.exception)

    def test_json_should_loads(self):
        """De-serialize JSON string to JSON object correctly."""
        actual = '[{"key": 5.5, "key2": "value2"}]'
        expected = [{'key': Decimal(5.5), 'key2': 'value2'}]
        self.assertEqual(self.assertion.json_loads(actual), expected)

    def test_list_and_json_should_be_equal(self):
        """List and JSON string should compare equally."""
        actual = [{'key': Decimal(5.5)}, {'key': Decimal(5.4)}]
        expected = '[{"key": 5.4}, {"key": 5.5}]'
        try:
            self.assertion.list_and_json_string_should_be_equal(actual, expected, 'key')
        except AssertionError:
            self.fail("Assertion.list_and_json_string_should_be_equal() "
                      "raised AssertionError unexpectedly")

    def test_list_and_json_should_be_unequal(self):
        """List and JSON string should compare unequally."""
        actual = [{'key': Decimal(5.5)}, {'key': Decimal(5.4)}]
        expected = '[{"key": 5.4}, {"key": 5.5}]'
        self.assertion._builtin.should_be_equal = mock.Mock(side_effect=AssertionError())
        with self.assertRaises(AssertionError) as context:
            self.assertion.list_and_json_string_should_be_equal(actual, expected, 'key')
        self.assertEqual(context.exception.message, '')

    def test_lists_deep_compare_should_be_equal_to(self):
        """First list should be equal to second list."""
        actual = [{'key': Decimal(5.5)}, {'key': Decimal(5.4)}]
        expected = [{'key': Decimal(5.4)}, {'key': Decimal(5.5)}]
        self.assertEqual(self.assertion.lists_deep_compare(actual, expected, 'key'), 0)

    def test_lists_deep_compare_should_be_less_than(self):
        """First list should be less than second list."""
        actual = [{'key': Decimal(5.5)}, {'key': Decimal(5.4)}]
        expected = [{'key': Decimal(5.4)}, {'key': Decimal(5.5)}, {'key': Decimal(5.6)}]
        self.assertEqual(self.assertion.lists_deep_compare(actual, expected, 'key'), -1)

    def test_lists_deep_compare_should_be_greater_than(self):
        """First list should be greater than second list."""
        actual = [{'key': Decimal(5.6)}, {'key': Decimal(5.5)}, {'key': Decimal(5.4)}]
        expected = [{'key': Decimal(5.4)}, {'key': Decimal(5.5)}]
        self.assertEqual(self.assertion.lists_deep_compare(actual, expected, 'key'), 1)

    def test_lists_deep_comparison_should_be_equal(self):
        """Lists deep comparison should compare equally."""
        actual = [{'key': Decimal(5.5)}, {'key': Decimal(5.4)}]
        expected = [{'key': Decimal(5.4)}, {'key': Decimal(5.5)}]
        try:
            self.assertion.lists_deep_compare_should_be_equal(actual, expected, 'key')
        except AssertionError:
            self.fail("Assertion.lists_deep_compare_should_be_equal() "
                      "raised AssertionError unexpectedly")

    def test_lists_deep_comparison_should_be_unequal(self):
        """Lists deep comparison should compare unequally."""
        actual = [{'key': Decimal(5.5)}, {'key': Decimal(5.4)}]
        expected = [{'key': Decimal(5.4)}, {'key': Decimal(5.5)}]
        self.assertion._builtin.should_be_equal = mock.Mock(side_effect=AssertionError())
        with self.assertRaises(AssertionError) as context:
            self.assertion.lists_deep_compare_should_be_equal(actual, expected, 'key')
        self.assertEqual(context.exception.message, '')

    def test_object_restore_dict(self):
        """Should restore dict object successfully."""
        actual = {"py/dict": {"key": "value"}}
        expected = dict({"key": "value"})
        self.assertEqual(self.assertion._restore(actual), expected)

    def test_object_restore_tuple(self):
        """Should restore tuple object successfully."""
        actual = {"py/tuple": (1, 2, 3)}
        expected = tuple((1, 2, 3))
        self.assertEqual(self.assertion._restore(actual), expected)

    def test_object_restore_set(self):
        """Should restore set object successfully."""
        actual = {"py/set": [1, 2, 3]}
        expected = set([1, 2, 3])
        self.assertEqual(self.assertion._restore(actual), expected)

    def test_object_restore_namedtuple(self):
        """Should restore namedtuple object successfully."""
        actual = {"py/collections.namedtuple":
                  {"type": "MINE", "fields": "a b c", "values": (0, 1, 2)}}
        expected = namedtuple('MINE', 'a b c')._make(range(3))
        self.assertEqual(self.assertion._restore(actual), expected)

    def test_object_restore_OrderedDict(self):
        """Should restore OrderedDict object successfully."""
        actual = {"py/collections.OrderedDict": [('key2', 2), ('key1', 1)]}
        expected = OrderedDict([('key2', 2), ('key1', 1)])
        self.assertEqual(self.assertion._restore(actual), expected)
