DC := $(shell command -v docker-compose 2> /dev/null)
ifeq (DC,)
DC = $(shell which docker-compose)
else
DC = $(shell which docker) compose
endif

default: help
	@echo ""
	@echo "You need to specify a subcommand."
	@exit 1

help:
	@echo "build         - build docker images for dev"
	@echo "run           - docker-compose up the entire system for dev"
	@echo ""
	@echo "djshell       - start a Django Python shell (ipython)"
	@echo "shell         - start a bash shell"
	@echo "runshell      - start a bash shell with ports bound so you can run the server"
	@echo "clean         - remove all build, test, coverage and Python artifacts"
	@echo "rebuild       - force a rebuild of the dev docker image"
	@echo "lint          - run pre-commit hooks"
	@echo "test          - run python tests"
	@echo "docs          - generate Sphinx HTML documentation"


.docker-build:
	${MAKE} build

build:
	${DC} -f local.yml build django
	touch .docker-build

rebuild: clean build

run: .docker-build
	${DC} -f local.yml up django

shell: .docker-build
	${DC} -f local.yml run --rm django bash

runshell: .docker-build
	${DC} -f local.yml run --rm --service-ports django bash

djshell: .docker-build
	${DC} -f local.yml run --rm django python manage.py shell

clean:
#	python related things
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -rf {} +
#	test related things
	-rm -f .coverage
#	docs files
	-rm -rf docs/_build/
#	state files
	-rm -f .docker-build*

lint: .docker-build
	pre-commit run --all-files
	${DC} -f local.yml run --rm django mypy blog_app
	${DC} -f local.yml run --rm django pylint blog_app

test: .docker-build
	${DC} -f local.yml run --rm django ./bin/run-unit-tests.sh

docs: .docker-build
	${DC} -f local.yml run --rm django $(MAKE) -C docs/ clean
	${DC} -f local.yml run --rm django $(MAKE) -C docs/ html

.PHONY: build rebuild run shell runshell djshell clean lint test docs
