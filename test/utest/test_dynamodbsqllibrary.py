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

import unittest
from sys import path
path.append('src')
from DynamoDBSQLLibrary import DynamoDBSQLLibrary  # noqa: E402
from DynamoDBSQLLibrary.keywords import Assertion, Query, SessionManager  # noqa: E402


class DynamoDBSQLLibraryTests(unittest.TestCase):
    """DynamoDB SQL library test class."""

    def test_should_inherit_keywords(self):
        """DynamoDB SQL library instance should inherit keyword instances."""
        library = DynamoDBSQLLibrary()
        self.assertIsInstance(library, Assertion)
        self.assertIsInstance(library, Query)
        self.assertIsInstance(library, SessionManager)
