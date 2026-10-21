.PHONY: check editor run legacy-check

GODOT ?= /Applications/Godot.app/Contents/MacOS/Godot
PYTHON ?= ../../.venv/bin/python

check:
	python3 scripts/validate_godot.py --godot "$(GODOT)"

editor:
	"$(GODOT)" --path . --editor

run:
	"$(GODOT)" --path .

legacy-check:
	$(MAKE) -C legacy/pygame PYTHON="$(PYTHON)" check
