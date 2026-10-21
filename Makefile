.PHONY: check editor run legacy-check hub-map

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

# Rebuild after editing hub/assets/maps/matrix.tmx in Tiled.
hub-map:
	"$(GODOT)" --headless --path . --import
	python3 scripts/convert_hub_map.py --godot "$(GODOT)"

.PHONY: untitled-map
untitled-map:
	"$(GODOT)" --headless --path . --import
	python3 scripts/convert_hub_map.py --godot "$(GODOT)" --map levels/untitled/assets/maps/untitled-intro.tmx --spawn player --output res://levels/untitled/world.tscn --world-script res://levels/untitled/world.gd
