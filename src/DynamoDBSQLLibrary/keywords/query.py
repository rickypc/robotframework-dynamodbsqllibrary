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

from dynamo3.result import ResultSet
from robot.api import logger
from robot.api.deco import keyword


class Query():
    """Query keywords for DynamoDB scan and query operations."""

    def __init__(self):
        self._logger = logger

    @keyword("DynamoDB Host")
    def dynamodb_host(self, label):
        """Returns DynamoDB session endpoint URL.

        Arguments:
        - ``label``: A case and space insensitive string to identify the DynamoDB session.

        Examples:
        | ${var} = | DynamoDB Host | LABEL |
        """
        # pylint: disable=no-member
        return self._cache.switch(label).connection.host

    @keyword("DynamoDB Region")
    def dynamodb_region(self, label):
        """Returns DynamoDB session region.

        Arguments:
        - ``label``: A case and space insensitive string to identify the DynamoDB session.

        Examples:
        | ${var} = | DynamoDB Region | LABEL |
        """
        # pylint: disable=no-member
        return self._cache.switch(label).connection.region

    @keyword("List DynamoDB Tables")
    def list_dynamodb_tables(self, label, **kwargs):
        """Returns list of all tables on requested DynamoDB session.

        Arguments:
        - ``label``: A case and space insensitive string to identify the DynamoDB session.
        - ``Limit``: Maximum number of tables to return. (Default 100)

        Examples:
        | @{var} = | List DynamoDB Tables | LABEL |                           |         |
        | @{var} = | List DynamoDB Tables | LABEL | Limit=1                   |         |
        | @{var} = | List DynamoDB Tables | LABEL | ExclusiveStartTableName=a |         |
        | @{var} = | List DynamoDB Tables | LABEL | ExclusiveStartTableName=a | Limit=1 |
        """
        # pylint: disable=no-member
        session = self._cache.switch(label)
        response = list(session.connection.call('list_tables',
                                                Limit=int(kwargs.pop('Limit', 100)),
                                                **kwargs)['TableNames'])
        # pylint: disable=no-member
        self._logger.debug(f"List tables response:\n{response}")
        return response

    @keyword("Query DynamoDB")
    def query_dynamodb(self, label, commands):
        """Executes the SQL-like DSL commands on requested DynamoDB session.
        The return value will vary based on the type of query.

        Arguments:
        - ``label``: A case and space insensitive string to identify the DynamoDB session.
        - ``commands``: SQL-like DSL commands.
        See [https://goo.gl/RRKSeK|available queries].

        Examples:
        | ${var} = | Query DynamoDB | LABEL | DUMP SCHEMA my-table |
        | @{var} = | Query DynamoDB | LABEL | SCAN my-table LIMIT ${limit} |
        """
        # pylint: disable=no-member
        session = self._cache.switch(label)
        response = session.execute(commands)
        if isinstance(response, ResultSet):
            response = list(response)
        # pylint: disable=no-member
        self._logger.debug(f"'{commands}' response:\n{response}")
        return response
