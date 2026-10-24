# The Bug — BUG

The original cat/mouse debugging experiment: a white 600×600 logical field,
unchanged `cat.png` at (15,20), black-backed coordinate and three-button-state
text at (10,10)/(10,40), and “mouse!” following the mouse. Left/middle/right
states retain the Python tuple presentation. Escape returns to Matrix.

The field fits the shared resizable window. Mouse coordinates are mapped into
logical field space; fonts/rasterization differ from Pygame. Outside-field
positions may be negative or beyond 600, and debug text is clipped, like the
source window. No sound or gameplay objectives existed in the source.

Asset source: [original Pygame source](https://github.com/Fayed-Gaya/matrix/blob/55c803c4c8488db9dd17b36bbecd62f775cd52d8/legacy/pygame/levels/the_bug/cat.png), copied unchanged; no new
licensing/authorship claim. Runtime is independent of the archive and Python.
The optional historical behavior suite sends mouse movement and all three button events and checks
routing/return. Manual checking on other input devices/platforms remains needed.
