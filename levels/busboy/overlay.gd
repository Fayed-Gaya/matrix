extends Control
## Readable woodland UI; three real buttons work with keyboard, mouse and touch.
const BACKGROUND: Texture2D = preload("res://assets/art/busboy/backgrounds/environment_forestbackground.png")
const ROOT_IMAGE: Texture2D = preload("res://assets/art/sprites/busboy/corrupted_roots/root.png")
const TREE_IMAGE: Texture2D = preload("res://assets/art/busboy/refinement/tree.png")
const NPC_SHEET: Texture2D = preload("res://assets/art/sprites/busboy/waykeeper/waykeeper.png")
const PLAYER_SHEET: Texture2D = preload("res://assets/art/sprites/busboy/player/traveller.png")
var actions: Array[Button] = []
var leave: Button

func _ready() -> void:
	var level: BusboyLevel = get_parent() as BusboyLevel
	for action: String in ["strike", "guard", "cleanse"]:
		var button: Button = Button.new()
		button.text = {"strike":"1  STRIKE\n4 damage · no stain", "guard":"2  GUARD\nHalf reply · +1 mana · -1 stain", "cleanse":"3  CLEANSE\n7 damage · -2 mana · +1 stain"}[action]
		button.pressed.connect(level.choose.bind(action))
		style_button(button)
		add_child(button)
		actions.append(button)
	leave = Button.new()
	leave.pressed.connect(level.leave_encounter)
	style_button(leave)
	add_child(leave)
	resized.connect(layout_buttons)
	layout_buttons()
	sync_buttons()

func style_button(button: Button) -> void:
	for state: String in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = Color("253b3c") if state != "disabled" else Color("202b30")
		style.border_color = Color("acb99b") if state in ["hover", "focus"] else Color("586f6b")
		style.set_border_width_all(2 if state == "focus" else 1)
		button.add_theme_stylebox_override(state, style)
	button.add_theme_color_override("font_color", Color("dfe3c9"))
	button.add_theme_color_override("font_disabled_color", Color("788887"))

func layout_buttons() -> void:
	var mobile: bool = MatrixMobileOverlay.active(self)
	var width: float = (size.x - 72) / 3
	for i: int in range(actions.size()):
		actions[i].position = Vector2(24 + i * (width + 12), size.y - (72 if mobile else 104))
		actions[i].size = Vector2(width, 56 if mobile else 68)
		actions[i].add_theme_font_size_override("font_size", 13 if mobile else 17)
	leave.position = Vector2(size.x - (296 if mobile else 170), 12)
	leave.size = Vector2(150, 40)
	leave.add_theme_font_size_override("font_size", 15)

func sync_buttons() -> void:
	var level: BusboyLevel = get_parent() as BusboyLevel
	for button: Button in actions:
		button.visible = level.encounter != null
		button.disabled = level.encounter == null or level.encounter.phase != BusboyEncounter.Phase.PLAYER
	leave.visible = level.encounter != null
	if level.encounter != null:
		leave.text = "Continue" if level.encounter.phase == BusboyEncounter.Phase.VICTORY else ("Try again" if level.encounter.phase == BusboyEncounter.Phase.DEFEAT else "Retreat")

func _process(_delta: float) -> void:
	sync_buttons()

func _draw() -> void:
	var level: BusboyLevel = get_parent() as BusboyLevel
	var font: Font = ThemeDB.fallback_font
	var mobile: bool = MatrixMobileOverlay.active(self)
	if level.opening:
		draw_texture_rect(BACKGROUND, Rect2(Vector2.ZERO, size), false)
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.03, 0.07, 0.09, 0.65))
		draw_string(font, Vector2(32, size.y * 0.36), "B U S B O Y", HORIZONTAL_ALIGNMENT_CENTER, size.x - 64, 38 if mobile else 56, Color("d4dfbd"))
		draw_multiline_string(font, Vector2(32, size.y * 0.49), "A lantern in the dark.\nA path that will not stay open.", HORIZONTAL_ALIGNMENT_CENTER, size.x - 64, 19 if mobile else 24, 3, Color("a6beb1"))
		if not mobile: draw_string(font, Vector2(32, size.y * 0.77), "Enter / Space: begin     Escape: Matrix", HORIZONTAL_ALIGNMENT_CENTER, size.x - 64, 17, Color("d3ba8b"))
		return
	if level.encounter != null:
		draw_battle(level, font, mobile)
		return
	draw_rect(Rect2(0,0,size.x,76), Color("12232aee"))
	draw_line(Vector2(0,75),Vector2(size.x,75),Color("526d66"))
	draw_string(font,Vector2(20,27),"BUSBOY / " + ("REFUGE" if level.room_name == "cabin" else "THE FIRST CLEARING"),HORIZONTAL_ALIGNMENT_LEFT,size.x-170,20,Color("d4dfbd"))
	draw_string(font,Vector2(20,52),level.objective(),HORIZONTAL_ALIGNMENT_LEFT,size.x-40,16,Color("a6beb1"))
	if level.notice_time > 0 and level.dialogue.is_empty():
		draw_rect(Rect2(12,82,size.x-24,28),Color("12232ad9"))
		draw_string(font,Vector2(22,102),level.notice,HORIZONTAL_ALIGNMENT_LEFT,size.x-44,14,Color("d3ba8b"))
	if not mobile:
		draw_rect(Rect2(0,size.y-32,size.x,32),Color("12232aee"))
		draw_string(font,Vector2(20,size.y-11),"WASD / arrows: move     E: interact     Escape: Matrix",HORIZONTAL_ALIGNMENT_LEFT,size.x-40,15,Color("a6beb1"))
	var hint: String = level.interaction_hint().replace("E:","Use:" if mobile else "E:")
	if not hint.is_empty() and level.dialogue.is_empty():
		draw_string(font,Vector2(190 if mobile else 20,size.y-(84 if mobile else 43)),hint,HORIZONTAL_ALIGNMENT_LEFT,size.x-(400 if mobile else 40),16,Color("e2c895"))
	if not level.dialogue.is_empty():
		var box: Rect2 = Rect2(24,84 if mobile else size.y-238,size.x-48,size.y-182 if mobile else 190)
		draw_rect(box,Color("162a30f5"))
		draw_rect(box.grow(-5),Color("819b82"),false,1)
		var has_portrait: bool = level.room_name == "forest" and not level.nearby_npc().is_empty() and not level.complete
		if has_portrait:
			draw_texture_rect_region(NPC_SHEET,Rect2(box.position+Vector2(12,24),Vector2(72,72)),Rect2(32,96,32,32))
			draw_string(font,box.position+Vector2(12,113),"WAYKEEPER",HORIZONTAL_ALIGNMENT_LEFT,82,11,Color("b7b293"))
		var inset: float = 104 if has_portrait else 18
		draw_multiline_string(font,box.position+Vector2(inset,28),level.dialogue,HORIZONTAL_ALIGNMENT_LEFT,box.size.x-inset-18,16 if mobile else 20,-1,Color("e0e4cc"))
		draw_string(font,box.position+Vector2(190 if mobile else 18,box.size.y-18),"Use / Enter: continue",HORIZONTAL_ALIGNMENT_LEFT,box.size.x-36,14,Color("b7b293"))

func bar(rect: Rect2, current: int, maximum: int, color: Color) -> void:
	draw_rect(rect,Color("263438"))
	draw_rect(Rect2(rect.position,Vector2(rect.size.x*float(current)/maximum,rect.size.y)),color)

func draw_battle(level: BusboyLevel, font: Font, mobile: bool) -> void:
	var battle: BusboyEncounter = level.encounter
	var ink: Color = Color("e0e4cc")
	draw_rect(Rect2(Vector2.ZERO,size),Color("101e29f4"))
	draw_texture_rect(TREE_IMAGE,Rect2(-32,80,192,256),false,Color(0.3,0.5,0.48,0.32))
	draw_texture_rect(TREE_IMAGE,Rect2(size.x-160,65,192,256),false,Color(0.3,0.5,0.48,0.32))
	draw_string(font,Vector2(24,32),"THE BOUND KNOT",HORIZONTAL_ALIGNMENT_LEFT,240,20,ink)
	var phase: String = "YOUR TURN" if battle.phase == BusboyEncounter.Phase.PLAYER else ("ROOTS RESPONDING" if battle.phase == BusboyEncounter.Phase.RESOLVING else ("PASSAGE CLEARED" if battle.phase == BusboyEncounter.Phase.VICTORY else "CATCH YOUR BREATH"))
	draw_string(font,Vector2(24,57),phase,HORIZONTAL_ALIGNMENT_LEFT,size.x-330,14,Color("b2c99f"))
	var card_width: float = (size.x-72)/2
	for x: float in [24.0, size.x/2+12]:
		draw_rect(Rect2(x,72,card_width,78),Color("20323ada"))
		draw_rect(Rect2(x,72,card_width,78),Color("48605d"),false,1)
	draw_string(font,Vector2(36,95),"TRAVELLER    %d / %d" % [battle.health,BusboyEncounter.MAX_HEALTH],HORIZONTAL_ALIGNMENT_LEFT,card_width-24,16,ink)
	bar(Rect2(36,103,card_width-24,5),battle.health,BusboyEncounter.MAX_HEALTH,Color("a7b992"))
	draw_string(font,Vector2(36,132),"Mana %d/4   Stain %d (+%d enemy damage)" % [battle.mana,battle.corruption,battle.corruption],HORIZONTAL_ALIGNMENT_LEFT,card_width-24,13,Color("b9c7c0"))
	var right: float = size.x/2+24
	draw_string(font,Vector2(right,95),"ROOT KNOT    %d / %d" % [battle.enemy_health,BusboyEncounter.MAX_ROOT],HORIZONTAL_ALIGNMENT_LEFT,card_width-24,16,ink)
	bar(Rect2(right,103,card_width-24,5),battle.enemy_health,BusboyEncounter.MAX_ROOT,Color("a48ba5"))
	draw_string(font,Vector2(right,132),"Next: " + battle.intent(),HORIZONTAL_ALIGNMENT_LEFT,card_width-24,13,Color("dec69b"))
	var stage_y: float = 196 if mobile else (150+size.y-240)/2
	var hero: Vector2 = Vector2(size.x*0.25,stage_y)
	var enemy: Vector2 = Vector2(size.x*0.73,stage_y)
	var hero_size: float = 90 if mobile else 160
	var enemy_size: Vector2 = Vector2(128,106) if mobile else Vector2(216,180)
	draw_set_transform(hero,0,Vector2(1,0.25));draw_circle(Vector2(0,hero_size*1.5),hero_size*0.38,Color("0c151e"));draw_set_transform(Vector2.ZERO)
	draw_texture_rect_region(PLAYER_SHEET,Rect2(hero-Vector2.ONE*hero_size/2,Vector2.ONE*hero_size),Rect2(32,96,32,32))
	draw_texture_rect(ROOT_IMAGE,Rect2(enemy-enemy_size/2,enemy_size),false)
	if battle.effect_time > 0:
		var color: Color = Color("c7dfbd") if battle.effect != "cleanse" else Color("bb9fca")
		var target: Vector2 = hero if battle.effect in ["guard","reply"] else enemy
		draw_arc(target,45 if mobile else 80,0,TAU,36,color,2)
		var damage: String = "-7" if battle.effect == "cleanse" else ("-4" if battle.effect == "strike" else ("GUARD" if battle.effect == "guard" else ""))
		draw_string(font,target+Vector2(-20,-48 if mobile else -90),damage,HORIZONTAL_ALIGNMENT_LEFT,120,18,color)
	var log_y: float = size.y-(140 if mobile else 222)
	draw_rect(Rect2(24,log_y,size.x-48,60 if mobile else 100),Color("20323ada"))
	draw_string(font,Vector2(36,log_y+20),battle.last_action,HORIZONTAL_ALIGNMENT_LEFT,size.x-72,13 if mobile else 18,ink)
	draw_string(font,Vector2(36,log_y+40),battle.last_reply if not battle.last_reply.is_empty() else battle.message,HORIZONTAL_ALIGNMENT_LEFT,size.x-72,13 if mobile else 18,Color("b6c6aa"))
	if not mobile: draw_string(font,Vector2(36,log_y+74),battle.message,HORIZONTAL_ALIGNMENT_LEFT,size.x-72,17,Color("d5bd93"))
	if battle.phase in [BusboyEncounter.Phase.VICTORY,BusboyEncounter.Phase.DEFEAT]:
		draw_string(font,Vector2(24,size.y-8),"Enter / Continue: " + ("return to the clearing" if battle.phase == BusboyEncounter.Phase.VICTORY else "try again") + "    Escape: retreat",HORIZONTAL_ALIGNMENT_LEFT,size.x-48,12,Color("a6beb1"))
