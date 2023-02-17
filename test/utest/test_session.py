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

import mock
import unittest
from boto3.session import Session
from robot.utils import ConnectionCache
from sys import path
path.append('src')
from DynamoDBSQLLibrary.keywords import SessionManager  # noqa: E402


class SessionManagerTests(unittest.TestCase):
    """Session Manager keyword test class."""

    def setUp(self):
        """Instantiate the session manager class."""
        self.label = 'MY-LABEL'
        self.region = 'MY-REGION'
        self.session = SessionManager()
        self.session._logger = mock.Mock()

    def test_class_should_initiate(self):
        """Class init should instantiate required classes."""
        self.assertIsInstance(self.session._cache, ConnectionCache)

    def test_create_should_register_new_session(self):
        """Create session should successfully register new session."""
        label = self.session.create_dynamodb_session(self.region, label=self.label)
        self.assertEqual(label, self.label)
        self.assertNotEqual(label, self.region)
        try:
            self.session._cache.switch(label)
        except RuntimeError:
            self.fail("Label '%s' should be exist." % label)
        self.session.delete_all_dynamodb_sessions()

    def test_create_should_register_with_region_as_label(self):
        """Create session should successfully register new session with region as default label."""
        label = self.session.create_dynamodb_session(self.region)
        self.assertNotEqual(label, self.label)
        self.assertEqual(label, self.region)
        try:
            self.session._cache.switch(label)
        except RuntimeError:
            self.fail("Label '%s' should be exist." % label)
        self.session.delete_all_dynamodb_sessions()

    def test_create_should_register_new_session_with_keys(self):
        """Create session should successfully register new session with keys."""
        label = self.session.create_dynamodb_session(access_key='key', secret_key='secret')
        try:
            self.session._cache.switch(label)
        except RuntimeError:
            self.fail("Label '%s' should be exist." % label)
        self.session.delete_all_dynamodb_sessions()

    def test_create_should_register_new_session_with_default_config(self):
        """Create session should successfully register new session with region from default config."""
        config_region = 'us-east-1'
        label = self.session.create_dynamodb_session()
        self.assertEqual(label, config_region)
        self.assertNotEqual(label, self.region)
        try:
            session = self.session._cache.switch(label)
            # configs and credentials only resolved after client creation
            credentials = session._session._session._credentials
            default_conf = session._session._session._config['profiles']['default']
            self.assertEqual(credentials.access_key, 'ACCESS_KEY')
            self.assertEqual(credentials.secret_key, 'SECRET_KEY')
            self.assertEqual(default_conf['aws_access_key_id'], 'ACCESS_KEY')
            self.assertEqual(default_conf['aws_secret_access_key'], 'SECRET_KEY')
            self.assertEqual(default_conf['region'], config_region)
            self.assertEqual(session.connection.region, config_region)
        except RuntimeError:
            self.fail("Label '%s' should be exist." % label)
        self.session.delete_all_dynamodb_sessions()

    def test_create_should_register_new_session_with_all_default_values(self):
        """Create session should successfully register new session with all default values from config."""
        config_region = 'us-east-1'
        label = self.session.create_dynamodb_session()
        self.assertEqual(label, config_region)
        self.assertNotEqual(label, self.region)
        try:
            session_client = self.session._cache.switch(label)
            # configs and credentials only resolved after client creation
            self.assertEqual(session_client.connection.region, config_region)
        except RuntimeError:
            self.fail("Label '%s' should be exist." % label)
        self.session.delete_all_dynamodb_sessions()

    def test_create_should_register_new_session_with_default_keys(self):
        """Create session should successfully register new session with default keys."""
        label = self.session.create_dynamodb_session(self.region, label=self.label)
        self.assertEqual(label, self.label)
        self.assertNotEqual(label, self.region)
        try:
            session = self.session._cache.switch(label)
            # configs and credentials only resolved after client creation
            credentials = session._session._session._credentials
            default_conf = session._session._session._config['profiles']['default']
            self.assertEqual(credentials.access_key, 'ACCESS_KEY')
            self.assertEqual(credentials.secret_key, 'SECRET_KEY')
            self.assertEqual(default_conf['aws_access_key_id'], 'ACCESS_KEY')
            self.assertEqual(default_conf['aws_secret_access_key'], 'SECRET_KEY')
            self.assertNotEqual(default_conf['region'], self.region)
            self.assertEqual(session.connection.region, self.region)
        except RuntimeError:
            self.fail("Label '%s' should be exist." % label)
        self.session.delete_all_dynamodb_sessions()

    def test_create_should_register_new_session_with_specified_profile(self):
        """Create session should successfully register new session with specified profile."""
        config_region = 'us-west-1'
        default_config_region = 'us-east-1'
        label = self.session.create_dynamodb_session(profile='profile1')
        self.assertEqual(label, config_region)
        self.assertNotEqual(label, self.region)
        self.assertNotEqual(label, default_config_region)
        try:
            session = self.session._cache.switch(label)
            # configs and credentials only resolved after client creation
            credentials = session._session._session._credentials
            profile_conf = session._session._session._config['profiles']['profile1']
            self.assertEqual(credentials.access_key, 'ACCESS_KEY_1')
            self.assertEqual(credentials.secret_key, 'SECRET_KEY_1')
            self.assertEqual(profile_conf['aws_access_key_id'], 'ACCESS_KEY_1')
            self.assertEqual(profile_conf['aws_secret_access_key'], 'SECRET_KEY_1')
            self.assertNotEqual(profile_conf['region'], default_config_region)
            self.assertEqual(session.connection.region, config_region)
        except RuntimeError:
            self.fail("Label '%s' should be exist." % label)
        self.session.delete_all_dynamodb_sessions()

    def test_create_should_register_new_session_with_specified_profile_2(self):
        """Create session should successfully register new session with specified profile (without session)."""
        config_region = 'us-west-2'
        default_config_region = 'us-east-1'
        label = self.session.create_dynamodb_session(profile='profile2')
        self.assertEqual(label, config_region)
        self.assertNotEqual(label, self.region)
        self.assertNotEqual(label, default_config_region)
        try:
            session = self.session._cache.switch(label)
            # configs and credentials only resolved after client creation
            self.assertEqual(session.connection.region, config_region)
        except RuntimeError:
            self.fail("Label '%s' should be exist." % label)
        self.session.delete_all_dynamodb_sessions()

    def test_delete_should_remove_all_sessions(self):
        """Delete session should successfully remove all existing sessions."""
        self.session.create_dynamodb_session(self.region, label=self.label)
        self.session.delete_all_dynamodb_sessions()
        with self.assertRaises(RuntimeError) as context:
            self.session._cache.switch(self.label)
        self.assertTrue("Non-existing index or alias '%s'." % self.label in str(context.exception))

    def test_delete_should_remove_requested_session(self):
        """Delete session should successfully remove requested existing session."""
        self.session.create_dynamodb_session(self.region)
        self.session.create_dynamodb_session(self.region, label=self.label)
        self.session.delete_dynamodb_session(self.region)
        with self.assertRaises(Exception) as context:
            self.session.delete_dynamodb_session(self.region)
        self.assertTrue("Non-existing index or alias '%s'." % self.region in str(context.exception))
        try:
            self.session.delete_dynamodb_session(self.label)
        except Exception:
            self.fail("Label '%s' should be exist." % self.label)
        self.session.delete_all_dynamodb_sessions()

    def test_delete_should_log_error(self):
        self.session.delete_dynamodb_session(self.region, info_on_fail=True)
        self.session._logger.info.assert_called_with(f"Non-existing index or alias '{self.region}'.")

    def test_should_return_client(self):
        """Should return client session object."""
        config_region = 'us-east-1'
        session = Session()
        client = self.session._get_client(session)
        self.assertEqual(str(client._endpoint),
                         'dynamodb(https://dynamodb.%s.amazonaws.com)' % config_region)
        self.assertEqual(client._client_config.region_name, config_region)
        self.assertEqual(client.meta._endpoint_url,
                         'https://dynamodb.%s.amazonaws.com' % config_region)

    def test_should_return_client_with_requested_values(self):
        """Should return client session object with requested input values."""
        config_region = 'us-west-2'
        host = '127.0.0.1'
        port = 8000
        session = Session()
        client = self.session._get_client(session, host=host, is_secure=False,
                                          port=port, region=config_region)
        self.assertEqual(str(client._endpoint), 'dynamodb(http://%s:%s)' % (host, port))
        self.assertEqual(client._client_config.region_name, config_region)
        self.assertEqual(client.meta._endpoint_url, 'http://%s:%s' % (host, port))

    def test_should_return_session(self):
        """Should return session object."""
        config_region = 'us-east-1'
        session = self.session._get_session()
        default_conf = session._session._config['profiles']['default']
        self.assertEqual(default_conf['aws_access_key_id'], 'ACCESS_KEY')
        self.assertEqual(default_conf['aws_secret_access_key'], 'SECRET_KEY')
        self.assertEqual(default_conf['region'], config_region)

    def test_should_return_session_with_requested_values(self):
        """Should return session object with requested input values."""
        access_key = 'key'
        config_region = 'us-west-2'
        default_config_region = 'us-east-1'
        profile = 'profile1'
        secret_key = 'secret'
        session_token = 'session'
        session = self.session._get_session(access_key=access_key, profile=profile,
                                            region=config_region, secret_key=secret_key,
                                            session_token=session_token)
        credentials = session._session._credentials
        default_conf = session._session._config['profiles']['default']
        var = session._session._session_instance_vars
        self.assertEqual(credentials.access_key, access_key)
        self.assertEqual(credentials.secret_key, secret_key)
        self.assertEqual(credentials.token, session_token)
        self.assertEqual(default_conf['aws_access_key_id'], 'ACCESS_KEY')
        self.assertEqual(default_conf['aws_secret_access_key'], 'SECRET_KEY')
        self.assertEqual(default_conf['region'], default_config_region)
        self.assertEqual(var['profile'], profile)
        self.assertEqual(var['region'], config_region)

    def test_get_url_should_return_none(self):
        """Should return None on no input values."""
        host = None
        port = None
        is_secure = None
        url = self.session._get_url(host, port, is_secure)
        self.assertIsNone(url)

    def test_get_url_should_return_url(self):
        """Should return URL."""
        host = '127.0.0.1'
        port = None
        url = self.session._get_url(host, port)
        self.assertEqual(url, 'https://127.0.0.1')

    def test_get_url_should_return_url_with_port(self):
        """Should return URL with port numbers."""
        host = '127.0.0.1'
        port = 80
        is_secure = None
        url = self.session._get_url(host, port, is_secure)
        self.assertEqual(url, 'http://127.0.0.1:80')

    def test_get_url_should_return_url_with_ssl(self):
        """Should return URL without SSL."""
        host = '127.0.0.1'
        port = 80
        is_secure = True
        url = self.session._get_url(host, port, is_secure)
        self.assertEqual(url, 'https://127.0.0.1:80')

    def test_get_url_should_return_url_without_ssl(self):
        """Should return URL without SSL."""
        host = '127.0.0.1'
        port = 80
        is_secure = False
        url = self.session._get_url(host, port, is_secure)
        self.assertEqual(url, 'http://127.0.0.1:80')
