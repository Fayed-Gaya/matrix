extends Control

const TERRAIN: Texture2D = preload("res://levels/mario/assets/graphics/terrain/terrain_tiles.png")
const GRASS: Texture2D = preload("res://levels/mario/assets/graphics/decoration/grass/grass.png")
const FONT: Font = preload("res://levels/mario/assets/graphics/ui/ARCADEPI.TTF")
var camera: float = 0.0


func _draw() -> void:
	var level: MarioLevel = get_parent().get_parent() as MarioLevel
	camera = level.camera_x if level.mode == "stage" else 0.0
	for row: int in range(11):
		var part: String = "top" if row < 8 else ("middle" if row == 8 else "bottom")
		draw_texture_rect(level.image("decoration/sky/sky_" + part + ".png"),Rect2(0,row*64,1200,64),false)
	draw_set_transform(Vector2(-camera,0))
	for cloud: Dictionary in level.clouds:
		var position: Vector2 = cloud.position - cloud.image.get_size() * Vector2(0.5,1) if cloud.bottom else cloud.position
		draw_texture(cloud.image,position)
	if level.mode == "overworld":
		var points: PackedVector2Array = []
		for i: int in range(level.max_level+1):
			points.append(level.NODES[i])
		if points.size() > 1:
			draw_polyline(points,Color("a04f45"),6)
		for i: int in range(6):
			var images: Array = level.frames("overworld/"+str(i))
			var texture: Texture2D = images[int(level.age) % images.size() if i <= level.max_level else 0]
			draw_texture(texture,level.NODES[i]-texture.get_size()/2,Color.WHITE if i <= level.max_level else Color.BLACK)
		var hat: Texture2D = level.image("overworld/hat.png")
		draw_texture(hat,level.icon-hat.get_size()/2)
		return
	for kind: String in ["bg palms", "dust", "terrain", "enemies", "explosions", "crates", "grass", "coins", "fg palms"]:
		if kind in ["dust", "explosions"]:
			for effect: Dictionary in level.effects:
				if (kind == "explosions") != effect.folder.begins_with("enemy/"):
					continue
				var texture: Texture2D = level.frames(effect.folder)[int(effect.frame)]
				draw_texture(texture,effect.position-texture.get_size()/2)
			continue
		for item: Dictionary in level.objects:
			if item.kind != kind or item.rect.end.x < camera-256 or item.rect.position.x > camera+1456:
				continue
			if kind in ["terrain", "grass"]:
				var atlas: Texture2D = TERRAIN if kind == "terrain" else GRASS
				var columns: int = atlas.get_width() / 64
				draw_texture_rect_region(atlas,Rect2(item.rect.position,Vector2(64,64)),Rect2((int(item.tile)%columns)*64,(int(item.tile)/columns)*64,64,64))
			elif kind == "crates":
				draw_texture(level.image("terrain/crate.png"),item.rect.position)
			else:
				var texture: Texture2D = level.frames(item.folder)[int(item.frame)]
				art(texture,item.rect.position,kind == "enemies" and item.speed > 0)
	var body: Rect2 = level.visual_rect()
	if level.status == "run" and level.on_ground:
		var dust: Array = level.frames("character/dust_particles/run")
		art(dust[int(level.age)%dust.size()],Vector2(body.position.x-6,body.end.y-10),not level.facing_right)
	if level.hurt_left <= 0 or sin(Time.get_ticks_msec()) >= 0:
		art(level.frames("character/"+level.status)[int(level.animation)],body.position,not level.facing_right)
	draw_texture(level.image("character/hat.png"),level.goal.position)
	var water: Array = level.frames("decoration/water")
	var water_texture: Texture2D = water[int(level.age)%water.size()]
	for i: int in range(int((level.level_width+2400)/192)):
		var x: float = i*192-1200
		if x+192 >= camera and x <= camera+1200:
			draw_texture(water_texture,Vector2(x,684))
	draw_set_transform(Vector2.ZERO)
	draw_texture(level.image("ui/health_bar.png"),Vector2(20,10))
	draw_rect(Rect2(54,39,152*level.health/100.0,4),Color("dc4949"))
	var coin: Texture2D = level.image("ui/coin.png")
	draw_texture(coin,Vector2(50,61))
	draw_string(FONT,Vector2(54+coin.get_width(),61+coin.get_height()/2+10),str(level.coins),HORIZONTAL_ALIGNMENT_LEFT,-1,30,Color("33323d"))


func art(texture: Texture2D, position: Vector2, flip: bool) -> void:
	draw_set_transform(position-Vector2(camera,0)+Vector2(texture.get_width() if flip else 0,0),0,Vector2(-1 if flip else 1,1))
	draw_texture(texture,Vector2.ZERO)
	draw_set_transform(Vector2(-camera,0))
