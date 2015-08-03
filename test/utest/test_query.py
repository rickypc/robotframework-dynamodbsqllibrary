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

from dql import Engine
from dynamo3.result import ResultSet
from sys import path
path.append('src')
from DynamoDBSQLLibrary.keywords import Query
import mock
import unittest


class QueryTests(unittest.TestCase):
    """Query keyword test class."""

    def setUp(self):
        """Instantiate the query class."""
        self.command = 'MY-COMMAND'
        self.engine = mock.create_autospec(Engine)
        self.label = 'MY-LABEL'
        self.query = Query()
        self.query._builtin = mock.Mock()
        self.query._cache = mock.Mock()

    def test_should_return_expected_host(self):
        """Simulate query to return session host endpoint URL."""
        self.engine.connection = mock.PropertyMock()
        self.engine.connection.host = 'https://dynamodb.MY-REGION.amazonaws.com'
        self.query._cache.switch.return_value = self.engine
        response = self.query.dynamodb_host(self.label)
        self.assertEqual(response, 'https://dynamodb.MY-REGION.amazonaws.com')

    def test_should_return_expected_region(self):
        """Simulate query to return session region."""
        self.engine.connection = mock.PropertyMock()
        self.engine.connection.region = 'MY-REGION'
        self.query._cache.switch.return_value = self.engine
        response = self.query.dynamodb_region(self.label)
        self.assertEqual(response, 'MY-REGION')

    @mock.patch("DynamoDBSQLLibrary.keywords.query.ResultSet")
    def test_should_return_table_list(self, mock_rs):
        """Simulate query to return table list."""
        self.query._cache.switch.return_value = self.engine
        self.query.list_dynamodb_tables(self.label)
        self.query._cache.switch.assert_called_with(self.label)
        mock_rs.assert_called_with(self.engine.connection, 'TableNames', 'list_tables', Limit=100)
        self.query._builtin.log.assert_called_with("List tables response:\n%s" %
                                                   "[]", 'DEBUG')

    def test_query_should_return_string(self):
        """Simulate query to return string literal."""
        response = 'MY-RESPONSE'
        self.engine.execute.return_value = response
        self.query._cache.switch.return_value = self.engine
        self.query.query_dynamodb(self.label, self.command)
        self.query._cache.switch.assert_called_with(self.label)
        self.engine.execute.assert_called_with(self.command)
        self.query._builtin.log.assert_called_with("'%s' response:\n%s" %
                                                   (self.command, response), 'DEBUG')

    def test_query_should_return_result_set(self):
        """Simulate query to return ResultSet object."""
        response = mock.create_autospec(ResultSet)
        self.engine.execute.return_value = response
        self.query._cache.switch.return_value = self.engine
        self.query.query_dynamodb(self.label, self.command)
        self.query._cache.switch.assert_called_with(self.label)
        self.engine.execute.assert_called_with(self.command)
        self.query._builtin.log.assert_called_with("'%s' response:\n%s" %
                                                   (self.command, "[]"), 'DEBUG')
