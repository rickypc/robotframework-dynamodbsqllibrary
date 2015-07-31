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
from robot.libraries.BuiltIn import BuiltIn
from robot.utils import ConnectionCache


class SessionManager(object):
    """Session manager keywords for DynamoDB operations."""

    def __init__(self):
        self._builtin = BuiltIn()
        self._cache = ConnectionCache('No sessions.')

    def create_dynamodb_session(self, *args, **kwargs):
        # pylint: disable=line-too-long
        """Create DynamoDB session object.

        :param str `region`: Name of AWS region.

        :param botocore.session.Session `session`:
        The session object to user for the connection. (Optional)

        :param str `access_key`: If `session` is None,
        set this access key when creating the session. (Optional)

        :param str `secret_key`: If `session` is None,
        set this secret key when creating the session. (Optional)

        :param str `host`: Address of the host.
        Use this to connect to a local instance. (Optional)

        :param int `port`: Connect to the host on this port. (Default 80)

        :param bool `is_secure`: Enforce https connection. (Default True)

        :param str `label`: Session label, a case and space insensitive string. (Default :param str `region`)

        Examples:
        | Create DynamoDB Session | us-west-1 | access_key=KEY | secret_key=SECRET |             | # Label is us-west-1 |
        | Create DynamoDB Session | us-west-1 | access_key=KEY | secret_key=SECRET | label=LABEL | # Label is LABEL     |
        """
        # pylint: disable=line-too-long
        kargs = dict(enumerate(args))
        label = kwargs.pop('label', kargs.get(0, None))
        self._builtin.log('Creating DynamoDB session: %s' % label, 'DEBUG')
        session = Engine()
        session.connect(*args, **kwargs)
        self._cache.register(session, alias=label)
        return label

    def delete_all_dynamodb_sessions(self):
        """Removes all DynamoDB sessions."""
        self._cache.empty_cache()

    def delete_dynamodb_session(self, label):
        # pylint: disable=line-too-long
        """Removes DynamoDB sessions.

        :param str `label`: Session label, a case and space insensitive string. (Default :param str `region`)

        Examples:
        | Delete DynamoDB Session | LABEL |
        """
        # pylint: disable=line-too-long
        self._cache.switch(label)
        index = self._cache.current_index
        self._cache.current = self._cache._no_current  # pylint: disable=protected-access
        self._cache._connections[index - 1] = None  # pylint: disable=protected-access
        self._cache._aliases['x-%s-x' % label] = self._cache._aliases.pop(label)  # pylint: disable=protected-access
