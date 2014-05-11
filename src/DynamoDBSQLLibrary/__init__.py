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

from DynamoDBSQLLibrary.keywords import SessionManager
from DynamoDBSQLLibrary.version import get_version

__version__ = get_version()


class DynamoDBSQLLibrary(SessionManager):
    # pylint: disable=line-too-long
    """DynamoDBSQLibrary is a testing library for Robot Framework
    that gives you the capability to execute scan and query operations against
    multi-region Amazon DynamoDB sessions simultaneously using a SQL-like DSL.

    See https://aws.amazon.com/dynamodb/ for more information on Amazon DynamoDB.

    It leverages DynamoDB Query Languange (DQL) internally to provide a SQL-like DSL
    for Amazon DynamoDB.
    See https://dql.readthedocs.org/en/latest/ for more information on DQL.

    See https://dql.readthedocs.org/en/latest/topics/queries/index.html
    for more information on available DQL queries.

    Examples:
    | `Create DynamoDB Session` | us-west-2      | access_key=key | secret_key=secret | label=oregon    |
    | `Create DynamoDB Session` | ap-southeast-1 | access_key=key | secret_key=secret | label=singapore |
    | `Create DynamoDB Session` | eu-central-1   | access_key=key | secret_key=secret | label=frankfurt |
    | `Delete All Dynamodb Sessions` |
    """
    # pylint: disable=line-too-long

    ROBOT_EXIT_ON_FAILURE = True
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_LIBRARY_VERSION = __version__

    # pylint: disable=super-init-not-called
    def __init__(self):
        """DynamoDBSQLLibrary can be imported without argument.

        Examples:
        | = Keyword Definition =         | = Description =               |
        | Library `|` DynamoDBSQLLibrary | Initiate DynamoDB SQL library |
        """
        for base in DynamoDBSQLLibrary.__bases__:
            base.__init__(self)