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

from DynamoDBSQLLibrary.keywords import Assertion, Query, SessionManager
from DynamoDBSQLLibrary.version import get_version

__version__ = get_version()


class DynamoDBSQLLibrary(Assertion, Query, SessionManager):
    """DynamoDBSQLibrary is a big data testing library for Robot Framework
    that gives you the capability to execute scan and query operations against
    multi Amazon DynamoDB sessions simultaneously using a SQL-like DSL.

    See https://aws.amazon.com/dynamodb/ for more information on Amazon DynamoDB.

    It leverages DynamoDB Query Languange (DQL) internally to provide a SQL-like DSL
    for Amazon DynamoDB.
    See https://dql.readthedocs.org/en/latest/ for more information on DQL.

    See https://dql.readthedocs.org/en/latest/topics/queries/index.html
    for more information on available DQL queries.

    Examples:
    | `Create DynamoDB Session`     | us-west-2      | label=oregon                |
    | `Create DynamoDB Session`     | ap-southeast-1 | label=singapore             |
    | `Create DynamoDB Session`     | eu-central-1   | label=frankfurt             |
    | `Query DynamoDB` | oregon     | CREATE TABLE mine (id STRING HASH KEY)       |
    | `Query DynamoDB` | singapore  | CREATE TABLE mine (id STRING HASH KEY)       |
    | `Query DynamoDB` | frankfurt  | CREATE TABLE mine (id STRING HASH KEY)       |
    | `DynamoDB Table Should Exist` | oregon         | mine                        |
    | `DynamoDB Table Should Exist` | singapore      | mine                        |
    | `DynamoDB Table Should Exist` | frankfurt      | mine                        |
    | `Query DynamoDB` | oregon     | INSERT INTO mine (id) VALUES ('oregon')      |
    | `Query DynamoDB` | singapore  | INSERT INTO mine (id) VALUES ('singapore')   |
    | `Query DynamoDB` | frankfurt  | INSERT INTO mine (id) VALUES ('frankfurt')   |
    | @{oregon} =      | `Query DynamoDB`    | oregon       | SCAN mine            |
    | @{singapore} =   | `Query DynamoDB`    | singapore    | SCAN mine            |
    | @{frankfurt} =   | `Query DynamoDB`    | frankfurt    | SCAN mine            |
    | `List And JSON String Should Be Equal` | ${oregon}    | [{"id":"oregon"}]    |
    | `List And JSON String Should Be Equal` | ${singapore} | [{"id":"singapore"}] |
    | `List And JSON String Should Be Equal` | ${frankfurt} | [{"id":"frankfurt"}] |
    | `Delete All Dynamodb Sessions` |

    *Config and Credentials File*

    Set up config file in default location:

    - ~/.aws/config (Linux/Mac)
    - %USERPROFILE%\\.aws\\config (Windows)

    | [default]
    | region = us-east-1

    Set up credentials file in default location:

    - ~/.aws/credentials (Linux/Mac)
    - %USERPROFILE%\\.aws\\credentials (Windows)

    | [default]
    | aws_access_key_id = YOUR_KEY
    | aws_secret_access_key = YOUR_SECRET
    |
    | [another_profile]
    | aws_access_key_id = ANOTHER_KEY
    | aws_secret_access_key = ANOTHER_SECRET
    | region = us-west-1
    """

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
