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

from dynamo3.exception import DynamoDBError
from re import split


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
        | DynamoDB Dumps Should Be Equal | LABEL | CREATE TABLE dump1 (id STRING HASH KEY,bar NUMBER RANGE KEY) | CREATE TABLE dump2 (bar NUMBER RANGE KEY,id STRING HASH KEY) | # PASS |
        | DynamoDB Dumps Should Be Equal | LABEL | CREATE TABLE dump1 (id STRING HASH KEY,bar NUMBER RANGE KEY) | CREATE TABLE dump2 (id STRING HASH KEY)                          | # FAIL |
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
