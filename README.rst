Amazon AWS DynamoDB big data testing library for Robot Framework
================================================================

Introduction
------------

DynamoDBSQLibrary is a big data testing library for `Robot Framework`_
that gives you the capability to execute scan and query operations against
multi `Amazon DynamoDB`_ sessions simultaneously using a `SQL-like`_ DSL_.

It leverages DynamoDB Query Languange (DQL_) internally to provide a `SQL-like`_ DSL_
for `Amazon DynamoDB`_.

More information about DQL queries can be found in the `DQL Queries Documentation`_.

More information about this library can be found in the `Keyword Documentation`_.

Example
'''''''

+-----------------------------+----------------+----------------+-------------------+-----------------+
| Create DynamoDB Session     | us-west-2      | access_key=key | secret_key=secret | label=oregon    |
+-----------------------------+----------------+----------------+-------------------+-----------------+
| Create DynamoDB Session     | ap-southeast-1 | access_key=key | secret_key=secret | label=singapore |
+-----------------------------+----------------+----------------+-------------------+-----------------+
| Create DynamoDB Session     | eu-central-1   | access_key=key | secret_key=secret | label=frankfurt |
+-----------------------------+----------------+----------------+-------------------+-----------------+
| Query DynamoDB              | oregon         | CREATE TABLE mine (id STRING HASH KEY)               |
+-----------------------------+----------------+----------------+-------------------+-----------------+
| Query DynamoDB              | singapore      | CREATE TABLE mine (id STRING HASH KEY)               |
+-----------------------------+----------------+----------------+-------------------+-----------------+
| Query DynamoDB              | frankfurt      | CREATE TABLE mine (id STRING HASH KEY)               |
+-----------------------------+----------------+----------------+-------------------+-----------------+
| DynamoDB Table Should Exist | oregon         | mine                                                 |
+-----------------------------+----------------+----------------+-------------------+-----------------+
| DynamoDB Table Should Exist | singapore      | mine                                                 |
+-----------------------------+----------------+----------------+-------------------+-----------------+
| DynamoDB Table Should Exist | frankfurt      | mine                                                 |
+-----------------------------+----------------+----------------+-------------------+-----------------+
| Query DynamoDB              | oregon         | INSERT INTO mine (id) VALUES ('oregon')              |
+-----------------------------+----------------+----------------+-------------------+-----------------+
| Query DynamoDB              | singapore      | INSERT INTO mine (id) VALUES ('singapore')           |
+-----------------------------+----------------+----------------+-------------------+-----------------+
| Query DynamoDB              | frankfurt      | INSERT INTO mine (id) VALUES ('frankfurt')           |
+-----------------------------+----------------+----------------+-------------------+-----------------+
| @{oregon} =                 | Query DynamoDB | oregon         | SCAN mine                           |
+-----------------------------+----------------+----------------+-------------------+-----------------+
| @{singapore} =              | Query DynamoDB | singapore      | SCAN mine                           |
+-----------------------------+----------------+----------------+-------------------+-----------------+
| @{frankfurt} =              | Query DynamoDB | frankfurt      | SCAN mine                           |
+-----------------------------+----------------+----------------+-------------------+-----------------+
| List And JSON String Should Be Equal         | ${oregon}      | [{"id":"oregon"}]                   |
+-----------------------------+----------------+----------------+-------------------+-----------------+
| List And JSON String Should Be Equal         | ${singapore}   | [{"id":"singapore"}]                |
+-----------------------------+----------------+----------------+-------------------+-----------------+
| List And JSON String Should Be Equal         | ${frankfurt}   | [{"id":"frankfurt"}]                |
+-----------------------------+----------------+----------------+-------------------+-----------------+
| Delete All Dynamodb Sessions                                                                        |
+-----------------------------+----------------+----------------+-------------------+-----------------+

Installation
------------

Using ``pip``
'''''''''''''

The recommended installation method is using `pip <http://pip-installer.org>`__:

.. code:: bash

    pip install robotframework-dynamodbsqllibrary

The main benefit of using ``pip`` is that it automatically installs all
dependencies needed by the library. Other nice features are easy upgrading
and support for un-installation:

.. code:: bash

    pip install --upgrade robotframework-dynamodbsqllibrary
    pip uninstall robotframework-dynamodbsqllibrary

Notice that using ``--upgrade`` above updates both the library and all
its dependencies to the latest version. If you want, you can also install
a specific version or upgrade only the dql_ package used by the library:

.. code:: bash

    pip install robotframework-dynamodbsqllibrary==x.x.x
    pip install --upgrade dql
    pip install dql==x.x.x

Proxy configuration
'''''''''''''''''''

If you are behind a proxy, you can use ``--proxy`` command line option
or set ``http_proxy`` and/or ``https_proxy`` environment variables to
configure ``pip`` to use it. If you are behind an authenticating NTLM proxy,
you may want to consider installing `CNTML <http://cntlm.sourceforge.net>`__
to handle communicating with it.

For more information about ``--proxy`` option and using pip with proxies
in general see:

- http://pip-installer.org/en/latest/usage.html
- http://stackoverflow.com/questions/9698557/how-to-use-pip-on-windows-behind-an-authenticating-proxy
- http://stackoverflow.com/questions/14149422/using-pip-behind-a-proxy

Manual installation
'''''''''''''''''''

If you do not have network connection or cannot make proxy to work, you need
to resort to manual installation. This requires installing both the library
and its dependencies yourself.

- Make sure you have `Robot Framework installed <http://code.google.com/p/robotframework/wiki/Installation>`__.

- Download source distributions (``*.tar.gz``) for the library and its dependencies:

  - https://pypi.python.org/pypi/robotframework-dynamodbsqllibrary
  - https://pypi.python.org/pypi/dql

- Download PGP signatures (``*.tar.gz.asc``) for signed packages.

- Find each public key used to sign the package:

.. code:: bash

    gpg --keyserver pgp.mit.edu --search-keys D1406DE7

- Select the number from the list to import the public key

- Verify the package against its PGP signature:

.. code:: bash

    gpg --verify robotframework-dynamodbsqllibrary-x.x.x.tar.gz.asc robotframework-dynamodbsqllibrary-x.x.x.tar.gz

- Extract each source distribution to a temporary location.

- Go to each created directory from the command line and install each project using:

.. code:: bash

       python setup.py install

If you are on Windows, and there are Windows installers available for
certain projects, you can use them instead of source distributions.
Just download 32bit or 64bit installer depending on your system,
double-click it, and follow the instructions.

Directory Layout
----------------

doc/
    `Keyword documentation`_

src/
    Python source code

test/
     Test files

     atest/
           `Robot Framework`_ acceptance test

     utest/
           Python unit test

Usage
-----

To write tests with Robot Framework and DynamoDBSQLLibrary,
DynamoDBSQLLibrary must be imported into your Robot test suite.
See `Robot Framework User Guide`_ for more information.

Building Keyword Documentation
------------------------------

The `Keyword Documentation`_ can be found online, if you need to generate the keyword documentation, run:

.. code:: bash

    make doc

Run Unit Tests, Acceptance Tests, and Test Coverage Report
----------------------------------------------------------

.. code:: bash

    make test

License
-------

Copyright (c) 2014 - 2015 Richard Huang.

This library is free software, licensed under: `GNU Affero General Public License (AGPL-3.0) <http://www.gnu.org/licenses/agpl-3.0.en.html>`_.

Documentation and other similar content are provided under `Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-nc-sa/4.0/>`_.

.. _Amazon DynamoDB: https://aws.amazon.com/dynamodb/
.. _dql: https://dql.readthedocs.org/en/latest/
.. _DQL Queries Documentation: https://dql.readthedocs.org/en/latest/topics/queries/index.html
.. _DSL: https://en.wikipedia.org/wiki/Domain-specific_language
.. _Keyword Documentation: https://rickypc.github.io/robotframework-dynamodbsqllibrary/doc/DynamoDBSQLLibrary.html
.. _Robot Framework: http://robotframework.org
.. _Robot Framework User Guide: http://code.google.com/p/robotframework/wiki/UserGuide
.. _SQL-like: https://dql.readthedocs.org/en/latest/topics/queries/index.html
