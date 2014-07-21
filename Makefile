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

DYNAMO_NAME = DynamoDBLocal
DYNAMO_URL = http://dynamodb-local.s3-website-us-west-2.amazonaws.com/dynamodb_local_latest.tar.gz
LIBRARY_NAME = DynamoDBSQLLibrary

CURL = $(shell which curl 2>/dev/null)
JAVA = $(shell which java 2>/dev/null)

.PHONY: help

help:
	@echo targets: clean, version, download, run, pep8, pylint

clean:
	python setup.py clean --all
	rm -rf src/*.egg-info
	find . -iname "*.pyc" -delete
	find . -iname "__pycache__" | xargs rm -rf {} \;
	rm -rf test/test-results

version:
	grep "VERSION = '*'" src/$(LIBRARY_NAME)/version.py

download:
ifeq ($(CURL),)
	@echo "curl is required."
	exit 1
else
ifeq ("$(wildcard ./bin/$(DYNAMO_NAME).jar)","")
	mkdir bin
	$(CURL) -k -L -s $(DYNAMO_URL) | tar -zx -C ./bin
endif
endif

run:download
ifeq ($(JAVA),)
	@echo "java is required."
	exit 1
else
	$(JAVA) -Djava.library.path=./bin/$(DYNAMO_NAME)_lib -jar \
	./bin/$(DYNAMO_NAME).jar -delayTransientStatuses -inMemory \
	2>/dev/null & echo $$! > $@;
endif

pep8:
	pep8 --config=.pep8rc src/$(LIBRARY_NAME)/*.py src/$(LIBRARY_NAME)/keywords/*.py

pylint:
	pylint --rcfile=.pylintrc src/$(LIBRARY_NAME)/*.py src/$(LIBRARY_NAME)/keywords/*.py
