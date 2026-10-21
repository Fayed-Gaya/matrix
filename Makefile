.PHONY: check editor run legacy-check archive-check runtime-check

GODOT ?= /Applications/Godot.app/Contents/MacOS/Godot
PYTHON ?= ../../.venv/bin/python

check: archive-check
	python3 scripts/validate_godot.py --godot "$(GODOT)"

editor:
	"$(GODOT)" --path . --editor

run:
	"$(GODOT)" --path .

legacy-check:
	$(MAKE) -C legacy/pygame PYTHON="$(PYTHON)" check

.PHONY: untitled-map
untitled-map:
	"$(GODOT)" --headless --path . --import
	python3 scripts/convert_hub_map.py --godot "$(GODOT)" --map levels/untitled/assets/maps/untitled-intro.tmx --spawn player --output res://levels/untitled/world.tscn --world-script res://levels/untitled/world.gd

# Temporary preservation guard; remove only with authorized archive deletion.
archive-check:
	python3 scripts/validate_archive.py

# Fresh imports and all ten routes without Python/archive or existing cache.
runtime-check:
	python3 scripts/validate_runtime.py --godot "$(GODOT)"
