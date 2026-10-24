.PHONY: check smoke-check tools-check regression-check editor run legacy-check archive-check runtime-check

GODOT ?= /Applications/Godot.app/Contents/MacOS/Godot
PYTHON ?= ../../.venv/bin/python

# Level 2: one import and minimal startup/registered-route smoke.
check: smoke-check

smoke-check:
	python3 scripts/validate_godot.py --godot "$(GODOT)"

# Run when changing tooling, not as part of routine game CI.
tools-check:
	python3 -m unittest discover -s scripts/tests -q

# Historical map/trace/walkthrough evidence, explicitly opt-in.
regression-check:
	python3 scripts/validate_godot.py --godot "$(GODOT)" --regression

editor:
	"$(GODOT)" --path . --editor

run:
	"$(GODOT)" --path .

legacy-check:
	$(MAKE) -C legacy/pygame PYTHON="$(PYTHON)" check

# Temporary preservation guard; remove only with authorized archive deletion.
archive-check:
	python3 scripts/validate_archive.py

# Fresh imports and all active routes without Python/archive or existing cache.
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

# Full original ten-level Godot checks from the preserved pre-Alpha-0.2 revision.
.PHONY: archived-godot-check
archived-godot-check:
	python3 scripts/validate_archived_godot.py --godot "$(GODOT)"

# Level 1: import and only selected focused behavior/resources.
CHECKS ?= pegasus
.PHONY: fast-check release-check art-export
fast-check:
	python3 scripts/validate_godot.py --godot "$(GODOT)" --only $(CHECKS)

# Level 3: on-demand checks and local build; never publishes.
release-check:
	$(MAKE) tools-check
	python3 scripts/validate_godot.py --godot "$(GODOT)" --only all resources
	$(MAKE) runtime-check GODOT="$(GODOT)"
	python3 scripts/audit_licenses.py --check
	$(MAKE) web-export GODOT="$(GODOT)"
	$(MAKE) browser-check

.PHONY: browser-check compatibility-check
browser-check:
	cd tests/web && npm test

# Optional Firefox and landscape Chromium/WebKit flows; one destination each.
compatibility-check:
	cd tests/web && npm run test:compat

ASEPRITE ?= /Applications/Aseprite.app/Contents/MacOS/aseprite
art-export:
	python3 scripts/export_art.py --aseprite "$(ASEPRITE)" --source "$(SOURCE)" --output "$(OUTPUT)"
