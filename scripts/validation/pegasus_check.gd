extends SceneTree
## Behavioral integration checks through real input, routing, map and movement.

var failures: int = 0
var app: MatrixApp
var pegasus: Pegasus
var capture_dir: String = ""


func _initialize() -> void:
	root.set_meta("matrix_test_mode",true)
	run.call_deferred()


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func key(code: Key, unicode: int = 0) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.unicode = unicode
	event.pressed = true
	root.push_input(event)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)


func text(value: String) -> void:
	for character: String in value:
		key(KEY_NONE, character.unicode_at(0))


func settle() -> void:
	await process_frame
	await process_frame


func capture(label: String) -> void:
	if capture_dir.is_empty():
		return
	await RenderingServer.frame_post_draw
	var result: Error = root.get_texture().get_image().save_png(capture_dir.path_join(label + ".png"))
	check(result == OK, "Screenshot failed: " + label)


func run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() >= 2 and args[0] == "--capture":
		capture_dir = args[1]
	root.size = Vector2i(1280, 720)
	app = load("res://app/main.tscn").instantiate() as MatrixApp
	root.add_child(app)
	await settle()
	pegasus = app.pegasus as Pegasus
	check(pegasus.overlay.opening, "Opening must appear on first launch")
	var spawn: Vector2 = pegasus.player.position
	Input.action_press("pegasus_right")
	await physics_frame
	await physics_frame
	Input.action_release("pegasus_right")
	check(pegasus.player.position == spawn, "Opening blocks player movement")
	await capture("opening")
	key(KEY_ENTER)
	check(not pegasus.overlay.opening, "Any key dismisses opening")
	check(not pegasus.overlay.terminal_active, "Start key must not open terminal")
	check(pegasus.player.position == Vector2(112, 224), "Cabin spawn")
	check(pegasus.world.bounds == Vector2(512, 320), "Cabin bounds")
	check(pegasus.world.collision_rects.size() == 10, "Cabin collision count")
	check(pegasus.world.terminal_rect == Rect2(416, 176, 64, 32), "Computer approach trigger")
	check(pegasus.world_viewport.size == Vector2i(512, 320), "2x rendering fits cabin at 1280x720")
	check(pegasus.world.get_node("Above").z_index > pegasus.player.z_index, "Above tiles overlay player")
	await capture("pegasus")
	key(KEY_E)
	check(not pegasus.overlay.terminal_active, "Terminal cannot open from spawn")
	check_input_bindings()
	pegasus.player.position = Vector2(300, 224)
	Input.action_press("pegasus_right")
	await physics_frame
	await physics_frame
	Input.action_release("pegasus_right")
	check(pegasus.player.position.x > 300 and pegasus.player.position.y == 224,
		"Physics loop responds to movement actions")
	check_movement()
	check(is_equal_approx(pegasus.player.speed, 182.0), "Pegasus walking speed reduced by 30 percent")
	pegasus.player.position = pegasus.world.player_spawn
	pegasus.player.step(Vector2.UP, 1.0, pegasus.world.collision_rects, pegasus.world.bounds)
	check(pegasus.player.position.y == 192.0, "Long frame stops at pod-front corridor")
	pegasus.player.step(Vector2.RIGHT, 336.0 / 182.0, pegasus.world.collision_rects, pegasus.world.bounds)
	check(pegasus.is_near_terminal(), "Walk from open chamber to computer across clear floor")
	# Approach the computer from its walkable front, without penetrating the desk.
	pegasus.player.position = Vector2(448, 208)
	pegasus.player.step(Vector2.UP, 0.065, pegasus.world.collision_rects, pegasus.world.bounds)
	check(pegasus.is_near_terminal(), "Terminal trigger is reachable without crossing collision")
	key(KEY_E)
	check(pegasus.overlay.terminal_active, "E opens reachable terminal")
	await capture("terminal")
	var stationary: Vector2 = pegasus.player.position
	Input.action_press("pegasus_up")
	await physics_frame
	await physics_frame
	Input.action_release("pegasus_up")
	check(pegasus.player.position == stationary, "Terminal blocks player movement")
	text("wrong")
	key(KEY_ENTER)
	check(pegasus.overlay.input_text == "" and pegasus.overlay.message == "Unknown code: WRONG",
		"Unknown code feedback and input reset")
	key(KEY_ENTER)
	check(pegasus.overlay.message == "Unknown code: <empty>", "Empty input feedback")
	text("abcdefghijklmnopqrstuv")
	check(pegasus.overlay.input_text.length() == 18, "18-character input limit")
	key(KEY_BACKSPACE)
	check(pegasus.overlay.input_text.length() == 17, "Backspace edits code")
	key(KEY_ESCAPE)
	check(not pegasus.overlay.terminal_active, "Escape closes terminal")
	check(LevelRegistry.lookup(" balls ").name == "Balls", "Lookup trims and ignores case")
	check(LevelRegistry.ENTRIES.size() == 7, "All seven Alpha 0.2 modules registered")
	for retired: String in ["PONG", "JUMP", "MARIO", "MONSTERS", "ZELDA", "UNTITLED"]:
		check(LevelRegistry.lookup(retired).is_empty(), "Archived code unavailable: " + retired)
	for code: String in LevelRegistry.ENTRIES:
		check(not LevelRegistry.lookup(code).scene.is_empty(), "Native scene required: " + code)
	for code: String in LevelRegistry.ENTRIES:
		key(KEY_E)
		text(" " + code.to_lower() + " ")
		key(KEY_ENTER)
		await settle()
		check(app.active_level != null and app.active_code == code, "Route for " + code)
		check(not pegasus.visible and not pegasus.can_process(), "Pegasus suspended for " + code)
		if LevelRegistry.lookup(code).scene.is_empty():
			check(app.active_level.get_node("Message").text.contains("not been migrated"),
				"Pending level status is explicit")
		else:
			check(app.active_level.scene_file_path == LevelRegistry.lookup(code).scene,
				"Registered scene loaded for " + code)
		var previous: WeakRef = weakref(app.active_level)
		key(KEY_ESCAPE)
		await settle()
		check(app.active_level == null and previous.get_ref() == null, "Level freed on return")
		check(pegasus.visible and pegasus.can_process(), "Pegasus resumes for " + code)
		check(pegasus.player.position == stationary, "Return preserves player position")
		check(not pegasus.overlay.opening and not pegasus.overlay.terminal_active, "Return skips opening/terminal")
	app.launch_level("invalid")
	await settle()
	check(app.active_level == null, "Invalid route leaves pegasus active")
	# A real level scene follows the same contract as the temporary status scene.
	app._enter_level("TEST", {"scene": "res://scripts/validation/fixture_level.tscn"})
	await settle()
	check(app.active_level != null, "Router loads an independent level scene")
	var fixture: WeakRef = weakref(app.active_level)
	key(KEY_ESCAPE)
	await settle()
	check(app.active_level == null and fixture.get_ref() == null, "Independent level return/cleanup")
	root.size = Vector2i(1920, 1080)
	await settle()
	check(pegasus.world_viewport.size == Vector2i(512, 320), "Large window clamps viewport to map")
	check(pegasus.display.position == Vector2(448, 220), "Large world display is centered")
	root.size = Vector2i(640, 480)
	await settle()
	check(pegasus.world_viewport.size == Vector2i(512, 320) and pegasus.pixel_scale == 1, "Small window fits whole cabin at 1x")
	root.size = Vector2i(320, 240)
	await settle()
	check(pegasus.world_viewport.size == Vector2i(320, 240), "Tiny window updates viewport")
	pegasus.player.position = pegasus.world.bounds - Vector2(8, 8)
	pegasus.update_camera()
	check(pegasus.camera_offset == Vector2(192, 80), "Camera clamps at map edge")
	pegasus.player.position = Vector2(8, 8)
	pegasus.update_camera()
	check(pegasus.camera_offset == Vector2.ZERO, "Camera clamps at map origin")
	root.size = Vector2i(1280, 720)
	await settle()
	if args.size() == 1:
		check_map(args[0])
	app.free()
	await settle()
	# AudioServer releases stopped decoder instances on its mixer thread.
	await create_timer(0.15).timeout
	if failures == 0:
		print("Pegasus integration passed")
	quit(0 if failures == 0 else 1)


func check_movement() -> void:
	var player: PegasusPlayer = pegasus.player
	var obstacles: Array[Rect2] = [Rect2(120, 50, 1, 100)]
	player.position = Vector2(100, 100)
	player.step(Vector2.RIGHT, 0.5, obstacles, Vector2(800, 800))
	check(is_equal_approx(player.position.x, 112), "Thin obstacle blocks long frame")
	check(not player.hitbox().intersects(obstacles[0]), "No obstacle penetration")
	player.position = Vector2(100, 100)
	player.step(Vector2(1, 1), 0.1, [], Vector2(800, 800))
	check(is_equal_approx(player.position.distance_to(Vector2(100, 100)), 18.2), "Normalized speed")
	player.position = Vector2(10, 10)
	player.step(Vector2(-1, -1), 0.1, [], Vector2(800, 800))
	check(player.position == Vector2(8, 8), "Player stays inside bounds")
	for direction: Vector2 in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		player.position = pegasus.world.player_spawn
		player.step(direction, 3.0, pegasus.world.collision_rects, pegasus.world.bounds)
		check(Rect2(32, 64, 448, 224).encloses(player.hitbox()), "Cabin walls stop long movement")
		for obstacle: Rect2 in pegasus.world.collision_rects:
			check(not player.hitbox().intersects(obstacle), "Cabin furniture/wall collision has no penetration")
	# Approach both pod fronts and the computer with a long frame: stop at their feet.
	for point: Vector2 in [Vector2(104,240), Vector2(200,240), Vector2(372,240), Vector2(448,240)]:
		player.position = point
		player.step(Vector2.UP, 1.0, pegasus.world.collision_rects, pegasus.world.bounds)
		check(is_equal_approx(player.position.y, 192.0 if point.x < 400 else 184.0), "Pod/computer front blocks movement")
		for obstacle: Rect2 in pegasus.world.collision_rects:
			check(not player.hitbox().intersects(obstacle), "Pod/computer collision remains nonpenetrating")
	player.position = pegasus.world.player_spawn


func check_map(path: String) -> void:
	var expected: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	for i: int in range(expected.collision.size()):
		var rect: Array = expected.collision[i]
		check(pegasus.world.collision_rects[i] == Rect2(rect[0], rect[1], rect[2], rect[3]),
			"Converted collision rectangle " + str(i))
	for object: Dictionary in expected.objects:
		var sprite: Sprite2D = pegasus.world.get_node(object.node) as Sprite2D
		check(sprite.position == Vector2(object.position[0], object.position[1]), "Native prop placement: " + object.node)
		check(sprite.texture.resource_path == object.texture, "Independent editable prop art: " + object.node)
		check(sprite.offset == Vector2(object.offset[0], object.offset[1]), "Prop art retains its placement around the depth anchor")
	for feature: Dictionary in expected.features:
		var layer: TileMapLayer = pegasus.world.get_node(feature.layer)
		var cell: Vector2i = Vector2i(feature.cell[0], feature.cell[1])
		check(layer.get_cell_source_id(cell) == 0, "Cabin landmark tile exists")
		check(layer.get_cell_atlas_coords(cell) == Vector2i(feature.atlas[0], feature.atlas[1]),
			"Cabin landmark atlas coordinates")



func check_input_bindings() -> void:
	var expected: Dictionary = {
		"pegasus_left": [KEY_A, KEY_LEFT], "pegasus_right": [KEY_D, KEY_RIGHT],
		"pegasus_up": [KEY_W, KEY_UP], "pegasus_down": [KEY_S, KEY_DOWN],
		"pegasus_interact": [KEY_E], "return_to_pegasus": [KEY_ESCAPE],
	}
	for action: String in expected:
		var events: Array[InputEvent] = InputMap.action_get_events(action)
		check(events.size() == expected[action].size(), "Input binding count: " + action)
		for i: int in range(events.size()):
			check(events[i].physical_keycode == expected[action][i], "Input binding: " + action)
