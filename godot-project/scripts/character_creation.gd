## 角色创建场景 — 程序化构建 UI
## 主角固定：现代项目经理穿越者
## 玩家操作：分配15点属性 + 选择江湖出身加成
extends Control

const TOTAL_FREE_POINTS := 15
const MIN_STAT := 1
const MAX_STAT := 20

var _free_points: int = TOTAL_FREE_POINTS
var _allocated: Dictionary = {"gengu": 0, "neili": 0, "wuxing": 0, "shenfa": 0, "tipo": 0}
var _selected_origin: String = "project_manager"

# UI节点引用
var _points_label: Label
var _confirm_btn: Button
var _origin_option: OptionButton
var _origin_desc: RichTextLabel
var _stat_rows: Dictionary = {}   # stat_id → {label_val, btn_plus, btn_minus}
var _preview_panel: RichTextLabel

const STAT_NAMES := {
	"gengu": "根骨（攻击基础）",
	"neili": "内力（MP/内功）",
	"wuxing": "悟性（学武/洞察）",
	"shenfa": "身法（移动/回避）",
	"tipo": "体魄（HP/防御）"
}

func _ready() -> void:
	_build_ui()
	_refresh_preview()

func _build_ui() -> void:
	# 背景
	var bg := ColorRect.new()
	bg.anchors_preset = Control.PRESET_FULL_RECT
	bg.color = Color(0.08, 0.06, 0.12)
	add_child(bg)

	# 水墨纹理覆盖层（需要美术：res://assets/ui/creation_bg.png）
	var bg_art := TextureRect.new()
	bg_art.name = "BgArt"
	bg_art.anchors_preset = Control.PRESET_FULL_RECT
	bg_art.stretch_mode = TextureRect.STRETCH_SCALE
	bg_art.modulate = Color(1, 1, 1, 0.18)
	if ResourceLoader.exists("res://assets/ui/creation_bg.png"):
		bg_art.texture = load("res://assets/ui/creation_bg.png")
	add_child(bg_art)

	# 主布局：左右两栏
	var hbox := HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.set_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(hbox)

	# ── 左栏：角色展示 ──────────────────────
	var left_panel := Panel.new()
	left_panel.custom_minimum_size = Vector2(420, 0)
	left_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var lp_style := StyleBoxFlat.new()
	lp_style.bg_color = Color(0.1, 0.08, 0.15, 0.85)
	lp_style.set_border_width_all(1)
	lp_style.border_color = Color(0.4, 0.3, 0.6)
	left_panel.add_theme_stylebox_override("panel", lp_style)
	hbox.add_child(left_panel)

	var left_vbox := VBoxContainer.new()
	left_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	left_vbox.set_offsets_preset(Control.PRESET_FULL_RECT)
	left_vbox.add_theme_constant_override("separation", 12)
	var lm := left_vbox.add_theme_constant_override.bind("margin_left", 20)
	left_panel.add_child(left_vbox)

	_add_padding(left_vbox, 20)

	var title := Label.new()
	title.text = "创建主角"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.95, 0.88, 0.65))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left_vbox.add_child(title)

	# 角色立绘占位
	var portrait_frame := Panel.new()
	portrait_frame.custom_minimum_size = Vector2(240, 320)
	portrait_frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var pf_style := StyleBoxFlat.new()
	pf_style.bg_color = Color(0.15, 0.12, 0.2)
	pf_style.set_border_width_all(2)
	pf_style.border_color = Color(0.5, 0.4, 0.7)
	portrait_frame.add_theme_stylebox_override("panel", pf_style)
	left_vbox.add_child(portrait_frame)

	var portrait := TextureRect.new()
	portrait.anchors_preset = Control.PRESET_FULL_RECT
	portrait.expand_mode = TextureRect.EXPAND_FIT_HEIGHT
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists("res://assets/characters/protagonist.png"):
		portrait.texture = load("res://assets/characters/protagonist.png")
	else:
		# 占位文字
		var ph := Label.new()
		ph.text = "【立绘占位】\n主角立绘\nres://assets/characters/\nprotagonist.png"
		ph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ph.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		ph.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		ph.anchors_preset = Control.PRESET_FULL_RECT
		portrait_frame.add_child(ph)
	portrait_frame.add_child(portrait)

	# 固定背景说明
	var bg_text := RichTextLabel.new()
	bg_text.custom_minimum_size = Vector2(360, 120)
	bg_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bg_text.bbcode_enabled = true
	bg_text.text = (
		"[color=#f5dfa0][b]林渊 · 现代项目经理（穿越后18岁）[/b][/color]\n\n"
		+ "「本来在出差途中用手机改需求文档，睁眼已身在宋代江湖。\n"
		+ "武功为零，内力不存在，但我管过30人的跨部门团队。\n"
		+ "还好——手机还有电，圆珠笔还有墨水。\n"
		+ "身体变成18岁了……先当作一个bug记下来。」\n\n"
		+ "[color=#aaaaaa]★ 主角身份固定，影响主线剧情与对话[/color]"
	)
	left_vbox.add_child(bg_text)

	_add_padding(left_vbox, 8)

	# 状态预览
	_preview_panel = RichTextLabel.new()
	_preview_panel.custom_minimum_size = Vector2(360, 130)
	_preview_panel.bbcode_enabled = true
	_preview_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_vbox.add_child(_preview_panel)

	# ── 右栏：属性分配 + 出身选择 ────────────
	var right_scroll := ScrollContainer.new()
	right_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_child(right_scroll)

	var right_vbox := VBoxContainer.new()
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.add_theme_constant_override("separation", 10)
	right_scroll.add_child(right_vbox)

	_add_padding(right_vbox, 16)

	# 属性分配标题
	var attr_title := Label.new()
	attr_title.text = "分配属性点"
	attr_title.add_theme_font_size_override("font_size", 20)
	attr_title.add_theme_color_override("font_color", Color(0.85, 0.75, 0.5))
	right_vbox.add_child(attr_title)

	_points_label = Label.new()
	_points_label.add_theme_color_override("font_color", Color(0.4, 0.95, 0.6))
	_points_label.add_theme_font_size_override("font_size", 16)
	right_vbox.add_child(_points_label)

	# 五维属性行
	for stat_id in ["gengu","neili","wuxing","shenfa","tipo"]:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		var base_val: int = GlobalState.protagonist.base_stats.get(stat_id, 5)

		var lbl := Label.new()
		lbl.text = STAT_NAMES.get(stat_id, stat_id)
		lbl.custom_minimum_size = Vector2(180, 0)
		lbl.add_theme_color_override("font_color", Color(0.88, 0.85, 0.95))
		row.add_child(lbl)

		var btn_minus := Button.new()
		btn_minus.text = "−"
		btn_minus.custom_minimum_size = Vector2(36, 36)
		btn_minus.pressed.connect(_on_stat_minus.bind(stat_id))
		row.add_child(btn_minus)

		var val_lbl := Label.new()
		val_lbl.text = str(base_val)
		val_lbl.custom_minimum_size = Vector2(40, 0)
		val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		val_lbl.add_theme_font_size_override("font_size", 18)
		val_lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
		row.add_child(val_lbl)

		var btn_plus := Button.new()
		btn_plus.text = "＋"
		btn_plus.custom_minimum_size = Vector2(36, 36)
		btn_plus.pressed.connect(_on_stat_plus.bind(stat_id))
		row.add_child(btn_plus)

		_stat_rows[stat_id] = {"label": val_lbl, "plus": btn_plus, "minus": btn_minus}
		right_vbox.add_child(row)

	_add_padding(right_vbox, 12)

	# 出身选择
	var origin_title := Label.new()
	origin_title.text = "江湖出身"
	origin_title.add_theme_font_size_override("font_size", 20)
	origin_title.add_theme_color_override("font_color", Color(0.85, 0.75, 0.5))
	right_vbox.add_child(origin_title)

	_origin_option = OptionButton.new()
	_origin_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for origin_id in GameData.ORIGINS:
		var origin_data: Dictionary = GameData.ORIGINS[origin_id]
		_origin_option.add_item(origin_data.name)
		_origin_option.set_item_metadata(_origin_option.item_count - 1, origin_id)
	_origin_option.item_selected.connect(_on_origin_selected)
	right_vbox.add_child(_origin_option)

	_origin_desc = RichTextLabel.new()
	_origin_desc.custom_minimum_size = Vector2(0, 100)
	_origin_desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_origin_desc.bbcode_enabled = true
	right_vbox.add_child(_origin_desc)

	_add_padding(right_vbox, 16)

	# 确认按钮
	_confirm_btn = Button.new()
	_confirm_btn.text = "✦ 开始游戏 ✦"
	_confirm_btn.custom_minimum_size = Vector2(0, 52)
	_confirm_btn.add_theme_font_size_override("font_size", 20)
	_confirm_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_confirm_btn.pressed.connect(_on_confirm)
	right_vbox.add_child(_confirm_btn)

	_add_padding(right_vbox, 20)

	_refresh_ui()

# ── UI 刷新 ──────────────────────────────────
func _refresh_ui() -> void:
	_points_label.text = "剩余属性点：%d" % _free_points
	for stat_id in _stat_rows:
		var row: Dictionary = _stat_rows[stat_id]
		var base: int = GlobalState.protagonist.base_stats.get(stat_id, 5)
		var alloc: int = _allocated.get(stat_id, 0)
		row.label.text = str(base + alloc)
		row.plus.disabled = _free_points <= 0 or (base + alloc) >= MAX_STAT
		row.minus.disabled = alloc <= 0
	_refresh_origin_desc()
	_refresh_preview()

func _refresh_origin_desc() -> void:
	var origin_data: Dictionary = GameData.ORIGINS.get(_selected_origin, {})
	if origin_data.is_empty(): return
	var bonus_str: String = ""
	for s in origin_data.get("bonus_stats", {}):
		bonus_str += "  %s +%d\n" % [STAT_NAMES.get(s, s), origin_data.bonus_stats[s]]
	var items_str: String = ""
	for item_id in origin_data.get("bonus_items", []):
		items_str += GameData.ITEMS.get(item_id, {}).get("name", item_id) + "  "
	_origin_desc.text = (
		"[color=#aaffaa]" + origin_data.get("description", "") + "[/color]\n\n"
		+ ("[color=#f5c060]属性加成：\n" + bonus_str + "[/color]" if bonus_str else "")
		+ ("\n[color=#88ccff]初始道具：" + items_str + "[/color]" if items_str else "")
		+ "\n[color=#f5c060]起始金钱：" + str(origin_data.get("bonus_gold", 0)) + " 两[/color]"
	)

func _refresh_preview() -> void:
	if _preview_panel == null: return
	var prot: Dictionary = GlobalState.protagonist
	var merged: Dictionary = {}
	for k in prot.base_stats:
		merged[k] = prot.base_stats[k] + _allocated.get(k, 0)
	var origin_data: Dictionary = GameData.ORIGINS.get(_selected_origin, {})
	for s in origin_data.get("bonus_stats", {}):
		merged[s] = merged.get(s, 0) + origin_data.bonus_stats[s]
	var bd: Dictionary = GameData.calc_battle_stats(merged, 1)
	_preview_panel.bbcode_enabled = true
	_preview_panel.text = (
		"[color=#aaaaaa]—— 预览数值 ——[/color]\n"
		+ "[color=#ff8888]HP %d[/color]  [color=#88aaff]MP %d[/color]\n"
		+ "攻击 %d  防御 %d  移动 %d格"
	) % [bd.max_hp, bd.max_mp, bd.attack, bd.defense, bd.move_range]

# ── 事件回调 ─────────────────────────────────
func _on_stat_plus(stat_id: String) -> void:
	if _free_points <= 0: return
	var base: int = GlobalState.protagonist.base_stats.get(stat_id, 5)
	if base + _allocated.get(stat_id, 0) >= MAX_STAT: return
	_allocated[stat_id] = _allocated.get(stat_id, 0) + 1
	_free_points -= 1
	_refresh_ui()

func _on_stat_minus(stat_id: String) -> void:
	if _allocated.get(stat_id, 0) <= 0: return
	_allocated[stat_id] -= 1
	_free_points += 1
	_refresh_ui()

func _on_origin_selected(idx: int) -> void:
	_selected_origin = _origin_option.get_item_metadata(idx)
	_refresh_ui()

func _on_confirm() -> void:
	_confirm_btn.disabled = true
	GlobalState.init_new_game(_selected_origin, _allocated)
	SaveSystem.save_game(0)
	get_tree().change_scene_to_file("res://scenes/world_map.tscn")

# ── 辅助 ─────────────────────────────────────
func _add_padding(parent: Control, height: int) -> void:
	var pad := Control.new()
	pad.custom_minimum_size = Vector2(0, height)
	parent.add_child(pad)
