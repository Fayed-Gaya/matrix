extends Control

const FONT: Font = preload("res://levels/zelda/assets/graphics/font/joystix.ttf")
var camera: Vector2 = Vector2.ZERO


func _draw() -> void:
	var level: ZeldaLevel = get_parent().get_parent() as ZeldaLevel
	camera = level.player.get_center()-Vector2(640,360)
	draw_rect(Rect2(0,0,1280,720),Color("71ddee"))
	draw_set_transform(-camera)
	level.native_map.paint_layer(self,"Ground",Rect2(camera,Vector2(1280,720)))
	var entries: Array[Dictionary] = []
	for item: Dictionary in level.objects:
		if not item.dead and item.type != "boundary" and item.rect.intersects(Rect2(camera-Vector2(256,256),Vector2(1792,1232))):
			entries.append({"rect":item.rect,"texture":item.texture,"hidden":false,"flip":false})
	entries.append({"rect":level.player_rect(),"texture":level.player_texture(),"hidden":level.hurt_left > 0 and sin(Time.get_ticks_msec()) < 0,"flip":false})
	for enemy: Dictionary in level.enemies:
		var images: Array = level.frames("monsters/"+enemy.name+"/"+enemy.state)
		var texture: Texture2D = images[int(enemy.frame)%images.size()]
		entries.append({"rect":Rect2(enemy.box.get_center()-texture.get_size()/2,texture.get_size()),"texture":texture,"hidden":enemy.hurt > 0 and sin(Time.get_ticks_msec()) < 0,"flip":false})
	if level.weapon_rect.has_area():
		entries.append({"rect":level.weapon_rect,"texture":level.weapon_texture,"hidden":false,"flip":false})
	for effect: Dictionary in level.particles:
		var texture: Texture2D = level.frames(effect.folder)[int(effect.frame)]
		entries.append({"rect":Rect2(effect.position-texture.get_size()/2,texture.get_size()),"texture":texture,"hidden":false,"flip":effect.flip})
	entries.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return a.rect.get_center().y < b.rect.get_center().y)
	for entry: Dictionary in entries:
		if entry.hidden:
			continue
		if entry.flip:
			draw_set_transform(entry.rect.position-camera+Vector2(entry.rect.size.x,0),0,Vector2(-1,1))
			draw_texture(entry.texture,Vector2.ZERO)
			draw_set_transform(-camera)
		else:
			draw_texture(entry.texture,entry.rect.position)
	draw_set_transform(Vector2.ZERO)
	bar(Rect2(10,10,200,20),level.health/level.stats.health,Color.RED)
	bar(Rect2(10,34,140,20),level.energy/level.stats.energy,Color.BLUE)
	var weapon: Texture2D = level.image("weapons/"+level.WEAPONS[level.weapon_index]+"/full.png")
	var spell: Dictionary = level.data.magic_data[level.SPELLS[level.magic_index]]
	var magic: Texture2D = load_cached(level,spell.graphic)
	box(Rect2(10,630,80,80),Color.GOLD if level.weapon_switch > 0 else Color("111111"))
	draw_texture(weapon,Vector2(50,670)-weapon.get_size()/2)
	box(Rect2(80,635,80,80),Color.GOLD if level.magic_switch > 0 else Color("111111"))
	draw_texture(magic,Vector2(120,675)-magic.get_size()/2)
	var text: String = str(int(level.experience))
	var width: float = FONT.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,18).x
	box(Rect2(1250-width,662,width+20,48),Color("111111"))
	draw_string(FONT,Vector2(1260-width,697),text,HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("eeeeee"))
	if level.paused:
		for i: int in range(5):
			var selected: bool = i == level.menu_index
			var rect: Rect2 = Rect2(i*256+21,72,213,576)
			draw_rect(rect,Color("eeeeee") if selected else Color("222222"))
			draw_rect(rect,Color("111111"),false,4)
			var attribute: String = level.ATTRIBUTES[i]
			var color: Color = Color("111111") if selected else Color("eeeeee")
			center(attribute,Vector2(rect.get_center().x,112),color)
			center(str(int(level.costs[attribute])),Vector2(rect.get_center().x,620),color)
			draw_line(Vector2(rect.get_center().x,132),Vector2(rect.get_center().x,588),color,5)
			draw_rect(Rect2(rect.get_center().x-15,588-456*level.stats[attribute]/level.maximum[attribute],30,10),color)


func load_cached(level: ZeldaLevel,path: String) -> Texture2D:
	var key: String = "image:"+path
	if not level.cache.has(key):
		level.cache[key] = load(path)
	return level.cache[key]


func box(rect: Rect2,border: Color) -> void:
	draw_rect(rect,Color("222222"))
	draw_rect(rect,border,false,3)


func bar(rect: Rect2,ratio: float,color: Color) -> void:
	box(rect,Color("111111"))
	draw_rect(Rect2(rect.position,Vector2(maxf(0,rect.size.x*ratio),rect.size.y)),color)
	draw_rect(rect,Color("111111"),false,3)


func center(text: String,position: Vector2,color: Color) -> void:
	var width: float = FONT.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,18).x
	draw_string(FONT,position-Vector2(width/2,0),text,HORIZONTAL_ALIGNMENT_LEFT,-1,18,color)
