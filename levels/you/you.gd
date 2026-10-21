class_name YouLevel
extends MatrixLevel
## Native first-camera preview. Tests inject CameraFeed frames without hardware.

const CAMERA_SHADER: Shader = preload("res://levels/you/camera.gdshader")
const FIELD_SIZE: Vector2 = Vector2(640,480)
var feed: CameraFeed
var primary: CameraTexture
var chroma: CameraTexture
var camera_material: ShaderMaterial
var previous_monitoring: bool = false
var previous_active: bool = false
var test_mode: bool = false
var attempted: bool = false
var elapsed: float = 0
var field_scale: float = 1
var field_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	test_mode = bool(get_tree().root.get_meta("matrix_test_mode",false))
	previous_monitoring = CameraServer.monitoring_feeds
	resized.connect(fit_field)
	fit_field()
	if test_mode:
		$Status.text = "No camera active. Escape: return to Matrix"
		return
	if OS.has_feature("web"):
		$Status.text = "YOU: live camera capture is unavailable in this browser build. Play the native macOS version for camera capture. Escape returns to Matrix."
		return
	if OS.get_name() not in ["macOS","Linux","iOS","Android"]:
		$Status.text = "Camera capture is unavailable on this platform in stock Godot."
		return
	CameraServer.camera_feeds_updated.connect(find_camera,CONNECT_DEFERRED)
	CameraServer.camera_feed_removed.connect(camera_removed,CONNECT_DEFERRED)
	CameraServer.monitoring_feeds = true
	$Status.text = "Looking for a camera. Allow camera access if prompted."
	find_camera()


func fit_field() -> void:
	field_scale = minf(size.x/FIELD_SIZE.x,size.y/FIELD_SIZE.y)
	field_offset = (size-FIELD_SIZE*field_scale)/2
	$Preview.position = field_offset
	$Preview.size = FIELD_SIZE*field_scale
	queue_redraw()


func find_camera() -> void:
	if not is_inside_tree() or attempted or test_mode:
		return
	var feeds: Array[CameraFeed] = CameraServer.feeds()
	if not feeds.is_empty():
		start_capture(feeds[0])


func start_capture(camera: CameraFeed) -> bool:
	stop_capture()
	attempted = true
	elapsed = 0
	feed = camera
	previous_active = feed.feed_is_active
	# Formats are backend-specific; use the closest declared size if available.
	# An empty list means the backend chooses its own supported default.
	if not previous_active:
		var formats: Array = feed.formats
		var best: int = -1
		var distance: float = INF
		for i: int in range(formats.size()):
			var format: Dictionary = formats[i]
			if format.has("width") and format.has("height"):
				var candidate: float = absf(float(format.width)-640)+absf(float(format.height)-480)
				if candidate < distance:
					distance = candidate
					best = i
		if best >= 0:
			feed.set_format(best,{})
		feed.feed_is_active = true
	if not feed.feed_is_active:
		$Status.text = "Camera could not start. Check permission and device availability."
		return false
	primary = CameraTexture.new()
	primary.camera_feed_id = feed.get_id()
	primary.which_feed = CameraServer.FEED_RGBA_IMAGE
	chroma = CameraTexture.new()
	chroma.camera_feed_id = feed.get_id()
	chroma.which_feed = CameraServer.FEED_CBCR_IMAGE
	# CameraTexture enables monitoring internally; restore it on level exit.
	camera_material = ShaderMaterial.new()
	camera_material.shader = CAMERA_SHADER
	camera_material.set_shader_parameter("chroma_texture",chroma)
	$Preview.texture = primary
	$Preview.material = camera_material
	$Status.text = "Waiting for camera frames."
	update_preview()
	return true


func update_preview() -> void:
	if feed == null or camera_material == null:
		return
	var type: int = feed.get_datatype()
	$Preview.visible = type in [CameraFeed.FEED_RGB,CameraFeed.FEED_YCBCR,CameraFeed.FEED_YCBCR_SEP]
	if $Preview.visible:
		camera_material.set_shader_parameter("feed_type",type)
		var transform: Transform2D = feed.feed_transform
		camera_material.set_shader_parameter("uv_x",transform.x)
		camera_material.set_shader_parameter("uv_y",transform.y)
		camera_material.set_shader_parameter("uv_origin",transform.origin)
		$Status.text = ""
	elif type == CameraFeed.FEED_EXTERNAL:
		$Status.text = "This camera uses an external texture unsupported by this Compatibility preview."


func _process(delta: float) -> void:
	elapsed += delta
	update_preview()
	if elapsed > 5 and $Status.text in ["Waiting for camera frames.","Looking for a camera. Allow camera access if prompted."]:
		$Status.text = "No camera frames available. Check camera access and device availability."


func camera_removed(id: int) -> void:
	if feed != null and feed.get_id() == id:
		stop_capture()
		$Status.text = "Camera disconnected. Escape: return to Matrix"


func stop_capture() -> void:
	$Preview.texture = null
	$Preview.material = null
	$Preview.visible = false
	camera_material = null
	primary = null
	chroma = null
	if feed != null:
		feed.feed_is_active = previous_active
		feed = null


func _exit_tree() -> void:
	if CameraServer.camera_feeds_updated.is_connected(find_camera):
		CameraServer.camera_feeds_updated.disconnect(find_camera)
	if CameraServer.camera_feed_removed.is_connected(camera_removed):
		CameraServer.camera_feed_removed.disconnect(camera_removed)
	stop_capture()
	CameraServer.monitoring_feeds = previous_monitoring


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color.BLACK)
