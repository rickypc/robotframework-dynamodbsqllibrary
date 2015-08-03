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

from boto3.session import Session
from dynamo3 import DynamoDBConnection
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

        :param str `profile`:
        set this profile when creating the session. (Optional)

        :param str `access_key`: If `session` is None,
        set this access key when creating the session. (Optional)

        :param str `secret_key`: If `session` is None,
        set this secret key when creating the session. (Optional)

        :param str `session_token`: If `session` is None,
        set this session token when creating the session. (Optional)

        :param str `host`: Address of the host.
        Use this to connect to a local instance. (Optional)

        :param int `port`: Connect to the host on this port. (Default 80)

        :param bool `is_secure`: Enforce https connection. (Default True)

        :param str `label`: Session label, a case and space insensitive string. (Default :param str `region`)

        Examples:
        | Create DynamoDB Session |           |                  |                   |             | # Use default config  |
        | Create DynamoDB Session | us-west-1 |                  |                   |             | # Use default profile |
        | Create DynamoDB Session | us-west-1 | profile=profile1 |                   |             | # Use profile1        |
        | Create DynamoDB Session | us-west-1 | access_key=KEY   | secret_key=SECRET |             | # Label is us-west-1  |
        | Create DynamoDB Session | us-west-1 | access_key=KEY   | secret_key=SECRET | label=LABEL | # Label is LABEL      |
        """
        # pylint: disable=line-too-long
        kargs = dict(enumerate(args))
        region = kargs.get(0, kwargs.pop('region', None))
        label = kwargs.pop('label', region)
        session = Engine()
        # pylint: disable=protected-access
        session._session = kwargs.pop('session', None)
        # pylint: disable=protected-access
        if session._session is None:
            # pylint: disable=protected-access
            session._session = self._get_session(region=region, **kwargs)
        # pylint: disable=protected-access
        client = self._get_client(session._session, region=region, **kwargs)
        kwargs.pop('access_key', None)
        kwargs.pop('host', None)
        kwargs.pop('is_secure', None)
        kwargs.pop('port', None)
        kwargs.pop('profile', None)
        kwargs.pop('secret_key', None)
        kwargs.pop('session_token', None)
        session.connection = DynamoDBConnection(client, **kwargs)
        if label is None:
            label = session.connection.region
        # pylint: disable=protected-access
        self._builtin.log('Creating DynamoDB session: %s' % label, 'DEBUG')
        self._cache.register(session, alias=label)
        return label

    def delete_all_dynamodb_sessions(self):
        """Removes all DynamoDB sessions."""
        self._cache.empty_cache()

    def delete_dynamodb_session(self, label):
        """Removes DynamoDB sessions.

        :param str `label`: Session label, a case and space insensitive string.
        (Default :param str `region`)

        Examples:
        | Delete DynamoDB Session | LABEL |
        """
        self._cache.switch(label)
        index = self._cache.current_index
        # pylint: disable=protected-access
        self._cache.current = self._cache._no_current
        # pylint: disable=protected-access
        self._cache._connections[index - 1] = None
        # pylint: disable=protected-access
        self._cache._aliases['x-%s-x' % label] = self._cache._aliases.pop(label)

    def _get_client(self, session, **kwargs):
        """Returns boto3 client session object."""
        client_kwargs = {}
        host = kwargs.pop('host', None)
        is_secure = kwargs.pop('is_secure', True)
        port = kwargs.pop('port', None)
        region = kwargs.pop('region', None)
        url = self._get_url(host, port, is_secure)
        if region is not None:
            client_kwargs['region_name'] = region
        if url is not None:
            client_kwargs['endpoint_url'] = url
        if not is_secure:
            client_kwargs['use_ssl'] = is_secure
        return session.client('dynamodb', **client_kwargs)

    @staticmethod
    def _get_session(**kwargs):
        """Returns boto3 session object."""
        access_key = kwargs.pop('access_key', None)
        profile = kwargs.pop('profile', None)
        region = kwargs.pop('region', None)
        session_kwargs = {}
        token = kwargs.pop('session_token', None)
        if access_key is not None:
            session_kwargs['aws_access_key_id'] = access_key
            session_kwargs['aws_secret_access_key'] = kwargs.pop('secret_key', None)
        if profile is not None:
            session_kwargs['profile_name'] = profile
        if region is not None:
            session_kwargs['region_name'] = region
        if token is not None:
            session_kwargs['aws_session_token'] = token
        return Session(**session_kwargs)

    @staticmethod
    def _get_url(host, port, is_secure=True):
        """Returns pre-format host endpoint URL."""
        url = None
        if host is not None:
            protocol = 'https' if is_secure else 'http'
            url = '%s://%s' % (protocol, host)
            if port is not None:
                url += ':%d' % int(port)
        return url
