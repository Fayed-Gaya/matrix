extends SceneTree
## Synthetic feeds exercise the native path without opening personal cameras.

class SyntheticFeed extends CameraFeed:
	var stopped: bool = false
	var chosen: int = -1
	func _activate_feed() -> bool:
		return true
	func _deactivate_feed() -> void:
		stopped = true
	func _get_formats() -> Array:
		return [{"width":1280,"height":720},{"width":640,"height":480}]
	func _set_format(index: int,_parameters: Dictionary) -> bool:
		chosen = index
		return true

var app: MatrixApp
var game: YouLevel
var synthetic: SyntheticFeed
var monitoring: bool


func _initialize() -> void:
	root.set_meta("matrix_test_mode",true)
	run.call_deferred()


func settle() -> void:
	await process_frame
	await process_frame


func run() -> void:
	monitoring = CameraServer.monitoring_feeds
	root.size = Vector2i(1280,720)
	app = load("res://app/main.tscn").instantiate() as MatrixApp
	root.add_child(app)
	await settle()
	app.launch_level("YOU")
	await settle()
	game = app.active_level as YouLevel
	assert(game != null and game.feed == null and not game.get_node("Preview").visible)
	assert(CameraServer.monitoring_feeds == monitoring)
	assert(game.field_scale == 1.5 and game.field_offset == Vector2(160,0))
	synthetic = SyntheticFeed.new()
	synthetic.set_name("Synthetic validation feed")
	synthetic.feed_transform = Transform2D.IDENTITY
	CameraServer.add_feed(synthetic)
	assert(game.start_capture(synthetic))
	assert(synthetic.feed_is_active and synthetic.chosen == 1)
	assert(game.primary.camera_feed_id == synthetic.get_id())
	var picture: Image = Image.create(640,480,false,Image.FORMAT_RGB8)
	picture.fill_rect(Rect2i(0,0,320,240),Color.RED)
	picture.fill_rect(Rect2i(320,0,320,240),Color.GREEN)
	picture.fill_rect(Rect2i(0,240,320,240),Color.BLUE)
	picture.fill_rect(Rect2i(320,240,320,240),Color.WHITE)
	synthetic.set_rgb_image(picture)
	await settle()
	game.update_preview()
	assert(game.get_node("Preview").visible and game.get_node("Status").text.is_empty())
	assert(game.camera_material.get_shader_parameter("feed_type") == CameraFeed.FEED_RGB)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var screenshot: Image = root.get_texture().get_image()
		assert(screenshot.get_pixel(310,150).is_equal_approx(Color.RED))
		assert(screenshot.get_pixel(910,150).is_equal_approx(Color.GREEN))
		assert(screenshot.get_pixel(310,600).is_equal_approx(Color.BLUE))
		var args: PackedStringArray = OS.get_cmdline_user_args()
		if not args.is_empty():
			assert(screenshot.save_png(args[0]+"-rgb.png") == OK)
	# Feed-provided orientation is applied by the shader, not baked into frames.
	synthetic.feed_transform = Transform2D(Vector2(1,0),Vector2(0,-1),Vector2(0,1))
	game.update_preview()
	assert(game.camera_material.get_shader_parameter("uv_y") == Vector2(0,-1))
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().get_pixel(310,150).is_equal_approx(Color.BLUE))
	synthetic.feed_transform = Transform2D.IDENTITY
	# Neutral full-range YCbCr must produce gray through both native layouts.
	var ycbcr: Image = Image.create(640,480,false,Image.FORMAT_RGB8)
	ycbcr.fill(Color(0.5,0.5,0.5))
	synthetic.set_ycbcr_image(ycbcr)
	await settle()
	game.update_preview()
	assert(game.camera_material.get_shader_parameter("feed_type") == CameraFeed.FEED_YCBCR)
	await check_gray()
	var luminance: Image = Image.create(640,480,false,Image.FORMAT_R8)
	luminance.fill(Color(0.5,0,0))
	var chrominance: Image = Image.create(320,240,false,Image.FORMAT_RG8)
	chrominance.fill(Color(0.5,0.5,0))
	synthetic.set_ycbcr_images(luminance,chrominance)
	await settle()
	game.update_preview()
	assert(game.camera_material.get_shader_parameter("feed_type") == CameraFeed.FEED_YCBCR_SEP)
	await check_gray()
	root.size = Vector2i(640,480)
	await settle()
	assert(game.field_scale == 1 and game.field_offset == Vector2.ZERO)
	game.camera_removed(synthetic.get_id())
	assert(game.feed == null and synthetic.stopped and not synthetic.feed_is_active)
	assert(game.get_node("Status").text.contains("disconnected"))
	# Returning during active capture must stop it and free the texture/material.
	assert(game.start_capture(synthetic))
	synthetic.stopped = false
	var previous: WeakRef = weakref(game)
	var event: InputEventKey = InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.physical_keycode = KEY_ESCAPE
	event.pressed = true
	root.push_input(event)
	await settle()
	assert(app.active_level == null and previous.get_ref() == null)
	assert(synthetic.stopped and not synthetic.feed_is_active)
	assert(CameraServer.monitoring_feeds == monitoring)
	CameraServer.remove_feed(synthetic)
	synthetic = null
	app.free()
	await settle()
	print("You camera validation passed (synthetic feeds; hardware untested)")
	quit()


func check_gray() -> void:
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var color: Color = root.get_texture().get_image().get_pixel(310,150)
		assert(absf(color.r-0.5) < 0.02 and absf(color.g-0.5) < 0.02 and absf(color.b-0.5) < 0.02)
