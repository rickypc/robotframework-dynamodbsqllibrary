#!/usr/bin/env python
# -*- coding: utf-8 -*-

#    Amazon DynamoDB SQL Library - an Amazon DynamoDB testing library with SQL-like DSL.
#    Copyright (C) 2014  Richard Huang <rickypc@users.noreply.github.com>
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


class Query(object):
    """Query keywords for DynamoDB scan and query operations."""

    def query_dynamodb(self, label, commands):
        """Executes the SQL-like DSL commands on requested DynamoDB session.

        :param str `label`: Session label, a case and space insensitive string.

        :param str `commands`: SQL-like DSL commands.
        See https://dql.readthedocs.org/en/latest/topics/queries/index.html
        for more information on available queries.

        The return value will vary based on the type of query.

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
        self._builtin.log("'%s' response:\n%s" % (commands, response), 'DEBUG')
        return response
