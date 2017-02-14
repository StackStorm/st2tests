ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
SHELL := /bin/bash
TOX_DIR := .tox
VIRTUALENV_DIR ?= virtualenv

BINARIES := bin

# All components are prefixed by st2
COMPONENTS := $(wildcard st2*)
COMPONENTS += $(wildcard contrib/runners/*)

# Components that implement a component-controlled test-runner. These components provide an
# in-component Makefile. (Temporary fix until I can generalize the pecan unittest setup. -mar)
# Note: We also want to ignore egg-info dir created during build
COMPONENT_SPECIFIC_TESTS := st2tests st2client.egg-info

# nasty hack to get a space into a variable
space_char :=
space_char +=
comma := ,
COMPONENT_PYTHONPATH = $(subst $(space_char),:,$(realpath $(COMPONENTS)))
COMPONENTS_TEST := $(foreach component,$(filter-out $(COMPONENT_SPECIFIC_TESTS),$(COMPONENTS)),$(component))
COMPONENTS_TEST_COMMA := $(subst $(space_char),$(comma),$(COMPONENTS_TEST))

PYTHON_TARGET := 2.7

REQUIREMENTS := test-requirements.txt
PIP_OPTIONS := $(ST2_PIP_OPTIONS)

NOSE_OPTS := --rednose --immediate
NOSE_TIME := $(NOSE_TIME)

ifdef NOSE_TIME
	NOSE_OPTS := --rednose --immediate --with-timer
endif

ifndef PIP_OPTIONS
	PIP_OPTIONS := -U -q
endif

.PHONY: all
all: pylint

.PHONY: pylint
pylint: requirements .pylint

.PHONY: .pylint
.pylint:
	@echo
	@echo "================== pylint ===================="
	@echo
	. $(VIRTUALENV_DIR)/bin/activate; pylint -E --rcfile=./lint-configs/python/.pylintrc packs/fixtures/actions/pythonactions/*.py || exit 1;
	. $(VIRTUALENV_DIR)/bin/activate; pylint -E --rcfile=./lint-configs/python/.pylintrc packs/fixtures/actions/pythonactions/scripts/*.py || exit 1;
	. $(VIRTUALENV_DIR)/bin/activate; pylint -E --rcfile=./lint-configs/python/.pylintrc packs/fixtures/actions/pythonactions/scripts/*/*.py || exit 1;
	. $(VIRTUALENV_DIR)/bin/activate; pylint -E --rcfile=./lint-configs/python/.pylintrc packs/fixtures/actions/sensors/*.py || exit 1;
	. $(VIRTUALENV_DIR)/bin/activate; pylint -E --rcfile=./lint-configs/python/.pylintrc packs/asserts/actions/*.py || exit 1;
	
.PHONY: flake8
flake8: requirements .flake8

.PHONY: .flake8
.flake8:
	@echo
	@echo "==================== flake ===================="
	@echo
	. $(VIRTUALENV_DIR)/bin/activate; flake8 --config ./lint-configs/python/.flake8 packs/fixtures/actions/pythonactions/*.py
	. $(VIRTUALENV_DIR)/bin/activate; flake8 --config ./lint-configs/python/.flake8 packs/fixtures/actions/pythonactions/scripts/*.py
	. $(VIRTUALENV_DIR)/bin/activate; flake8 --config ./lint-configs/python/.flake8 packs/fixtures/actions/pythonactions/*/*.py
	. $(VIRTUALENV_DIR)/bin/activate; flake8 --config ./lint-configs/python/.flake8 packs/fixtures/actions/sensors/*.py
	. $(VIRTUALENV_DIR)/bin/activate; flake8 --config ./lint-configs/python/.flake8 packs/asserts/actions/*.py

.PHONY: lint
lint: requirements .lint

.PHONY: .lint
.lint: .flake8

.PHONY: requirements
requirements: virtualenv
	@echo
	@echo "==================== requirements ===================="
	@echo

	# Make sure we use latest version of pip
	$(VIRTUALENV_DIR)/bin/pip install --upgrade "pip>=8.1.2,<8.2"
	$(VIRTUALENV_DIR)/bin/pip install virtualenv  # Required for packs.install in dev envs.

	# Install requirements
	for req in $(REQUIREMENTS); do \
			echo "Installing $$req..." ; \
			$(VIRTUALENV_DIR)/bin/pip install $(PIP_OPTIONS) -r $$req ; \
	done

.PHONY: virtualenv
virtualenv: $(VIRTUALENV_DIR)/bin/activate
$(VIRTUALENV_DIR)/bin/activate:
	@echo
	@echo "==================== virtualenv ===================="
	@echo
	test -d $(VIRTUALENV_DIR) || virtualenv --no-site-packages $(VIRTUALENV_DIR)

	# Setup PYTHONPATH in bash activate script...
	echo '' >> $(VIRTUALENV_DIR)/bin/activate
	echo '_OLD_PYTHONPATH=$$PYTHONPATH' >> $(VIRTUALENV_DIR)/bin/activate
	echo 'PYTHONPATH=$$_OLD_PYTHONPATH:$(COMPONENT_PYTHONPATH)' >> $(VIRTUALENV_DIR)/bin/activate
	echo 'export PYTHONPATH' >> $(VIRTUALENV_DIR)/bin/activate
	touch $(VIRTUALENV_DIR)/bin/activate

	# Setup PYTHONPATH in fish activate script...
	echo '' >> $(VIRTUALENV_DIR)/bin/activate.fish
	echo 'set -gx _OLD_PYTHONPATH $$PYTHONPATH' >> $(VIRTUALENV_DIR)/bin/activate.fish
	echo 'set -gx PYTHONPATH $$_OLD_PYTHONPATH $(COMPONENT_PYTHONPATH)' >> $(VIRTUALENV_DIR)/bin/activate.fish
	echo 'functions -c deactivate old_deactivate' >> $(VIRTUALENV_DIR)/bin/activate.fish
	echo 'function deactivate' >> $(VIRTUALENV_DIR)/bin/activate.fish
	echo '  if test -n $$_OLD_PYTHONPATH' >> $(VIRTUALENV_DIR)/bin/activate.fish
	echo '    set -gx PYTHONPATH $$_OLD_PYTHONPATH' >> $(VIRTUALENV_DIR)/bin/activate.fish
	echo '    set -e _OLD_PYTHONPATH' >> $(VIRTUALENV_DIR)/bin/activate.fish
	echo '  end' >> $(VIRTUALENV_DIR)/bin/activate.fish
	echo '  old_deactivate' >> $(VIRTUALENV_DIR)/bin/activate.fish
	echo '  functions -e old_deactivate' >> $(VIRTUALENV_DIR)/bin/activate.fish
	echo 'end' >> $(VIRTUALENV_DIR)/bin/activate.fish
	touch $(VIRTUALENV_DIR)/bin/activate.fish
