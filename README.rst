Amazon AWS DynamoDB big data testing library for Robot Framework
================================================================

|Validations| |Coverage| |Docs| |Version| |Status| |Python| |Download| |License|

Introduction
------------

DynamoDB SQL Library is a big data testing library for `Robot Framework`_
that gives you the capability to execute scan and query operations against
multi `Amazon DynamoDB`_ sessions simultaneously using a `SQL-like`_ DSL_.

It leverages DynamoDB Query Languange (DQL_) internally to provide a `SQL-like`_ DSL_
for `Amazon DynamoDB`_.

More information about DQL queries can be found in the `DQL Queries Documentation`_.

More information about this library can be found in the `Keyword Documentation`_.

Example
'''''''

+-----------------------------+----------------+------------------------------------------------------+
| Create DynamoDB Session     | us-west-2      | label=oregon                                         |
+-----------------------------+----------------+------------------------------------------------------+
| Create DynamoDB Session     | ap-southeast-1 | label=singapore                                      |
+-----------------------------+----------------+------------------------------------------------------+
| Create DynamoDB Session     | eu-central-1   | label=frankfurt                                      |
+-----------------------------+----------------+------------------------------------------------------+
| Query DynamoDB              | oregon         | CREATE TABLE mine (id STRING HASH KEY)               |
+-----------------------------+----------------+------------------------------------------------------+
| Query DynamoDB              | singapore      | CREATE TABLE mine (id STRING HASH KEY)               |
+-----------------------------+----------------+------------------------------------------------------+
| Query DynamoDB              | frankfurt      | CREATE TABLE mine (id STRING HASH KEY)               |
+-----------------------------+----------------+------------------------------------------------------+
| DynamoDB Table Should Exist | oregon         | mine                                                 |
+-----------------------------+----------------+------------------------------------------------------+
| DynamoDB Table Should Exist | singapore      | mine                                                 |
+-----------------------------+----------------+------------------------------------------------------+
| DynamoDB Table Should Exist | frankfurt      | mine                                                 |
+-----------------------------+----------------+------------------------------------------------------+
| Query DynamoDB              | oregon         | INSERT INTO mine (id) VALUES ('oregon')              |
+-----------------------------+----------------+------------------------------------------------------+
| Query DynamoDB              | singapore      | INSERT INTO mine (id) VALUES ('singapore')           |
+-----------------------------+----------------+------------------------------------------------------+
| Query DynamoDB              | frankfurt      | INSERT INTO mine (id) VALUES ('frankfurt')           |
+-----------------------------+----------------+----------------+-------------------------------------+
| @{oregon} =                 | Query DynamoDB | oregon         | SCAN mine                           |
+-----------------------------+----------------+----------------+-------------------------------------+
| @{singapore} =              | Query DynamoDB | singapore      | SCAN mine                           |
+-----------------------------+----------------+----------------+-------------------------------------+
| @{frankfurt} =              | Query DynamoDB | frankfurt      | SCAN mine                           |
+-----------------------------+----------------+----------------+-------------------------------------+
| List And JSON String Should Be Equal         | ${oregon}      | [{"id":"oregon"}]                   |
+----------------------------------------------+----------------+-------------------------------------+
| List And JSON String Should Be Equal         | ${singapore}   | [{"id":"singapore"}]                |
+----------------------------------------------+----------------+-------------------------------------+
| List And JSON String Should Be Equal         | ${frankfurt}   | [{"id":"frankfurt"}]                |
+----------------------------------------------+----------------+-------------------------------------+
| Delete All Dynamodb Sessions                                                                        |
+-----------------------------------------------------------------------------------------------------+

Config and Credentials File
'''''''''''''''''''''''''''

Set up config file in default location:

- ~/.aws/config (Linux/Mac)
- %USERPROFILE%\\.aws\\config (Windows)

.. code-block:: ini

    [default]
    region = us-east-1

Set up credentials file in default location:

- ~/.aws/credentials (Linux/Mac)
- %USERPROFILE%\\.aws\\credentials (Windows)

.. code-block:: ini

    [default]
    aws_access_key_id = YOUR_KEY
    aws_secret_access_key = YOUR_SECRET

    [another_profile]
    aws_access_key_id = ANOTHER_KEY
    aws_secret_access_key = ANOTHER_SECRET
    region = us-west-1

Installation
------------

Using ``pip``
'''''''''''''

The recommended installation method is using pip_:

.. code:: bash

    python -m pip install robotframework-dynamodbsqllibrary

The main benefit of using ``pip`` is that it automatically installs all
dependencies needed by the library. Other nice features are easy upgrading
and support for un-installation:

.. code:: bash

    python -m pip install --upgrade robotframework-dynamodbsqllibrary
    python -m pip uninstall robotframework-dynamodbsqllibrary

Notice that using ``--upgrade`` above updates both the library and all
its dependencies to the latest version. If you want, you can also install
a specific version or upgrade only the dql_ package used by the library:

.. code:: bash

    python -m pip install robotframework-dynamodbsqllibrary==x.x.x
    python -m pip install --upgrade dql
    python -m pip install dql==x.x.x

Proxy configuration
'''''''''''''''''''

If you are behind a proxy, you can use ``--proxy`` command line option
or set ``http_proxy`` and/or ``https_proxy`` environment variables to
configure ``pip`` to use it. If you are behind an authenticating NTLM proxy,
you may want to consider installing CNTML_ to handle communicating with it.

For more information about ``--proxy`` option and using pip with proxies
in general see:

- https://pip.pypa.io/en/stable/cli/pip/#cmdoption-proxy
- https://stackoverflow.com/questions/9698557/how-to-use-pip-on-windows-behind-an-authenticating-proxy
- https://stackoverflow.com/questions/14149422/using-pip-behind-a-proxy

Manual installation
'''''''''''''''''''

If you do not have network connection or cannot make proxy to work, you need
to resort to manual installation. This requires installing both the library
and its dependencies yourself.

- Make sure you have `Robot Framework installed`_.

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

To write tests with Robot Framework and DynamoDB SQL Library,
DynamoDB SQL Library must be imported into your Robot test suite.
See `Robot Framework User Guide`_ for more information.

More information about Robot Framework standard libraries and built-in tools
can be found in the `Robot Framework Documentation`_.

Building Keyword Documentation
------------------------------

The `Keyword Documentation`_ can be found online, if you need to generate the keyword documentation, run:

.. code:: bash

    make doc

Run Unit Tests, Acceptance Tests, and Test Coverage Report
----------------------------------------------------------

Test the testing library, talking about dogfooding, let's run:

.. code:: bash

    make test

Contributing
------------

If you would like to contribute code to DynamoDB SQL Library repository, you can do so through GitHub by forking the repository and sending a pull request.

If you do not agree to `Contribution Agreement`_, do not contribute any code to DynamoDB SQL Library repository.

When submitting code, please make every effort to follow existing conventions and style in order to keep the code as readable as possible. Please also include appropriate test cases.

That's it! Thank you for your contribution!

License
-------

Copyright (c) 2014 - 2023 Richard Huang.

This library is free software, licensed under: `GNU Affero General Public License (AGPL-3.0)`_.

Documentation and other similar content are provided under `Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License`_.

.. _Amazon DynamoDB: https://bit.ly/3SgjyQA
.. _Contribution Agreement: CONTRIBUTING.md
.. _CNTML: https://bit.ly/3IxTVXZ
.. _Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License: https://bit.ly/2SMCRlS
.. _dql: https://bit.ly/3IaeVCW
.. _DQL Queries Documentation: https://bit.ly/3lFPzFj
.. _DSL: https://bit.ly/3lAWXli
.. _GNU Affero General Public License (AGPL-3.0): https://bit.ly/2yi7gyO
.. _Keyword Documentation: https://bit.ly/3SayD5V
.. _pip: https://bit.ly/3xzSLVU
.. _Robot Framework: https://bit.ly/3k0gKug
.. _Robot Framework Documentation: https://bit.ly/3xziFc4
.. _Robot Framework installed: https://bit.ly/3YEmfxr
.. _Robot Framework User Guide: https://bit.ly/410hgsR
.. _SQL-like: https://bit.ly/3lFPzFj
.. |Validations| image:: https://github.com/rickypc/robotframework-dynamodbsqllibrary/actions/workflows/validations.yml/badge.svg
    :target: https://bit.ly/3IvXeyW
    :alt: Validation Status
.. |Coverage| image:: https://img.shields.io/codecov/c/github/rickypc/robotframework-dynamodbsqllibrary.svg
    :target: https://bit.ly/3XLr1rH
    :alt: Code Coverage
.. |Docs| image:: https://img.shields.io/badge/docs-latest-brightgreen.svg
    :target: https://bit.ly/3SayD5V
    :alt: Keyword Documentation
.. |Version| image:: https://img.shields.io/pypi/v/robotframework-dynamodbsqllibrary.svg
    :target: https://bit.ly/3EjaggS
    :alt: Package Version
.. |Status| image:: https://img.shields.io/pypi/status/robotframework-dynamodbsqllibrary.svg
    :target: https://bit.ly/3EjaggS
    :alt: Development Status
.. |Python| image:: https://img.shields.io/pypi/pyversions/robotframework-dynamodbsqllibrary.svg
    :target: https://bit.ly/3Iz6baY
    :alt: Python Version
.. |Download| image:: https://img.shields.io/pypi/dm/robotframework-dynamodbsqllibrary.svg
    :target: https://bit.ly/3EjaggS
    :alt: Monthly Download
.. |License| image:: https://img.shields.io/pypi/l/robotframework-dynamodbsqllibrary.svg
    :target: https://bit.ly/2yi7gyO
    :alt: License
