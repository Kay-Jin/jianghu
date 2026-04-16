## 简单战斗测试
extends Node2D

func _ready():
	print("🎮 战斗测试场景初始化")
	print("✅ 主角立绘已加载")
	
	# 配置六边形网格
	var tile_map = get_node("Grid")
	if tile_map:
		var tile_set = TileSet.new()
		tile_set.tile_shape = TileSet.TILE_SHAPE_HEXAGON
		tile_set.tile_size = Vector2i(64, 37)
		
		var source = TileSetAtlasSource.new()
		var img = Image.create(64, 37, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.22, 0.18, 0.12))
		var tex = ImageTexture.create_from_image(img)
		
		source.texture = tex
		source.texture_region_size = Vector2i(64, 37)
		source.create_tile(Vector2i(0, 0))
		tile_set.add_source(source, 0)
		tile_map.tile_set = tile_set
		
		# 填充网格
		for x in range(15):
			for y in range(11):
				tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
		
		print("✅ 六边形网格已配置")

func _process(_delta):
	# 简单的玩家移动测试
	if Input.is_action_pressed("ui_right"):
		$Player.position.x += 5
	if Input.is_action_pressed("ui_left"):
		$Player.position.x -= 5
	if Input.is_action_pressed("ui_down"):
		$Player.position.y += 5
	if Input.is_action_pressed("ui_up"):
		$Player.position.y -= 5
