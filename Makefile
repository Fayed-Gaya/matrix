.PHONY: check format lint

PYTHON ?= .venv/bin/python

lint:
	$(PYTHON) -m ruff check .

format:
	$(PYTHON) -m ruff format .
	$(PYTHON) -m ruff check --fix .

check:
	$(PYTHON) -m ruff check .
	$(PYTHON) -m ruff format --check .
	$(PYTHON) -m compileall main.py matrix levels
