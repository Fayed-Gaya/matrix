# Godot levels

Each port gets its own directory with scenes, GDScript, assets, and a controls
and parity note. Preserve its mechanics and existing terminal code. Levels run
inside one application and return through the application router in `app/main.gd`.
Do not import Python levels or depend on assets under the removable archive.

A migrated level scene root must extend `MatrixLevel` (`shared/level.gd`).
Keep its nodes, audio and timers under that root. Emit `return_requested` to
return; the router removes/frees the root and resumes the existing pegasus.
The base class handles unconsumed Escape. A level may consume Escape to close
its own menu first. Never quit the application merely to leave a level.

Set the existing code's `scene` path in `app/level_registry.gd` when that port is
ready. Empty paths show the explicit pending screen until then. Do not create
another application/window or add global gameplay autoloads for each level.
