DYNAMO_NAME = DynamoDBLocal
DYNAMO_URL = http://dynamodb-local.s3-website-us-west-2.amazonaws.com/dynamodb_local_latest.tar.gz

CURL = $(shell which curl 2>/dev/null)
JAVA = $(shell which java 2>/dev/null)

.PHONY: help

help:
	@echo targets: download, run

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
