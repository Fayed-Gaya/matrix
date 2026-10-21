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

# Temporary preservation guard; remove only with authorized archive deletion.
archive-check:
	python3 scripts/validate_archive.py

# Fresh imports and all ten routes without Python/archive or existing cache.
runtime-check:
	python3 scripts/validate_runtime.py --godot "$(GODOT)"

# Actual native editor open/paint/save verification in a disposable project.
.PHONY: editor-map-check
editor-map-check:
	python3 scripts/validate_native_editor.py --godot "$(GODOT)"

.PHONY: web-templates web-export web-serve
web-templates:
	python3 scripts/setup_godot.py --templates

web-export:
	python3 scripts/web_export.py --godot "$(GODOT)"

web-serve:
	python3 -m http.server 8060 --bind 127.0.0.1 --directory exports/web
