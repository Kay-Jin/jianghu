## 战斗场景 - 六边形战棋主场景
extends Node2D

var battle_controller_node: Node2D = null
var ui_node: Node = null
var _effects_node: Node2D = null
var _sound_node: AudioStreamPlayer = null

const HEX_SIZE = 32.0
const GRID_WIDTH = 15
const GRID_HEIGHT = 11

var unit_sprites: Dictionary = {}
var move_highlight_nodes: Array[Node2D] = []
var attack_highlight_nodes: Array[Node2D] = []
var _initialized: bool = false

var character_sprites = {
	"主角": "res://assets/characters/protagonist.png",
	"叶寒江": "res://assets/characters/ye_hanjiang.png",
	"山贼头目": "res://assets/characters/tie_shan.png",
	"山贼甲": "res://assets/characters/tie_shan.png",
	"山贼乙": "res://assets/characters/tie_shan.png",
}

func _ready():
	print("⚔️ 战斗场景初始化")
	
	battle_controller_node = get_node("BattleController")
	ui_node = get_node("UI")
	
	if battle_controller_node == null:
		print("❌ BattleController 不存在！")
		return
	if ui_node == null:
		print("❌ UI 不存在！")
		return
	
	_setup_hex_tilemap()
	_create_unit_sprites()
	
	battle_controller_node.turn_changed.connect(_on_turn_changed)
	battle_controller_node.unit_selected.connect(_on_unit_selected)
	battle_controller_node.unit_moved.connect(animate_unit_move)
	battle_controller_node.unit_attacked.connect(_on_unit_attacked)
	battle_controller_node.martial_art_used.connect(_on_martial_art_used)
	battle_controller_node.battle_ended.connect(_on_battle_ended)
	battle_controller_node.message_shown.connect(_on_message_shown)
	
	var save_system = get_node_or_null("SaveSystem")
	if save_system and ui_node.has_method("setup"):
		ui_node.setup(battle_controller_node, save_system)
	elif ui_node.has_method("setup"):
		ui_node.setup(battle_controller_node)
	
	_effects_node = get_node_or_null("BattleEffects")
	
	_sound_node = AudioStreamPlayer.new()
	_sound_node.name = "ProceduralSound"
	add_child(_sound_node)
	var sound_script = load("res://scripts/procedural_sound.gd")
	if sound_script:
		_sound_node.set_script(sound_script)
	
	_initialized = true
	print("✅ 战斗场景初始化完成")

func _setup_hex_tilemap():
	var tile_map = get_node("BattleTileMap")
	if tile_map == null: return
	
	var tile_set = TileSet.new()
	tile_set.tile_shape = TileSet.TILE_SHAPE_HEXAGON
	tile_set.tile_size = Vector2i(64, 37)
	
	var source = TileSetAtlasSource.new()
	var img = Image.create(64, 37, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.22, 0.18, 0.12))
	for x in range(64):
		for y in range(37):
			var d = min(x, 63-x, y, 36-y)
			if d <= 1: img.set_pixel(x, y, Color(0.35, 0.32, 0.25))
	var tex = ImageTexture.create_from_image(img)
	source.texture = tex
	source.texture_region_size = Vector2i(64, 37)
	source.create_tile(Vector2i(0, 0))
	tile_set.add_source(source, 0)
	tile_map.tile_set = tile_set
	
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
	
	print("✅ TileMap 配置完成")

func _create_unit_sprites():
	if battle_controller_node == null: return
	
	var units = battle_controller_node.units
	for i in range(units.size()):
		var unit = units[i]
		var sprite_container = Node2D.new()
		
		var sprite_path = character_sprites.get(unit["name"], "")
		var sprite_added = false
		
		if sprite_path != "" and ResourceLoader.exists(sprite_path):
			var tex = load(sprite_path)
			if tex is Texture2D:
				var sp = Sprite2D.new()
				sp.texture = tex
				sp.scale = Vector2(0.5, 0.5)
				sp.offset = Vector2(0, -20)
				sprite_container.add_child(sp)
				sprite_added = true
				print("🖼️ 加载立绘：", unit["name"])
		
		if not sprite_added:
			var cr = ColorRect.new()
			cr.color = Color(0.2, 0.6, 0.9, 0.9) if unit["type"] == "player" else Color(0.9, 0.3, 0.3, 0.9)
			cr.size = Vector2(HEX_SIZE * 1.2, HEX_SIZE * 1.2)
			cr.position = Vector2(-HEX_SIZE * 0.6, -HEX_SIZE * 0.6)
			sprite_container.add_child(cr)
		
		var label = Label.new()
		label.text = unit["name"]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.position = Vector2(-HEX_SIZE * 0.8, HEX_SIZE * 0.7)
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_font_size_override("font_size", 10)
		label.size = Vector2(HEX_SIZE * 1.6, 14)
		sprite_container.add_child(label)
		
		sprite_container.position = _hex_to_screen(unit["grid_pos"])
		add_child(sprite_container)
		unit_sprites[i] = sprite_container
	
	print("🎨 创建了 ", unit_sprites.size(), " 个角色精灵")

func _clear_highlights():
	for node in move_highlight_nodes: node.queue_free()
	move_highlight_nodes.clear()
	for node in attack_highlight_nodes: node.queue_free()
	attack_highlight_nodes.clear()

func _highlight_move_range(center: Vector2i, max_range: int):
	_clear_highlights()
	var cells = HexUtils.get_cells_in_range(center, max_range)
	for cell in cells:
		if cell == center: continue
		var h = ColorRect.new()
		h.color = Color(0.2, 0.8, 0.3, 0.3)
		h.size = Vector2(HEX_SIZE * 1.4, HEX_SIZE * 1.4)
		h.position = _hex_to_screen(cell) + Vector2(-HEX_SIZE * 0.7, -HEX_SIZE * 0.7)
		var ov = get_node_or_null("RangeOverlay")
		(ov if ov else self).add_child(h)
		move_highlight_nodes.append(h)

func _highlight_attack_range(center: Vector2i, weapon_range: int):
	for node in move_highlight_nodes: node.queue_free()
	move_highlight_nodes.clear()
	var cells = HexUtils.get_cells_in_range(center, weapon_range)
	for cell in cells:
		if cell == center: continue
		var h = ColorRect.new()
		h.color = Color(0.9, 0.3, 0.3, 0.3)
		h.size = Vector2(HEX_SIZE * 1.4, HEX_SIZE * 1.4)
		h.position = _hex_to_screen(cell) + Vector2(-HEX_SIZE * 0.7, -HEX_SIZE * 0.7)
		var ov = get_node_or_null("RangeOverlay")
		(ov if ov else self).add_child(h)
		attack_highlight_nodes.append(h)

func _unhandled_input(event):
	if not _initialized: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var screen_pos = event.position
		var hex_pos = _screen_to_hex(screen_pos)
		match battle_controller_node.current_state:
			battle_controller_node.State.PLAYER_TURN_SELECT:
				_try_select_unit_at(hex_pos)
			battle_controller_node.State.PLAYER_MOVE:
				_try_move_to(hex_pos)
			battle_controller_node.State.PLAYER_ACTION:
				_try_attack_at(hex_pos)

func _try_select_unit_at(hex_pos: Vector2i):
	for i in range(battle_controller_node.units.size()):
		var unit = battle_controller_node.units[i]
		if unit["grid_pos"] == hex_pos and unit["type"] == "player" and unit["alive"] and not unit["acted"]:
			battle_controller_node.select_unit(i)
			return

func _try_move_to(hex_pos: Vector2i):
	battle_controller_node.move_unit_to(hex_pos)

func _try_attack_at(hex_pos: Vector2i):
	if ui_node and "pending_martial_art" in ui_node:
		var art_id: String = ui_node.pending_martial_art
		if art_id != "":
			for unit in battle_controller_node.units:
				if unit["grid_pos"] == hex_pos and unit["type"] == "enemy" and unit["alive"]:
					battle_controller_node.use_martial_art(battle_controller_node.selected_unit_index, art_id, hex_pos)
					ui_node.pending_martial_art = ""
					_clear_highlights()
					return
	else:
		for unit in battle_controller_node.units:
			if unit["grid_pos"] == hex_pos and unit["type"] == "enemy" and unit["alive"]:
				battle_controller_node.attack_target(hex_pos)
				return

func _hex_to_screen(hex_pos: Vector2i) -> Vector2:
	var x = HEX_SIZE * (sqrt(3.0) * hex_pos.x + sqrt(3.0)/2.0 * (hex_pos.y & 1))
	var y = HEX_SIZE * (3.0/2.0 * hex_pos.y)
	return Vector2(x, y)

func _screen_to_hex(screen_pos: Vector2) -> Vector2i:
	var x = screen_pos.x / (HEX_SIZE * sqrt(3.0))
	var y = screen_pos.y / (HEX_SIZE * 1.5)
	return Vector2i(round(x), round(y))

func animate_unit_move(unit_index: int):
	if not unit_sprites.has(unit_index): return
	var sprite = unit_sprites[unit_index]
	var unit = battle_controller_node.units[unit_index]
	var target_pos = _hex_to_screen(unit["grid_pos"])
	
	if _sound_node:
		_sound_node.play_move()
	
	var tween = create_tween()
	tween.tween_property(sprite, "position", target_pos, 0.3)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(sprite, "scale", Vector2(1.05, 0.95), 0.15)
	
	await tween.finished
	
	var bounce = create_tween()
	var from_y = sprite.position.y
	bounce.tween_property(sprite, "scale", Vector2(1.1, 0.9), 0.08)
	bounce.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.15)
	bounce.parallel().tween_property(sprite, "position:y", from_y - 5, 0.08)
	bounce.parallel().tween_property(sprite, "position:y", from_y, 0.15)
	
	await bounce.finished

func _on_turn_changed(text: String):
	if ui_node and ui_node.has_method("update_turn_text"): ui_node.update_turn_text(text)

func _on_unit_selected(unit_data: Dictionary):
	if ui_node and ui_node.has_method("update_unit_info"): ui_node.update_unit_info(unit_data)
	_highlight_move_range(unit_data["grid_pos"], unit_data["move_range"])

func _on_unit_attacked(attacker_index: int, target_index: int, damage: int):
	if not _effects_node: return
	var attacker_sprite = unit_sprites.get(attacker_index)
	var target_sprite = unit_sprites.get(target_index)
	if not attacker_sprite or not target_sprite: return
	
	var from_pos = attacker_sprite.position
	var to_pos = target_sprite.position
	
	_effects_node.show_slash_effect(from_pos, to_pos, Color(1.0, 0.9, 0.6))
	_effects_node.spawn_hit_particles(to_pos)
	_effects_node.flash_unit_red(target_sprite, 0.2)
	_effects_node.screen_shake(5.0, 0.15)
	_effects_node.show_damage_number(to_pos + Vector2(0, -40), damage)
	
	if _sound_node:
		_sound_node.play_attack_sword()
	
	var lunge = create_tween()
	lunge.tween_property(attacker_sprite, "position", from_pos.lerp(to_pos, 0.15), 0.08)
	lunge.tween_property(attacker_sprite, "position", from_pos, 0.12)

func _on_martial_art_used(attacker_index: int, target_index: int, art_name: String, damage: int):
	if not _effects_node: return
	var attacker_sprite = unit_sprites.get(attacker_index)
	var target_sprite = unit_sprites.get(target_index)
	if not attacker_sprite or not target_sprite: return
	
	var from_pos = attacker_sprite.position
	var to_pos = target_sprite.position
	
	match art_name:
		"断剑剑法":
			MartialArtEffects.create_sword_slash(self, from_pos, to_pos, Color(0.8, 0.85, 1.0))
		"破军":
			MartialArtEffects.create_cross_impact(self, to_pos, Color(1.0, 0.85, 0.15))
			MartialArtEffects.create_explosion_particles(self, to_pos, Color(1.0, 0.85, 0.15), 25)
		_:
			MartialArtEffects.create_sword_slash(self, from_pos, to_pos)
	
	_effects_node.flash_unit_red(target_sprite, 0.3)
	_effects_node.screen_shake(8.0, 0.2)
	_effects_node.show_damage_number(to_pos + Vector2(0, -50), damage, true)
	
	if _sound_node:
		_sound_node.play_martial_art()
	
	var lunge = create_tween()
	lunge.tween_property(attacker_sprite, "position", from_pos.lerp(to_pos, 0.25), 0.1)
	lunge.tween_property(attacker_sprite, "position", from_pos, 0.15)

func _on_battle_ended(winner: String):
	if ui_node and ui_node.has_method("show_battle_end"):
		ui_node.show_battle_end(winner)
	_clear_highlights()
	
	if _sound_node:
		if winner == "player":
			_sound_node.play_victory()
		else:
			_sound_node.play_defeat()
	
	if winner == "player":
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_message_shown(text: String):
	if ui_node and ui_node.has_method("add_log_message"): ui_node.add_log_message(text)

func delayed_free_node(node: Node, delay: float):
	await get_tree().create_timer(delay).timeout
	if is_instance_valid(node):
		node.queue_free()

func _process(_delta):
	if not _initialized: return
	for i in range(battle_controller_node.units.size()):
		if unit_sprites.has(i):
			var unit = battle_controller_node.units[i]
			if not unit["alive"]:
				unit_sprites[i].modulate = Color(0.3, 0.3, 0.3, 0.5)
