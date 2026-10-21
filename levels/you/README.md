# You — YOU

Entering YOU attempts to start the first camera exposed by Godot. The preview
uses the source's 640×480 logical field, fitted into the shared resizable window.
Escape returns to Matrix and releases the feed. No images are recorded, saved,
transmitted or persisted by the level.

This is a native GDScript CameraServer/CameraFeed/CameraTexture port of
`legacy/pygame/levels/you/you.py`. It requests the closest declared format to
640×480, or uses the backend default when formats are not exposed. RGB and
combined/separate YCbCr textures are displayed through a Compatibility canvas
shader, applying the feed's UV transform. YCbCr conversion assumes full-range
BT.601; actual device color profiles still need testing. External-texture feeds
are reported as unsupported rather than displayed incorrectly.

**Platform limitation:** stock Godot exposes camera feeds on Linux, macOS, iOS
and Android, according to its current CameraServer documentation. Windows and
web have no stock camera backend. Those platforms show an unavailable message;
full cross-platform capture parity is blocked pending a separately chosen native
extension/browser integration. None is introduced here. Mobile export modules,
OS permissions and usage descriptions also need platform packaging work.

See the official [CameraServer](https://docs.godotengine.org/en/latest/classes/class_cameraserver.html),
[CameraFeed](https://docs.godotengine.org/en/latest/classes/class_camerafeed.html)
and [CameraTexture](https://docs.godotengine.org/en/latest/classes/class_cameratexture.html)
references. These are moving/latest documentation; property names and virtual
methods used here were also inspected in the installed Godot 4.7.2 ClassDB.

Differences from the source: missing/denied/disconnected devices show a message
instead of crashing; camera failure cannot terminate Matrix. The shared window
replaces a separate fixed-size window. The level restores prior monitoring/feed
activity on exit; no new device picker, recording, account or persistence exists.
If no frames arrive after five seconds, it reports the permission/device check.

Automated checks use only a synthetic CameraFeed and disable real-device startup
with root metadata `matrix_test_mode`. They cover format selection, RGB output,
vertical orientation, combined/separate YCbCr neutral-gray conversion, resize,
disconnection and release on Escape. The actual Compatibility-window pixels
passed checks and the synthetic capture was inspected. CameraTexture internally
enables device monitoring even for a synthetic feed; tests activate no physical
feed and restore monitoring on exit. The general hub suite also skips hardware.

**Not verified:** live capture, permission allow/deny flows, actual camera LED
shutdown/re-entry, device-specific orientation/colors/resolution, unplugging real
hardware, or exported platforms. Enter YOU during manual playtesting on this Mac
and check those behaviors. Successful synthetic tests are not camera parity.
