## 世界大地图场景 — 九宫格区域导航
## 玩家可在此选择前往各大区域
extends Control

var _location_buttons: Dictionary = {}   # location_id → Button
var _info_panel: RichTextLabel
var _hovered_location: String = ""

# 九宫格布局（row, col）
const GRID_POSITIONS := {
	"northwest_desert":  Vector2i(0, 0),
	"hebei_yanshan":     Vector2i(0, 1),
	"liaodong":          Vector2i(0, 2),
	"sichuan_qingcheng": Vector2i(1, 0),
	"capital_city":      Vector2i(1, 1),
	"east_sea":          Vector2i(1, 2),
	"southern_mountains":Vector2i(2, 0),
	"jiangnan":          Vector2i(2, 1),
	"jiangnan_south":    Vector2i(2, 2),
}

const REGION_ICONS := {
	"northwest_desert":   "🏜️",
	"hebei_yanshan":      "⛰️",
	"liaodong":           "❄️",
	"sichuan_qingcheng":  "🌿",
	"capital_city":       "⭐",
	"east_sea":           "🌊",
	"southern_mountains": "🌲",
	"jiangnan":           "🌸",
	"jiangnan_south":     "🏯",
}

func _ready() -> void:
	_build_ui()
	_refresh_buttons()

func _build_ui() -> void:
	# 背景
	var bg := ColorRect.new()
	bg.anchors_preset = Control.PRESET_FULL_RECT
	bg.color = Color(0.06, 0.04, 0.10)
	add_child(bg)

	# 地图背景图片（需提供 res://assets/ui/world_map_bg.png）
	var map_bg := TextureRect.new()
	map_bg.anchors_preset = Control.PRESET_FULL_RECT
	map_bg.stretch_mode = TextureRect.STRETCH_SCALE
	map_bg.modulate = Color(1, 1, 1, 0.35)
	if ResourceLoader.exists("res://assets/ui/world_map_bg.png"):
		map_bg.texture = load("res://assets/ui/world_map_bg.png")
	add_child(map_bg)

	# 标题
	var title := Label.new()
	title.text = "🗺️  江湖大地图"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(0.95, 0.88, 0.65))
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 16
	title.offset_bottom = 60
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)

	# 时间/日期条
	var time_lbl := Label.new()
	time_lbl.name = "TimeLabel"
	time_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	time_lbl.set_anchors_preset(Control.PRESET_TOP_WIDE)
	time_lbl.offset_top = 60
	time_lbl.offset_bottom = 88
	time_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(time_lbl)

	# 主布局：九宫格 + 右侧信息面板
	var main_hbox := HBoxContainer.new()
	main_hbox.add_theme_constant_override("separation", 20)
	main_hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_hbox.offset_top = 90
	main_hbox.offset_left = 20
	main_hbox.offset_right = -20
	main_hbox.offset_bottom = -70
	add_child(main_hbox)

	# 九宫格容器
	var grid := GridContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	main_hbox.add_child(grid)

	# 按行列顺序添加九个格子
	for row in 3:
		for col in 3:
			var loc_id: String = ""
			for lid in GRID_POSITIONS:
				if GRID_POSITIONS[lid] == Vector2i(row, col):
					loc_id = lid
					break
			if loc_id.is_empty():
				var empty := Control.new()
				grid.add_child(empty)
				continue
			var loc_data: Dictionary = GameData.LOCATIONS.get(loc_id, {})
			var btn := Button.new()
			btn.custom_minimum_size = Vector2(0, 110)
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
			var icon: String = REGION_ICONS.get(loc_id, "📍")
			btn.text = "%s\n%s" % [icon, loc_data.get("name", loc_id)]
			btn.add_theme_font_size_override("font_size", 15)
			btn.mouse_entered.connect(_on_region_hover.bind(loc_id))
			btn.pressed.connect(_on_region_pressed.bind(loc_id))
			_location_buttons[loc_id] = btn
			grid.add_child(btn)

	# 右侧信息面板
	var right_panel := Panel.new()
	right_panel.custom_minimum_size = Vector2(320, 0)
	right_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var rp_style := StyleBoxFlat.new()
	rp_style.bg_color = Color(0.1, 0.08, 0.15, 0.9)
	rp_style.set_border_width_all(1)
	rp_style.border_color = Color(0.4, 0.3, 0.6)
	rp_style.corner_radius_top_left = 6
	rp_style.corner_radius_top_right = 6
	rp_style.corner_radius_bottom_left = 6
	rp_style.corner_radius_bottom_right = 6
	right_panel.add_theme_stylebox_override("panel", rp_style)
	main_hbox.add_child(right_panel)

	_info_panel = RichTextLabel.new()
	_info_panel.anchors_preset = Control.PRESET_FULL_RECT
	_info_panel.offset_left = 12
	_info_panel.offset_top = 12
	_info_panel.offset_right = -12
	_info_panel.offset_bottom = -12
	_info_panel.bbcode_enabled = true
	_info_panel.text = "[color=#888888]将鼠标移到地区，查看详情。\n点击地区进行移动。[/color]"
	right_panel.add_child(_info_panel)

	# 底部操作栏
	var bottom_bar := HBoxContainer.new()
	bottom_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_bar.offset_bottom = -8
	bottom_bar.offset_top = -56
	bottom_bar.offset_left = 20
	bottom_bar.offset_right = -20
	bottom_bar.add_theme_constant_override("separation", 12)
	add_child(bottom_bar)

	var party_btn := Button.new()
	party_btn.text = "👥 队伍管理"
	party_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	party_btn.custom_minimum_size = Vector2(0, 44)
	party_btn.pressed.connect(_on_party_btn)
	bottom_bar.add_child(party_btn)

	var inv_btn := Button.new()
	inv_btn.text = "🎒 背包"
	inv_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inv_btn.custom_minimum_size = Vector2(0, 44)
	inv_btn.pressed.connect(_on_inventory_btn)
	bottom_bar.add_child(inv_btn)

	var save_btn := Button.new()
	save_btn.text = "💾 存档"
	save_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_btn.custom_minimum_size = Vector2(0, 44)
	save_btn.pressed.connect(_on_save_btn)
	bottom_bar.add_child(save_btn)

	var menu_btn := Button.new()
	menu_btn.text = "≡ 主菜单"
	menu_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu_btn.custom_minimum_size = Vector2(0, 44)
	menu_btn.pressed.connect(_on_menu_btn)
	bottom_bar.add_child(menu_btn)

func _process(_delta) -> void:
	var tl := get_node_or_null("TimeLabel") as Label
	if tl:
		tl.text = "第 %d 天  %s" % [GlobalState.game_day, GlobalState.get_time_of_day_label()]

func _refresh_buttons() -> void:
	var current: String = GlobalState.current_location
	for loc_id in _location_buttons:
		var btn: Button = _location_buttons[loc_id]
		var loc_data: Dictionary = GameData.LOCATIONS.get(loc_id, {})
		var cond: String = loc_data.get("unlock_condition", "")
		var locked: bool = _is_locked(cond)
		btn.disabled = locked
		if loc_id == current:
			btn.modulate = Color(0.6, 1.0, 0.65)  # 当前位置高亮绿
		elif locked:
			btn.modulate = Color(0.4, 0.4, 0.4)
		else:
			btn.modulate = Color(1.0, 1.0, 1.0)

func _is_locked(condition: String) -> bool:
	if condition.is_empty(): return false
	if condition.begins_with("quest:"):
		var parts: PackedStringArray = condition.split(":")
		if parts.size() < 2: return false
		# quest:main_3_started → check if main_3 is active or complete
		var quest_id: String = parts[1].replace("_started", "")
		var state: String = GlobalState.get_quest_state(quest_id)
		return state == "inactive"
	return false

func _on_region_hover(loc_id: String) -> void:
	_hovered_location = loc_id
	var loc_data: Dictionary = GameData.LOCATIONS.get(loc_id, {})
	var current: String = GlobalState.current_location
	var is_current: bool = (loc_id == current)
	var locked: bool = _is_locked(loc_data.get("unlock_condition", ""))
	var towns: Array = loc_data.get("towns", [])
	var text: String = (
		"[color=#f5c060][b]%s[/b][/color]\n\n"
		+ "[color=#cccccc]%s[/color]\n\n"
	) % [loc_data.get("name", loc_id), loc_data.get("desc", "")]
	if is_current:
		text += "[color=#88ff88]✓ 你当前所在此地[/color]\n"
	elif locked:
		text += "[color=#ff6666]🔒 需要完成特定任务才能前往[/color]\n"
	else:
		text += "[color=#aaccff]点击→ 前往此地（消耗约8小时）[/color]\n"
	if towns.size() > 0:
		text += "\n[color=#ffdd88]可前往：" + "、".join(towns) + "[/color]"
	_info_panel.text = text

func _on_region_pressed(loc_id: String) -> void:
	if loc_id == GlobalState.current_location:
		_travel_to_town(loc_id)
		return
	var loc_data: Dictionary = GameData.LOCATIONS.get(loc_id, {})
	if _is_locked(loc_data.get("unlock_condition", "")):
		return
	# 移动到该区域
	GlobalState.travel_to(loc_id)
	_refresh_buttons()
	_travel_to_town(loc_id)

func _travel_to_town(loc_id: String) -> void:
	# 前往该区域的城镇（如果有）
	var loc_data: Dictionary = GameData.LOCATIONS.get(loc_id, {})
	var towns: Array = loc_data.get("towns", [])
	if towns.is_empty():
		# 无城镇，触发随机事件或野外场景（占位→直接回到地图）
		_info_panel.text = "[color=#ffaa44]该区域暂无城镇，后续版本开放。[/color]"
		return
	# 把目标城镇 ID 存入 pending 参数，然后跳转到 town_base 场景
	GlobalState.set_flag("pending_town", towns[0])
	get_tree().change_scene_to_file("res://scenes/town_base.tscn")

func _on_party_btn() -> void:
	# 简单弹出队伍信息（后续可扩展为完整队伍管理场景）
	var popup := AcceptDialog.new()
	popup.title = "当前队伍"
	var names: Array = []
	for char_id in GlobalState.party:
		var cd: Dictionary = GameData.CHARACTERS.get(char_id, {})
		names.append(cd.get("name", char_id))
	popup.dialog_text = "队伍成员（%d/%d）：\n%s" % [
		GlobalState.party.size(), GlobalState.max_party_size,
		"\n".join(names)
	]
	add_child(popup)
	popup.popup_centered()

func _on_inventory_btn() -> void:
	var popup := AcceptDialog.new()
	popup.title = "背包"
	var lines: Array = ["金两：%d 两" % GlobalState.gold]
	for item_id in GlobalState.inventory:
		var item_data: Dictionary = GameData.ITEMS.get(item_id, {})
		lines.append("%s × %d" % [item_data.get("name", item_id), GlobalState.inventory[item_id]])
	popup.dialog_text = "\n".join(lines) if lines.size() > 1 else "金两：%d 两\n（背包空空如也）" % GlobalState.gold
	add_child(popup)
	popup.popup_centered()

func _on_save_btn() -> void:
	SaveSystem.save_game(0)
	var popup := AcceptDialog.new()
	popup.title = "存档"
	popup.dialog_text = "游戏已存档（槽位 1）"
	add_child(popup)
	popup.popup_centered()

func _on_menu_btn() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
