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

from botocore.session import get_session, Session
from robot.libraries.BuiltIn import BuiltIn
from robot.utils import ConnectionCache
from sys import path
path.append('src')
from DynamoDBSQLLibrary.keywords import SessionManager
import unittest


class SessionManagerTests(unittest.TestCase):
    """Session Manager keyword test class."""

    def setUp(self):
        """Instantiate the session manager class."""
        self.label = 'MY-LABEL'
        self.region = 'MY-REGION'
        self.session = SessionManager()

    def test_class_should_initiate(self):
        """Class init should instantiate required classes."""
        self.assertIsInstance(self.session._builtin, BuiltIn)
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
        session = get_session()
        label = self.session.create_dynamodb_session(session=session)
        self.assertEqual(label, config_region)
        self.assertNotEqual(label, self.region)
        try:
            session_client = self.session._cache.switch(label)
            # configs and credentials only resolved after client creation
            credentials = session._credentials
            default_conf = session._config['profiles']['default']
            self.assertEqual(credentials.access_key, 'ACCESS_KEY')
            self.assertEqual(credentials.secret_key, 'SECRET_KEY')
            self.assertEqual(default_conf['aws_access_key_id'], 'ACCESS_KEY')
            self.assertEqual(default_conf['aws_secret_access_key'], 'SECRET_KEY')
            self.assertEqual(default_conf['region'], config_region)
            self.assertEqual(session_client._connection.region, config_region)
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
            self.assertEqual(session_client._connection.region, config_region)
        except RuntimeError:
            self.fail("Label '%s' should be exist." % label)
        self.session.delete_all_dynamodb_sessions()

    def test_create_should_register_new_session_with_default_keys(self):
        """Create session should successfully register new session with default keys."""
        session = get_session()
        label = self.session.create_dynamodb_session(self.region, session=session, label=self.label)
        self.assertEqual(label, self.label)
        self.assertNotEqual(label, self.region)
        try:
            session_client = self.session._cache.switch(label)
            # configs and credentials only resolved after client creation
            credentials = session._credentials
            default_conf = session._config['profiles']['default']
            self.assertEqual(credentials.access_key, 'ACCESS_KEY')
            self.assertEqual(credentials.secret_key, 'SECRET_KEY')
            self.assertEqual(default_conf['aws_access_key_id'], 'ACCESS_KEY')
            self.assertEqual(default_conf['aws_secret_access_key'], 'SECRET_KEY')
            self.assertNotEqual(default_conf['region'], self.region)
            self.assertEqual(session_client._connection.region, self.region)
        except RuntimeError:
            self.fail("Label '%s' should be exist." % label)
        self.session.delete_all_dynamodb_sessions()

    def test_create_should_register_new_session_with_specified_profile(self):
        """Create session should successfully register new session with specified profile."""
        config_region = 'us-west-1'
        default_config_region = 'us-east-1'
        session = Session(profile='profile1')
        label = self.session.create_dynamodb_session(session=session)
        self.assertEqual(label, config_region)
        self.assertNotEqual(label, self.region)
        self.assertNotEqual(label, default_config_region)
        try:
            session_client = self.session._cache.switch(label)
            # configs and credentials only resolved after client creation
            credentials = session._credentials
            profile_conf = session._config['profiles']['profile1']
            self.assertEqual(credentials.access_key, 'ACCESS_KEY_1')
            self.assertEqual(credentials.secret_key, 'SECRET_KEY_1')
            self.assertEqual(profile_conf['aws_access_key_id'], 'ACCESS_KEY_1')
            self.assertEqual(profile_conf['aws_secret_access_key'], 'SECRET_KEY_1')
            self.assertNotEqual(profile_conf['region'], default_config_region)
            self.assertEqual(session_client._connection.region, config_region)
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
            self.assertEqual(session._connection.region, config_region)
        except RuntimeError:
            self.fail("Label '%s' should be exist." % label)
        self.session.delete_all_dynamodb_sessions()

    def test_delete_should_remove_all_sessions(self):
        """Delete session should successfully remove all existing sessions."""
        self.session.create_dynamodb_session(self.region, label=self.label)
        self.session.delete_all_dynamodb_sessions()
        with self.assertRaises(RuntimeError) as context:
            self.session._cache.switch(self.label)
        self.assertTrue("Non-existing index or alias '%s'." % self.label in context.exception)

    def test_delete_should_remove_requested_session(self):
        """Delete session should successfully remove requested existing session."""
        self.session.create_dynamodb_session(self.region)
        self.session.create_dynamodb_session(self.region, label=self.label)
        self.session.delete_dynamodb_session(self.region)
        with self.assertRaises(RuntimeError) as context:
            self.session._cache.switch(self.region)
        self.assertTrue("Non-existing index or alias '%s'." % self.region in context.exception)
        try:
            self.session._cache.switch(self.label)
        except RuntimeError:
            self.fail("Label '%s' should be exist." % self.label)
        self.session.delete_all_dynamodb_sessions()
