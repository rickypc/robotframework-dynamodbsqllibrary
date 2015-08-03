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

DYNAMO_NAME = DynamoDBLocal
DYNAMO_URL = http://dynamodb-local.s3-website-us-west-2.amazonaws.com/dynamodb_local_latest.tar.gz
LIBRARY_NAME = DynamoDBSQLLibrary

CURL = $(shell which curl 2>/dev/null)
JAVA = $(shell which java 2>/dev/null)
SHELL := /bin/bash
lc = $(subst A,a,$(subst B,b,$(subst C,c,$(subst D,d,$(subst E,e,$(subst F,f,$(subst G,g,$(subst H,h,$(subst I,i,$(subst J,j,$(subst K,k,$(subst L,l,$(subst M,m,$(subst N,n,$(subst O,o,$(subst P,p,$(subst Q,q,$(subst R,r,$(subst S,s,$(subst T,t,$(subst U,u,$(subst V,v,$(subst W,w,$(subst X,x,$(subst Y,y,$(subst Z,z,$1))))))))))))))))))))))))))

define AWS_CREDENTIALS
[default]
aws_access_key_id = ACCESS_KEY
aws_secret_access_key = SECRET_KEY

[profile1]
aws_access_key_id = ACCESS_KEY_1
aws_secret_access_key = SECRET_KEY_1
region = us-west-1

[profile2]
aws_access_key_id = ACCESS_KEY_2
aws_secret_access_key = SECRET_KEY_2
region = us-west-2
endef

export AWS_CREDENTIALS

.PHONY: help test

help:
	@echo targets: clean, clean_dist, version, install_devel_deps, download, run, \
	lint, test, test_unit, test_acceptance, doc, github_doc, testpypi, pypi

clean:
	python setup.py clean --all
	rm -rf .coverage htmlcov src/*.egg-info test/test-results
	find . -iname "*.pyc" -delete
	find . -iname "__pycache__" | xargs rm -rf {} \;

clean_dist:
	rm -rf dist

version:
	python -m robot.libdoc src/$(LIBRARY_NAME) version

install_devel_deps:
	pip install -e .
	pip install coverage mock
	mkdir -p ~/.aws
	[ -f ~/.aws/config ] && mv ~/.aws/config ~/.aws/config.bak || true
	[ -f ~/.aws/credentials ] && mv ~/.aws/credentials ~/.aws/credentials.bak || true
	@echo -e "[default]\nregion=us-east-1" > ~/.aws/config
	@echo "$$AWS_CREDENTIALS" > ~/.aws/credentials

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
	>/dev/null 2>&1 & echo $$! > $@;
endif

lint:clean
	flake8 --max-complexity 10
	pylint --rcfile=setup.cfg src/$(LIBRARY_NAME)/*.py src/$(LIBRARY_NAME)/keywords/*.py

test:test_unit test_acceptance

test_acceptance: run
	pybot -L DEBUG -d test/test-results test/atest/suites/ && { kill `cat $<` && rm $<; } || \
	{ kill `cat $<` && rm $<; exit 1; }

test_unit:
	PYTHONPATH=./src: coverage run --source=src -m unittest discover test/utest
	coverage report

doc:clean
	python -m robot.libdoc src/$(LIBRARY_NAME) doc/$(LIBRARY_NAME).html
	python -m analytics doc/$(LIBRARY_NAME).html

github_doc:clean
	git checkout gh-pages
	git merge master
	git push origin gh-pages
	git checkout master

testpypi:clean_dist doc
	python setup.py register -r test
	python setup.py sdist upload -r test --sign
	@echo https://testpypi.python.org/pypi/robotframework-$(call lc,$(LIBRARY_NAME))/

pypi:clean_dist doc
	python setup.py register -r pypi
	python setup.py sdist upload -r pypi --sign
	@echo https://pypi.python.org/pypi/robotframework-$(call lc,$(LIBRARY_NAME))/
