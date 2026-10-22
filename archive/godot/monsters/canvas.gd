extends Control

const FONT: Font = preload("res://levels/monsters/assets/graphics/fonts/PixeloidSans.ttf")
var camera: Vector2 = Vector2.ZERO
var game: MonstersLevel


func _draw() -> void:
	game = get_parent().get_parent() as MonstersLevel
	draw_set_transform(Vector2.ZERO)
	if game.world.is_empty():
		return
	if game.battle != null:
		camera = Vector2.ZERO
		draw_battle(game.battle)
	else:
		draw_world()
		if game.index_open:
			draw_index()
		if not game.evolution_queue.is_empty():
			draw_evolution()
	if game.tint > 0:
		draw_rect(Rect2(0,0,1280,720),Color(0,0,0,game.tint))


func art(texture: Texture2D,position: Vector2,flip: bool = false,factor: float = 1.0,color: Color = Color.WHITE) -> void:
	draw_set_transform(position-camera+Vector2(texture.get_width()*factor if flip else 0,0),0,Vector2(-factor if flip else factor,factor))
	draw_texture(texture,Vector2.ZERO,color)
	draw_set_transform(-camera)


func draw_world() -> void:
	camera = game.player_position-Vector2(640,360)
	draw_rect(Rect2(0,0,1280,720),Color.BLACK)
	draw_set_transform(-camera)
	var world: Dictionary = game.world
	for layer: Dictionary in world.layers:
		game.native_maps[game.map_name].paint_layer(self,layer.name,Rect2(camera,Vector2(1280,720)))
	var water: Array = game.frames("tilesets/water")
	var water_texture: Texture2D = water[int(game.age*6)%water.size()]
	for obj: Dictionary in world.groups.get("Water",[]):
		for y: int in range(int(obj.position[1]),int(obj.position[1]+obj.size[1]),64):
			for x: int in range(int(obj.position[0]),int(obj.position[0]+obj.size[0]),64):
				if Rect2(x,y,64,64).intersects(Rect2(camera,Vector2(1280,720))):
					draw_texture(water_texture,Vector2(x,y))
	for obj: Dictionary in world.groups.get("Coast",[]):
		var position: Vector2 = Vector2(obj.position[0],obj.position[1])
		if Rect2(position,Vector2(64,64)).intersects(Rect2(camera,Vector2(1280,720))):
			draw_texture(game.sprite("coast/"+obj.properties.terrain,obj.properties.side,game.age),position)
	var main: Array[Dictionary] = []
	var above: Array[Dictionary] = []
	for obj: Dictionary in world.groups.get("Objects",[]):
		if obj.image < 0:
			continue
		var texture: Texture2D = game.tile(int(obj.image))
		var position: Vector2 = Vector2(obj.position[0],obj.position[1])
		var entry: Dictionary = {"texture":texture,"position":position,"sort_y":position.y+texture.get_height()/2.0,"entity":false}
		if obj.name == "top":
			above.append(entry)
		else:
			main.append(entry)
	for obj: Dictionary in world.groups.get("Monsters",[]):
		if obj.image < 0:
			continue
		var texture: Texture2D = game.tile(int(obj.image))
		var position: Vector2 = Vector2(obj.position[0],obj.position[1])
		if obj.properties.biome == "sand":
			draw_texture(texture,position)
		else:
			main.append({"texture":texture,"position":position,"sort_y":position.y+texture.get_height()/2.0-40,"entity":false})
	for npc: Dictionary in game.npcs:
		var texture: Texture2D = game.sprite("characters/"+npc.graphic,npc.facing+("_idle" if npc.direction.is_zero_approx() else ""),game.age)
		main.append({"texture":texture,"position":npc.position-texture.get_size()/2,"sort_y":npc.position.y,"entity":true})
	var player: Texture2D = game.sprite("characters/player",game.facing+("_idle" if game.player_direction.is_zero_approx() else ""),game.age)
	main.append({"texture":player,"position":game.player_position-player.get_size()/2,"sort_y":game.player_position.y,"entity":true})
	main.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return a.sort_y < b.sort_y)
	for entries: Array[Dictionary] in [main,above]:
		for entry: Dictionary in entries:
			if not Rect2(entry.position,entry.texture.get_size()).intersects(Rect2(camera-Vector2(128,128),Vector2(1536,976))):
				continue
			if entry.entity:
				draw_texture(game.image("other/shadow.png"),entry.position+Vector2(40,110))
			draw_texture(entry.texture,entry.position)
	if game.noticed:
		var notice: Texture2D = game.image("ui/notice.png")
		draw_texture(notice,game.player_position-Vector2(notice.get_width()/2,player.get_height()/2+notice.get_height()))
	if game.dialogue_active:
		var npc: Dictionary = game.npcs[game.dialogue_npc]
		var extent: Vector2 = game.sprite("characters/"+npc.graphic,"down_idle",0).get_size()
		var text: String = game.dialogue_lines[game.dialogue_index]
		var dimensions: Vector2 = FONT.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,30)+Vector2(10,10)
		var position: Vector2 = npc.position-Vector2(dimensions.x/2,extent.y/2+10+dimensions.y)
		draw_rect(Rect2(position,dimensions),Color.WHITE)
		draw_string(FONT,position+Vector2(5,dimensions.y-8),text,HORIZONTAL_ALIGNMENT_LEFT,-1,30,Color.BLACK)
	draw_set_transform(Vector2.ZERO)
	camera = Vector2.ZERO


func draw_battle(battle: MonsterBattle) -> void:
	draw_texture_rect(game.image("backgrounds/"+battle.biome+".png"),Rect2(0,0,1280,720),false)
	var targets: Array = battle.team(battle.target_side)
	for actor: Dictionary in battle.actors:
		var monster: MonsterState = actor.monster
		var center: Vector2 = battle.POSITIONS[actor.side*3+actor.slot]
		var texture: Texture2D = game.sprite("monsters/"+monster.name,actor.state,float(actor.frame)/6)
		var highlight: bool = actor == battle.current and not (battle.mode == "target" and battle.target_side == 0)
		if battle.mode == "target" and not targets.is_empty() and actor == targets[battle.index%targets.size()]:
			highlight = true
		if highlight:
			var outline: Texture2D = game.sprite("outlines/"+monster.name,actor.state,float(actor.frame)/6)
			art(outline,center-outline.get_size()/2,actor.side == 0)
		art(texture,center-texture.get_size()/2,actor.side == 0)
		var name_size: Vector2 = FONT.get_string_size(monster.name,HORIZONTAL_ALIGNMENT_LEFT,-1,18)+Vector2(20,24)
		var name_anchor: Vector2 = center+Vector2(-texture.get_width()/2.0+16 if actor.side == 0 else texture.get_width()/2.0-40,-70)
		var name_position: Vector2 = name_anchor-Vector2(name_size.x/2,0)
		draw_rect(Rect2(name_position,name_size),Color("f4fefa"))
		label(monster.name,name_position+Vector2(10,29),18,Color.BLACK)
		var level_position: Vector2 = name_position+Vector2(0 if actor.side == 0 else name_size.x-60,name_size.y)
		draw_rect(Rect2(level_position,Vector2(60,26)),Color("f4fefa"))
		label("Lvl "+str(monster.level),level_position+Vector2(5,19),14,Color.BLACK)
		bar(Rect2(level_position+Vector2(0,24),Vector2(60,2)),monster.xp/monster.level_up,Color.BLACK)
		var bar_position: Vector2 = center+Vector2(-75,texture.get_height()/2.0-28)
		draw_rect(Rect2(bar_position,Vector2(150,48)),Color("f4fefa"))
		label("%d/%d" % [monster.health,monster.stat("max_health")],bar_position+Vector2(7,15),14,Color.BLACK)
		bar(Rect2(bar_position+Vector2(7,17),Vector2(136,4)),monster.health/monster.stat("max_health"),Color("f03131"))
		label("%d/%d" % [monster.energy,monster.stat("max_energy")],bar_position+Vector2(7,39),14,Color.BLACK)
		bar(Rect2(bar_position+Vector2(7,41),Vector2(136,4)),monster.energy/monster.stat("max_energy"),Color("66d7ee"))
		bar(Rect2(bar_position+Vector2(0,46),Vector2(150,2)),monster.initiative/100,Color("3a373b"))
		if monster.defending:
			label("DEFEND",bar_position+Vector2(0,65),14,Color.GOLD)
	for effect: Dictionary in battle.effects:
		var texture: Texture2D = game.sprite("attacks/"+effect.animation,"frames",4.0/6.0-effect.time)
		art(texture,effect.position-texture.get_size()/2)
	if battle.lost:
		panel(Rect2(280,310,720,90))
		label(battle.message,Vector2(300,360),20)
		return
	if battle.mode in ["general","attacks","switch"] and not battle.current.is_empty():
		var position: Vector2 = battle.POSITIONS[battle.current.side*3+battle.current.slot]+Vector2(110,-90)
		var options: Array = battle.choices()
		panel(Rect2(position,Vector2(290,200)))
		var start: int = maxi(0,battle.index-3)
		for i: int in range(start,mini(options.size(),start+4)):
			var y: float = position.y+36+(i-start)*46
			var text: String = str(options[i])
			var icon: Texture2D
			if battle.mode == "general":
				var key: String = ["sword","shield","arrows","hand"][i]
				icon = game.image("ui/"+key+("_highlight" if i == battle.index else "")+".png")
			elif battle.mode == "switch":
				var monster: MonsterState = game.party[int(options[i])]
				text = monster.name+" Lv."+str(monster.level)
				icon = game.image("icons/"+monster.name+".png")
			if i == battle.index:
				draw_rect(Rect2(position.x+4,y-28,282,42),Color("4b484d"))
			if icon != null:
				draw_texture_rect(icon,Rect2(position.x+8,y-28,36,36),false)
			label(text,Vector2(position.x+52,y),18,Color.GOLD if i == battle.index else Color.WHITE)
	if battle.mode == "target":
		label("Choose a target: Up/Down, Space. Escape goes back.",Vector2(360,50),18)
	if battle.message_left > 0:
		panel(Rect2(250,650,780,44))
		label(battle.message,Vector2(270,680),18)


func draw_index() -> void:
	draw_rect(Rect2(0,0,1280,720),Color(0,0,0,0.78))
	panel(Rect2(256,72,768,576))
	var start: int = maxi(0,game.party_index-5)
	for i: int in range(start,mini(game.party.size(),start+6)):
		var monster: MonsterState = game.party[i]
		var y: float = 72+(i-start)*96
		draw_rect(Rect2(256,y,230,96),Color("c8c8c8") if i == game.party_index else Color("3a373b"))
		draw_texture_rect(game.image("icons/"+monster.name+".png"),Rect2(264,y+8,60,60),false)
		label(monster.name,Vector2(332,y+35),18,Color.GOLD if i == game.swap_index else Color.WHITE)
		label("Lv."+str(monster.level),Vector2(332,y+60),14)
		bar(Rect2(332,y+70,140,5),monster.health/monster.stat("max_health"),Color.RED)
		bar(Rect2(332,y+80,140,5),monster.energy/monster.stat("max_energy"),Color.CYAN)
	var selected: MonsterState = game.party[game.party_index]
	var texture: Texture2D = game.sprite("monsters/"+selected.name,"idle",game.age)
	art(texture,Vector2(750,225)-texture.get_size()/2)
	label(selected.name+"  Lv."+str(selected.level),Vector2(540,115),24)
	label("Element: "+selected.element(),Vector2(540,335),18)
	var keys: Array[String] = ["max_health","max_energy","attack","defense","speed","recovery"]
	for i: int in range(keys.size()):
		var key: String = keys[i]
		var maximum: float = 1
		for definition: Dictionary in game.data.MONSTER_DATA.values():
			maximum = maxf(maximum,float(definition.stats[key]))
		label(key.trim_prefix("max_")+": "+str(snappedf(selected.stat(key),0.1)),Vector2(520,375+i*30),14)
		bar(Rect2(750,363+i*30,230,10),selected.stat(key)/(maximum*selected.level),Color("64a990"))
	label("XP %d / %d" % [selected.xp,selected.level_up],Vector2(520,570),14)
	label("Moves: "+", ".join(selected.abilities()),Vector2(520,600),14)
	label("Space: mark/swap party order. Enter/Escape: close.",Vector2(280,680),18)


func draw_evolution() -> void:
	var evolution: Dictionary = game.evolution_queue[0]
	if game.evolution_elapsed < 0.8:
		return
	draw_rect(Rect2(0,0,1280,720),Color(0,0,0,0.78))
	var progress: float = clampf((game.evolution_elapsed-0.8)/3.2,0,1)
	var old: Texture2D = game.sprite("monsters/"+evolution.from,"idle",0)
	var next: Texture2D = game.sprite("monsters/"+evolution.to,"idle",0)
	art(old,Vector2(640,360)-old.get_size(),false,2,Color(1,1,1,1-progress))
	art(next,Vector2(640,360)-next.get_size(),false,2,Color(1,1,1,progress))
	if progress >= 1:
		var stars: Array = game.frames("other/star animation")
		var index: int = int((game.evolution_elapsed-4)*20)
		if index < stars.size():
			var texture: Texture2D = stars[index]
			art(texture,Vector2(640,360)-texture.get_size(),false,2)
	panel(Rect2(260,580,760,60))
	label(evolution.from+(" is evolving" if progress < 1 else " evolved into "+evolution.to),Vector2(285,620),24)


func label(text: String,position: Vector2,font_size: int = 18,color: Color = Color.WHITE) -> void:
	draw_string(FONT,position,text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,color)


func panel(rect: Rect2) -> void:
	draw_rect(rect,Color("2b292c"))
	draw_rect(rect,Color("c8c8c8"),false,2)


func bar(rect: Rect2,ratio: float,color: Color) -> void:
	draw_rect(rect,Color.BLACK)
	draw_rect(Rect2(rect.position,Vector2(rect.size.x*clampf(ratio,0,1),rect.size.y)),color)
