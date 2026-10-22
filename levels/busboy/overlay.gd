extends Control

const BACKGROUND: Texture2D = preload("res://levels/busboy/assets/backgrounds/environment_forestbackground.png")
const ROOT_IMAGE: Texture2D = preload("res://levels/busboy/assets/root.png")
const PLAYER_SHEET: Texture2D = preload("res://levels/busboy/assets/sprites/player_snoblin.png")
var actions: Array[Button] = []
var leave: Button

func _ready() -> void:
	var level: BusboyLevel = get_parent() as BusboyLevel
	for action: String in ["strike", "guard", "cleanse"]:
		var button: Button = Button.new()
		button.text = {"strike":"1 · Strike", "guard":"2 · Guard", "cleanse":"3 · Cleanse (2 mana)"}[action]
		button.pressed.connect(level.choose.bind(action))
		add_child(button)
		actions.append(button)
	leave = Button.new()
	leave.pressed.connect(level.leave_encounter)
	add_child(leave)
	resized.connect(layout_buttons)
	layout_buttons()
	sync_buttons()

func layout_buttons() -> void:
	var width: float = (size.x - 80) / 3
	for i: int in range(actions.size()):
		actions[i].position = Vector2(24 + i * (width + 16), size.y * 0.75)
		actions[i].size = Vector2(width, 52)
		actions[i].add_theme_font_size_override("font_size", 18 if size.x >= 900 else 13)
	leave.position = Vector2(size.x - (370 if MatrixMobileOverlay.active(self) else 230), 18)
	leave.size = Vector2(210, 40)

func sync_buttons() -> void:
	var level: BusboyLevel = get_parent() as BusboyLevel
	for button: Button in actions:
		button.visible = level.encounter != null
		button.disabled = level.encounter == null or level.encounter.phase != BusboyEncounter.Phase.PLAYER
	leave.visible = level.encounter != null
	leave.text = "Continue" if level.encounter != null and level.encounter.phase in [BusboyEncounter.Phase.VICTORY, BusboyEncounter.Phase.DEFEAT] else "Retreat to forest"

func _process(_delta: float) -> void:
	sync_buttons()

func _draw() -> void:
	var level: BusboyLevel = get_parent() as BusboyLevel
	var font: Font = ThemeDB.fallback_font
	if level.opening:
		draw_texture_rect(BACKGROUND, Rect2(Vector2.ZERO, size), false)
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.03, 0.07, 0.05, 0.5))
		draw_string(font, Vector2(32, size.y * 0.4), "BUSBOY", HORIZONTAL_ALIGNMENT_LEFT, size.x - 64, 48, Color("d2e4bd"))
		draw_multiline_string(font, Vector2(32, size.y * 0.5), "A small path into a cursed forest.\nProvisional Alpha 0.2 introduction.\nSpace/Enter: begin · Escape: Matrix", HORIZONTAL_ALIGNMENT_LEFT, size.x - 64, 24, 4, Color.WHITE)
		return
	if level.encounter != null:
		draw_battle(level, font)
		return
	if MatrixMobileOverlay.active(self):
		MatrixMobileOverlay.draw(self, "BUSBOY · Draft", level.objective(), level.interaction_hint(), level.dialogue)
		return
	draw_rect(Rect2(0,0,size.x,128), Color(0.04,0.08,0.06,0.92))
	draw_string(font, Vector2(18,26), "BUSBOY · " + ("Starting room" if level.room_name == "cabin" else "Cursed forest") + " · Provisional", HORIZONTAL_ALIGNMENT_LEFT, size.x - 36, 22, Color("d2e4bd"))
	draw_multiline_string(font, Vector2(18,52), level.objective(), HORIZONTAL_ALIGNMENT_LEFT, size.x - 36, 18, 2, Color.WHITE)
	if level.notice_time > 0:
		draw_string(font, Vector2(18,110), level.notice, HORIZONTAL_ALIGNMENT_LEFT, size.x - 36, 16, Color("d9b799"))
	draw_rect(Rect2(0,size.y-42,size.x,42),Color(0.04,0.08,0.06,0.92))
	draw_string(font, Vector2(18,size.y-15), "WASD/arrows: move · E: interact · Escape: Matrix", HORIZONTAL_ALIGNMENT_LEFT, size.x-36, 16, Color("bac9ae"))
	if not level.interaction_hint().is_empty():
		draw_string(font, Vector2(18,size.y-55), level.interaction_hint(), HORIZONTAL_ALIGNMENT_LEFT, size.x-36, 20, Color("e5cd98"))
	if not level.dialogue.is_empty():
		var box: Rect2 = Rect2(24,size.y/2-115,size.x-48,230)
		draw_rect(box,Color("18261f"))
		draw_rect(box,Color("90ac7c"),false,2)
		draw_multiline_string(font,box.position+Vector2(20,34),level.dialogue,HORIZONTAL_ALIGNMENT_LEFT,box.size.x-40,20,7,Color.WHITE)
		draw_string(font,box.position+Vector2(20,210),"E/Enter: continue · Escape: close",HORIZONTAL_ALIGNMENT_LEFT,box.size.x-40,16,Color("bac9ae"))

func draw_battle(level: BusboyLevel, font: Font) -> void:
	var battle: BusboyEncounter = level.encounter
	draw_rect(Rect2(Vector2.ZERO,size),Color("18261f"))
	draw_string(font,Vector2(24,48),"Corrupted root · Provisional encounter",HORIZONTAL_ALIGNMENT_LEFT,size.x-290,26,Color("d2e4bd"))
	draw_texture_rect_region(PLAYER_SHEET,Rect2(size.x*0.25-64,size.y*0.36-64,128,128),Rect2(32,96,32,32))
	draw_texture_rect(ROOT_IMAGE,Rect2(size.x*0.72-64,size.y*0.36-64,128,128),false)
	draw_string(font,Vector2(size.x*0.12,size.y*0.55),"You: %d/18 · Mana: %d/4" % [battle.health,battle.mana],HORIZONTAL_ALIGNMENT_LEFT,size.x*0.4,22,Color.WHITE)
	draw_string(font,Vector2(size.x*0.6,size.y*0.55),"Roots: %d/18 · Stain: %d" % [battle.enemy_health,battle.corruption],HORIZONTAL_ALIGNMENT_LEFT,size.x*0.38,22,Color.WHITE)
	draw_multiline_string(font,Vector2(24,size.y*0.63),battle.message,HORIZONTAL_ALIGNMENT_LEFT,size.x-48,22,2,Color("e2c8a5"))
	var hint: String = "Next: " + battle.intent() if battle.phase in [BusboyEncounter.Phase.PLAYER,BusboyEncounter.Phase.RESOLVING] else "Enter/Space or Continue to leave the encounter."
	draw_string(font,Vector2(24,size.y*0.9),hint,HORIZONTAL_ALIGNMENT_LEFT,size.x-48,20,Color("bac9ae"))
