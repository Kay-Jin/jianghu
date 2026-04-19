## 城镇基础场景 — 通用城市/据点 UI
## 所有城市/门派/据点复用此场景，通过 GlobalState.get_flag("pending_town") 确定当前城镇
## 支持：NPC列表 / 对话 / 商店 / 客栈存档 / 前往战斗
extends Control

# ── 城镇 NPC 数据（补充到 game_data.gd 中的角色外的本地NPC）──────────
# key = town_id，value = Array[NPC定义]
const TOWN_NPCS := {
	"duanjian_manor": [
		{"id": "shen_tianjian", "name": "沈天剑", "title": "断剑山庄庄主（义父）",
		 "portrait": "res://assets/characters/shen_tianjian.png",
		 "can_join": false, "shop": false, "quests": ["main_1"],
		 "dialogues": ["main_1_intro", "duanjian_lore", "daily_sword"]},
		{"id": "shen_ren", "name": "沈刃", "title": "首席弟子",
		 "portrait": "res://assets/characters/shen_ren.png",
		 "can_join": true, "shop": false, "quests": ["sq_43"],
		 "dialogues": ["shen_join","shen_daily","shen_post_main1"]},
		{"id": "gu_yuming", "name": "顾昱明", "title": "庄主义子",
		 "portrait": "res://assets/characters/gu_yuming.png",
		 "can_join": true, "shop": false, "quests": ["sq_31"],
		 "dialogues": ["gu_join","gu_secret","gu_daily"]},
		{"id": "blacksmith_duanjian", "name": "段师傅", "title": "山庄铁匠",
		 "portrait": "",
		 "can_join": false, "shop": true, "shop_type": "weapon", "quests": [],
		 "dialogues": ["shop_greeting"]},
	],
	"linyan_city": [
		{"id": "wei_zhuiyun", "name": "卫追云", "title": "六扇门女捕头",
		 "portrait": "res://assets/characters/wei_zhuiyun.png",
		 "can_join": true, "shop": false, "quests": ["sq_11","sq_33"],
		 "dialogues": ["wei_intro","wei_join","wei_reform"]},
		{"id": "yun_moyan", "name": "云墨烟", "title": "万花楼花魁（卧底）",
		 "portrait": "res://assets/characters/yun_moyan.png",
		 "can_join": true, "shop": false, "quests": [],
		 "dialogues": ["yun_intro","yun_intel","yun_join"]},
		{"id": "cai_jing_aide", "name": "蔡京管家", "title": "宰相府管家",
		 "portrait": "",
		 "can_join": false, "shop": false, "quests": [],
		 "dialogues": ["caijing_blockade"]},
		{"id": "linyan_inn", "name": "同福客栈老板", "title": "客栈掌柜",
		 "portrait": "",
		 "can_join": false, "shop": true, "shop_type": "inn", "quests": [],
		 "dialogues": ["inn_welcome"]},
		{"id": "linyan_weapon_shop", "name": "天工坊掌柜", "title": "铸剑大师",
		 "portrait": "",
		 "can_join": false, "shop": true, "shop_type": "weapon", "quests": [],
		 "dialogues": ["shop_greeting"]},
		{"id": "linyan_pharmacy", "name": "百草堂坐诊", "title": "药铺老板",
		 "portrait": "",
		 "can_join": false, "shop": true, "shop_type": "medicine", "quests": [],
		 "dialogues": ["shop_greeting"]},
	],
	"gusu_city": [
		{"id": "shen_qingyuan", "name": "沈清鸢", "title": "听雨楼少主",
		 "portrait": "res://assets/characters/shen_qingyuan.png",
		 "can_join": true, "shop": false, "quests": ["main_2"],
		 "dialogues": ["shen_qingyuan_intro","shen_qingyuan_main2","shen_qingyuan_join"]},
		{"id": "ke_xingyue", "name": "珂星月", "title": "逍遥渡东海游侠",
		 "portrait": "res://assets/characters/ke_xingyue.png",
		 "can_join": true, "shop": false, "quests": ["sq_13"],
		 "dialogues": ["ke_intro","ke_join","ke_sea"]},
		{"id": "gusu_inn", "name": "水乡客栈掌柜", "title": "老板娘",
		 "portrait": "",
		 "can_join": false, "shop": true, "shop_type": "inn", "quests": [],
		 "dialogues": ["inn_welcome"]},
	],
	"yanshan_city": [
		{"id": "yan_zheng", "name": "燕铮", "title": "铁血盟统领",
		 "portrait": "res://assets/characters/yan_zheng.png",
		 "can_join": true, "shop": false, "quests": ["main_5","sq_34"],
		 "dialogues": ["yan_intro","yan_join","yan_war"]},
		{"id": "fang_feng", "name": "方烽", "title": "边境溃兵",
		 "portrait": "res://assets/characters/fang_feng.png",
		 "can_join": true, "shop": false, "quests": ["sq_48"],
		 "dialogues": ["fang_intro","fang_join","fang_letter"]},
		{"id": "yanshan_weapon", "name": "军械司", "title": "军需官",
		 "portrait": "",
		 "can_join": false, "shop": true, "shop_type": "weapon", "quests": [],
		 "dialogues": ["shop_greeting"]},
	],
	"yao_wang_valley": [
		{"id": "bai_zhi", "name": "白芷", "title": "药王谷传人",
		 "portrait": "res://assets/characters/bai_zhi.png",
		 "can_join": true, "shop": false, "quests": ["main_3","sq_32"],
		 "dialogues": ["bai_intro","bai_join","bai_medical"]},
		{"id": "nie_wushang", "name": "聂无殇", "title": "毒医",
		 "portrait": "res://assets/characters/nie_wushang.png",
		 "can_join": true, "shop": false, "quests": ["sq_42"],
		 "dialogues": ["nie_intro","nie_join","nie_patient"]},
		{"id": "yao_shop", "name": "药王谷弟子", "title": "药材供给",
		 "portrait": "",
		 "can_join": false, "shop": true, "shop_type": "medicine", "quests": [],
		 "dialogues": ["shop_greeting"]},
	],
	"penglai_city": [
		{"id": "qingxu", "name": "清虚", "title": "逍遥渡散人",
		 "portrait": "res://assets/characters/qingxu.png",
		 "can_join": true, "shop": false, "quests": ["sq_35"],
		 "dialogues": ["qingxu_intro","qingxu_join","qingxu_sea"]},
		{"id": "ke_xingyue_penglai", "name": "珂星月", "title": "东海游侠",
		 "portrait": "res://assets/characters/ke_xingyue.png",
		 "can_join": true, "shop": false, "quests": ["sq_13"],
		 "dialogues": ["ke_intro","ke_join"]},
	],
	"longmen_inn": [
		{"id": "ba_tuer", "name": "巴图尔", "title": "西域使者",
		 "portrait": "res://assets/characters/ba_tuer.png",
		 "can_join": true, "shop": false, "quests": ["sq_19","sq_45"],
		 "dialogues": ["ba_intro","ba_join","ba_mission"]},
		{"id": "longmen_inn_boss", "name": "龙门掌柜", "title": "客栈老板",
		 "portrait": "",
		 "can_join": false, "shop": true, "shop_type": "inn", "quests": [],
		 "dialogues": ["inn_welcome"]},
	],
}

# 商店库存（shop_type → Array[item_id]）
const SHOP_INVENTORY := {
	"weapon":   ["iron_sword", "fine_sword", "battle_saber", "mechanism_crossbow"],
	"armor":    ["cloth_robe", "leather_armor", "iron_armor"],
	"medicine": ["hp_small", "hp_medium", "mp_small", "antidote", "revive"],
	"inn":      [],  # inn 不卖物品，提供住宿/存档
}

# 对话数据库 — 占位对话（美术提供立绘后可扩展）
const DIALOGUES := {
	"main_1_intro": [
		{"speaker": "沈天剑", "text": "渊儿，你终于来了。山庄出事了，我需要你的帮助。"},
		{"speaker": "林渊", "text": "义父，发生了什么？"},
		{"speaker": "沈天剑", "text": "你的师叔……沈天影，他背叛了我们。"},
	],
	"duanjian_lore": [
		{"speaker": "沈天剑", "text": "断剑山庄创立于前朝，以'断而不折'为训。"},
		{"speaker": "林渊", "text": "（悄悄记笔记）……这相当于企业文化了。"},
	],
	"daily_sword": [
		{"speaker": "沈天剑", "text": "今日练剑了吗？"},
		{"speaker": "林渊", "text": "练了练了，我在用项目管理方法论学剑法。"},
		{"speaker": "沈天剑", "text": "……你这孩子，真叫人哭笑不得。"},
	],
	"shen_join": [
		{"speaker": "沈刃", "text": "主角，我要随你一起。山庄的仇，我要亲手报。"},
		{"speaker": "林渊", "text": "有你在太好了。欢迎加入队伍！"},
	],
	"shen_daily": [
		{"speaker": "沈刃", "text": "今天又出发了。"},
		{"speaker": "林渊", "text": "对。你准备好了吗？"},
		{"speaker": "沈刃", "text": "我总是准备好的。"},
	],
	"shen_post_main1": [
		{"speaker": "沈刃", "text": "义父被救了，但真正的主谋还没找到。"},
		{"speaker": "林渊", "text": "我知道。我们继续。"},
	],
	"jiang_join": [
		{"speaker": "江明辉", "text": "我是义父的义子，但……我对义父隐瞒了一件事。"},
		{"speaker": "林渊", "text": "你可以慢慢告诉我。跟我走吗？"},
		{"speaker": "江明辉", "text": "好。你好像不是普通的江湖人。"},
		{"speaker": "林渊", "text": "（干笑）我是……特殊的那种。"},
	],
	"su_intro": [
		{"speaker": "苏婉儿", "text": "你就是最近在江湖上声名大噪的那个人？"},
		{"speaker": "林渊", "text": "还谈不上声名大噪。我只是个……路人。"},
		{"speaker": "苏婉儿", "text": "有趣。我的情报网里没有你的档案，这本身就很有趣。"},
	],
	"su_join": [
		{"speaker": "苏婉儿", "text": "听雨楼可以成为你的后盾，但我需要一件事。"},
		{"speaker": "林渊", "text": "什么事？"},
		{"speaker": "苏婉儿", "text": "帮我找到内鬼。主线二·听雨暗流，就此开始。"},
	],
	"pei_intro": [
		{"speaker": "裴青鸾", "text": "六扇门，裴青鸾。我在调查一起案子，你的名字在卷宗里出现了。"},
		{"speaker": "林渊", "text": "……我解释一下。"},
		{"speaker": "裴青鸾", "text": "不用解释，我看过。你没嫌疑。我只是想问你几个问题。"},
	],
	"pei_join": [
		{"speaker": "裴青鸾", "text": "六扇门内部有些事我一个人推不动，你……愿意帮我吗？"},
		{"speaker": "林渊", "text": "我帮过很多'推不动的项目'。加入队伍吧。"},
		{"speaker": "裴青鸾", "text": "……项目？"},
	],
	"yan_intro": [
		{"speaker": "燕铮", "text": "外乡人，铁血盟的地方，没事别乱逛。"},
		{"speaker": "林渊", "text": "我来找你谈正事。关于燕山防线。"},
		{"speaker": "燕铮", "text": "（审视主角片刻）……进来谈。"},
	],
	"yan_join": [
		{"speaker": "燕铮", "text": "你不是武林中人，但你的想法有用。"},
		{"speaker": "林渊", "text": "我管过团队。带兵和带项目，道理一样的。"},
		{"speaker": "燕铮", "text": "哈。那一起上吧。"},
	],
	"bai_intro": [
		{"speaker": "白芷", "text": "你有伤？"},
		{"speaker": "林渊", "text": "不算伤……只是累。"},
		{"speaker": "白芷", "text": "来，让我看看。（伸出手）"},
	],
	"bai_join": [
		{"speaker": "白芷", "text": "谷里的药材被人控制了，我一个人解决不了。"},
		{"speaker": "林渊", "text": "我刚好要去查这件事。跟我走？"},
		{"speaker": "白芷", "text": "好。路上我帮你治伤。"},
	],
	"inn_welcome": [
		{"speaker": "掌柜", "text": "客官，住店还是吃饭？小店上下都有。"},
	],
	"shop_greeting": [
		{"speaker": "掌柜", "text": "客官，看看我们的货？保证物美价廉！"},
	],
}

# ── 当前城镇数据 ──────────────────────────────
var _town_id: String = ""
var _town_npcs: Array = []
var _current_dialogue: Array = []
var _dialogue_index: int = 0
var _current_npc: Dictionary = {}

# UI引用
var _town_title: Label
var _bg_image: TextureRect
var _npc_container: VBoxContainer
var _dialogue_panel: Panel
var _speaker_label: Label
var _dialogue_text: RichTextLabel
var _choices_container: VBoxContainer
var _portrait_display: TextureRect
var _shop_panel: Panel
var _shop_items_container: VBoxContainer

func _ready() -> void:
	_town_id = str(GlobalState.get_flag("pending_town"))
	if _town_id.is_empty() or _town_id == "false":
		_town_id = "duanjian_manor"
	_town_npcs = TOWN_NPCS.get(_town_id, [])
	_build_ui()

func _build_ui() -> void:
	# 背景颜色
	var bg_color := ColorRect.new()
	bg_color.anchors_preset = Control.PRESET_FULL_RECT
	bg_color.color = Color(0.07, 0.05, 0.1)
	add_child(bg_color)

	# 场景背景图（需提供图片）
	_bg_image = TextureRect.new()
	_bg_image.anchors_preset = Control.PRESET_FULL_RECT
	_bg_image.stretch_mode = TextureRect.STRETCH_SCALE
	_bg_image.modulate = Color(1, 1, 1, 0.5)
	_load_town_bg()
	add_child(_bg_image)

	# 场景名标题
	var loc_data: Dictionary = GameData.LOCATIONS.get(GlobalState.current_location, {})
	_town_title = Label.new()
	_town_title.text = _get_town_display_name()
	_town_title.add_theme_font_size_override("font_size", 26)
	_town_title.add_theme_color_override("font_color", Color(0.95, 0.88, 0.65))
	_town_title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_town_title.offset_top = 12
	_town_title.offset_bottom = 50
	_town_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_town_title)

	# 主布局
	var main_hbox := HBoxContainer.new()
	main_hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_hbox.offset_top = 56
	main_hbox.offset_left = 16
	main_hbox.offset_right = -16
	main_hbox.offset_bottom = -60
	main_hbox.add_theme_constant_override("separation", 12)
	add_child(main_hbox)

	# ── 左侧 NPC 列表 ────────────────────────
	var npc_panel := Panel.new()
	npc_panel.custom_minimum_size = Vector2(220, 0)
	npc_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var np_style := StyleBoxFlat.new()
	np_style.bg_color = Color(0.08, 0.06, 0.12, 0.9)
	np_style.set_border_width_all(1)
	np_style.border_color = Color(0.35, 0.28, 0.5)
	npc_panel.add_theme_stylebox_override("panel", np_style)
	main_hbox.add_child(npc_panel)

	var npc_scroll := ScrollContainer.new()
	npc_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	npc_panel.add_child(npc_scroll)

	_npc_container = VBoxContainer.new()
	_npc_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_npc_container.add_theme_constant_override("separation", 4)
	npc_scroll.add_child(_npc_container)

	var npc_title := Label.new()
	npc_title.text = "  在场人物"
	npc_title.add_theme_font_size_override("font_size", 14)
	npc_title.add_theme_color_override("font_color", Color(0.7, 0.65, 0.5))
	_npc_container.add_child(npc_title)

	for npc in _town_npcs:
		_add_npc_button(npc)

	# ── 中间：对话区域 ────────────────────────
	var center_vbox := VBoxContainer.new()
	center_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_vbox.add_theme_constant_override("separation", 8)
	main_hbox.add_child(center_vbox)

	# 上方：立绘显示区
	var portrait_area := Panel.new()
	portrait_area.custom_minimum_size = Vector2(0, 340)
	portrait_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var pa_style := StyleBoxFlat.new()
	pa_style.bg_color = Color(0.1, 0.08, 0.14, 0.7)
	portrait_area.add_theme_stylebox_override("panel", pa_style)
	center_vbox.add_child(portrait_area)

	_portrait_display = TextureRect.new()
	_portrait_display.anchors_preset = Control.PRESET_FULL_RECT
	_portrait_display.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait_display.expand_mode = TextureRect.EXPAND_FIT_HEIGHT
	portrait_area.add_child(_portrait_display)

	var no_npc_hint := Label.new()
	no_npc_hint.name = "NoNpcHint"
	no_npc_hint.text = "点击左侧人物名字开始对话"
	no_npc_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	no_npc_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	no_npc_hint.anchors_preset = Control.PRESET_FULL_RECT
	no_npc_hint.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	portrait_area.add_child(no_npc_hint)

	# 下方：对话框
	_dialogue_panel = Panel.new()
	_dialogue_panel.custom_minimum_size = Vector2(0, 180)
	_dialogue_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_dialogue_panel.visible = false
	var dp_style := StyleBoxFlat.new()
	dp_style.bg_color = Color(0.05, 0.04, 0.09, 0.95)
	dp_style.set_border_width_all(1)
	dp_style.border_color = Color(0.45, 0.38, 0.65)
	_dialogue_panel.add_theme_stylebox_override("panel", dp_style)
	center_vbox.add_child(_dialogue_panel)

	var dlg_vbox := VBoxContainer.new()
	dlg_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	dlg_vbox.offset_left = 12
	dlg_vbox.offset_top = 8
	dlg_vbox.offset_right = -12
	dlg_vbox.offset_bottom = -8
	_dialogue_panel.add_child(dlg_vbox)

	_speaker_label = Label.new()
	_speaker_label.add_theme_font_size_override("font_size", 15)
	_speaker_label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.5))
	dlg_vbox.add_child(_speaker_label)

	_dialogue_text = RichTextLabel.new()
	_dialogue_text.bbcode_enabled = true
	_dialogue_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_dialogue_text.add_theme_font_size_override("normal_font_size", 16)
	dlg_vbox.add_child(_dialogue_text)

	_choices_container = VBoxContainer.new()
	_choices_container.add_theme_constant_override("separation", 4)
	dlg_vbox.add_child(_choices_container)

	var next_btn := Button.new()
	next_btn.name = "NextBtn"
	next_btn.text = "继续 ▶"
	next_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	next_btn.custom_minimum_size = Vector2(100, 34)
	next_btn.pressed.connect(_on_next_dialogue)
	dlg_vbox.add_child(next_btn)

	# ── 右侧：商店面板（默认隐藏）────────────
	_shop_panel = Panel.new()
	_shop_panel.custom_minimum_size = Vector2(280, 0)
	_shop_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_shop_panel.visible = false
	var sp_style := StyleBoxFlat.new()
	sp_style.bg_color = Color(0.09, 0.07, 0.13, 0.92)
	sp_style.set_border_width_all(1)
	sp_style.border_color = Color(0.5, 0.42, 0.25)
	_shop_panel.add_theme_stylebox_override("panel", sp_style)
	main_hbox.add_child(_shop_panel)

	var shop_vbox := VBoxContainer.new()
	shop_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	shop_vbox.offset_left = 8
	shop_vbox.offset_top = 8
	shop_vbox.offset_right = -8
	shop_vbox.offset_bottom = -8
	_shop_panel.add_child(shop_vbox)

	var shop_title := Label.new()
	shop_title.name = "ShopTitle"
	shop_title.text = "商店"
	shop_title.add_theme_font_size_override("font_size", 17)
	shop_title.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	shop_vbox.add_child(shop_title)

	var gold_lbl := Label.new()
	gold_lbl.name = "GoldLabel"
	gold_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	shop_vbox.add_child(gold_lbl)

	var shop_scroll := ScrollContainer.new()
	shop_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shop_vbox.add_child(shop_scroll)

	_shop_items_container = VBoxContainer.new()
	_shop_items_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_scroll.add_child(_shop_items_container)

	var shop_close := Button.new()
	shop_close.text = "关闭商店"
	shop_close.pressed.connect(func(): _shop_panel.visible = false)
	shop_vbox.add_child(shop_close)

	# ── 底部操作栏 ────────────────────────────
	var bottom_bar := HBoxContainer.new()
	bottom_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_bar.offset_bottom = -6
	bottom_bar.offset_top = -54
	bottom_bar.offset_left = 12
	bottom_bar.offset_right = -12
	bottom_bar.add_theme_constant_override("separation", 8)
	add_child(bottom_bar)

	var map_btn := Button.new()
	map_btn.text = "🗺️ 世界地图"
	map_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_btn.custom_minimum_size = Vector2(0, 44)
	map_btn.pressed.connect(_on_goto_world_map)
	bottom_bar.add_child(map_btn)

	var save_btn := Button.new()
	save_btn.text = "💾 存档"
	save_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_btn.custom_minimum_size = Vector2(0, 44)
	save_btn.pressed.connect(func(): SaveSystem.save_game(0))
	bottom_bar.add_child(save_btn)

func _get_town_display_name() -> String:
	match _town_id:
		"duanjian_manor": return "断剑山庄"
		"linyan_city": return "临渊城·京城"
		"gusu_city": return "姑苏城"
		"yanshan_city": return "燕山城"
		"yao_wang_valley": return "药王谷"
		"penglai_city": return "蓬莱城"
		"longmen_inn": return "龙门客栈"
		_: return _town_id

func _load_town_bg() -> void:
	var bg_path: String = "res://assets/backgrounds/town_%s.png" % _town_id
	if ResourceLoader.exists(bg_path):
		_bg_image.texture = load(bg_path)

func _add_npc_button(npc: Dictionary) -> void:
	var btn := Button.new()
	var in_party: bool = GlobalState.is_in_party(npc.get("id", ""))
	var party_tag: String = " [队]" if in_party else ""
	btn.text = "%s%s\n[color=#888888]%s[/color]" % [npc.get("name", "?"), party_tag, npc.get("title", "")]
	btn.add_theme_font_size_override("font_size", 13)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.pressed.connect(_on_npc_clicked.bind(npc))
	if npc.get("shop", false):
		btn.modulate = Color(1.0, 0.9, 0.5)
	elif in_party:
		btn.modulate = Color(0.7, 1.0, 0.75)
	_npc_container.add_child(btn)

func _on_npc_clicked(npc: Dictionary) -> void:
	_current_npc = npc
	get_node_or_null("NoNpcHint")

	# 更新立绘
	_portrait_display.texture = null
	var portrait_path: String = npc.get("portrait", "")
	if portrait_path != "" and ResourceLoader.exists(portrait_path):
		_portrait_display.texture = load(portrait_path)

	if npc.get("shop", false):
		_open_shop(npc.get("shop_type", "weapon"))
		return

	_shop_panel.visible = false

	# 选择对话：优先显示任务触发对话
	var dialogue_id: String = _pick_best_dialogue(npc)
	var dialogue_lines: Array = DIALOGUES.get(dialogue_id, [
		{"speaker": npc.get("name", "NPC"), "text": "（此NPC暂无对话数据，待剧本填入）"}
	])
	_start_dialogue(dialogue_lines, npc)

func _pick_best_dialogue(npc: Dictionary) -> String:
	# 优先使用未完成任务的触发对话
	for quest_id in npc.get("quests", []):
		if GlobalState.get_quest_state(quest_id) == "inactive":
			var key: String = npc.get("id", "") + "_intro"
			if DIALOGUES.has(key): return key
	# 其次根据好感度选择
	var aff: int = GlobalState.get_affection(npc.get("id", ""))
	if aff >= 50:
		var key: String = npc.get("id", "") + "_close"
		if DIALOGUES.has(key): return key
	# 默认日常对话
	var dialogues: Array = npc.get("dialogues", [])
	if dialogues.is_empty(): return ""
	return dialogues[0]

func _start_dialogue(lines: Array, npc: Dictionary) -> void:
	_current_dialogue = lines
	_dialogue_index = 0
	_dialogue_panel.visible = true
	_show_dialogue_line()
	# 触发好感度上涨（和NPC对话）
	GlobalState.change_affection(npc.get("id", ""), 2)
	# 检查任务触发
	for quest_id in npc.get("quests", []):
		if GlobalState.get_quest_state(quest_id) == "inactive":
			GlobalState.start_quest(quest_id)

func _show_dialogue_line() -> void:
	if _dialogue_index >= _current_dialogue.size():
		_end_dialogue()
		return
	var line: Dictionary = _current_dialogue[_dialogue_index]
	_speaker_label.text = line.get("speaker", "")
	_dialogue_text.text = "[color=#e8e4d8]" + line.get("text", "") + "[/color]"
	# 清除选项
	for child in _choices_container.get_children():
		child.queue_free()
	# 如果有选项
	var choices: Array = line.get("choices", [])
	for choice in choices:
		var btn := Button.new()
		btn.text = choice.get("text", "")
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_choice.bind(choice))
		_choices_container.add_child(btn)
	var next_btn := _dialogue_panel.get_node_or_null("VBoxContainer/NextBtn")
	if next_btn:
		next_btn.visible = choices.is_empty()

func _on_next_dialogue() -> void:
	_dialogue_index += 1
	_show_dialogue_line()

func _on_choice(choice: Dictionary) -> void:
	if choice.has("quest_choice"):
		GlobalState.set_quest_choice(
			choice.quest_choice.get("quest_id", ""),
			choice.quest_choice.get("key", ""),
			choice.quest_choice.get("value")
		)
	if choice.has("affection_delta"):
		GlobalState.change_affection(_current_npc.get("id", ""), choice.affection_delta)
	# 加入队伍选项
	if choice.get("join_party", false):
		GlobalState.add_party_member(_current_npc.get("id", ""))
	_dialogue_index += 1
	_show_dialogue_line()

func _end_dialogue() -> void:
	_dialogue_panel.visible = false
	# 检查是否可以加入队伍
	if _current_npc.get("can_join", false) and not GlobalState.is_in_party(_current_npc.get("id", "")):
		_show_join_prompt()

func _show_join_prompt() -> void:
	var confirm := ConfirmationDialog.new()
	confirm.title = "邀请加入队伍"
	confirm.dialog_text = "邀请 [%s] 加入队伍？\n（当前队伍 %d/%d）" % [
		_current_npc.get("name", ""),
		GlobalState.party.size(),
		GlobalState.max_party_size
	]
	confirm.confirmed.connect(func():
		if GlobalState.add_party_member(_current_npc.get("id", "")):
			print("[Town] %s 加入队伍" % _current_npc.get("name", ""))
		confirm.queue_free()
	)
	confirm.canceled.connect(func(): confirm.queue_free())
	add_child(confirm)
	confirm.popup_centered()

func _open_shop(shop_type: String) -> void:
	_shop_panel.visible = true
	var gold_lbl := _shop_panel.get_node_or_null("VBoxContainer/GoldLabel") as Label
	if gold_lbl: gold_lbl.text = "持有金两：%d 两" % GlobalState.gold
	var title_lbl := _shop_panel.get_node_or_null("VBoxContainer/ShopTitle") as Label
	if title_lbl:
		match shop_type:
			"weapon": title_lbl.text = "⚔️ 武器铺"
			"armor": title_lbl.text = "🛡️ 甲具店"
			"medicine": title_lbl.text = "💊 药铺"
			"inn": title_lbl.text = "🏨 客栈"
			_: title_lbl.text = "商店"

	for child in _shop_items_container.get_children():
		child.queue_free()

	if shop_type == "inn":
		_add_inn_options()
		return

	var items: Array = SHOP_INVENTORY.get(shop_type, [])
	for item_id in items:
		var item_data: Dictionary = GameData.ITEMS.get(item_id, {})
		if item_data.is_empty(): continue
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		var name_lbl := Label.new()
		name_lbl.text = item_data.get("name", item_id)
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
		row.add_child(name_lbl)
		var price_lbl := Label.new()
		price_lbl.text = "%d 两" % item_data.get("price", 0)
		price_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		row.add_child(price_lbl)
		var buy_btn := Button.new()
		buy_btn.text = "购买"
		buy_btn.custom_minimum_size = Vector2(56, 0)
		buy_btn.pressed.connect(_on_buy_item.bind(item_id, item_data.get("price", 0)))
		row.add_child(buy_btn)
		_shop_items_container.add_child(row)

func _add_inn_options() -> void:
	var rest_btn := Button.new()
	rest_btn.text = "🛏️ 住宿休息（免费 / 存档）"
	rest_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rest_btn.pressed.connect(_on_inn_rest)
	_shop_items_container.add_child(rest_btn)

func _on_inn_rest() -> void:
	# 恢复全队HP/MP，推进时间，自动存档
	var prot: Dictionary = GlobalState.protagonist
	var bd: Dictionary = GameData.calc_battle_stats(
		prot.base_stats.merged(prot.bonus_stats), prot.level
	)
	GlobalState.protagonist.hp = bd.max_hp
	GlobalState.protagonist.mp = bd.max_mp
	GlobalState.advance_time(8.0)
	SaveSystem.save_game(0)
	var popup := AcceptDialog.new()
	popup.title = "客栈"
	popup.dialog_text = "好好睡了一觉。\nHP/MP 全额恢复，游戏已自动存档。"
	add_child(popup)
	popup.popup_centered()

func _on_buy_item(item_id: String, price: int) -> void:
	if GlobalState.spend_gold(price):
		GlobalState.add_item(item_id, 1)
		var item_name: String = GameData.ITEMS.get(item_id, {}).get("name", item_id)
		print("[Shop] 购买：%s" % item_name)
		var gold_lbl := _shop_panel.get_node_or_null("VBoxContainer/GoldLabel") as Label
		if gold_lbl: gold_lbl.text = "持有金两：%d 两" % GlobalState.gold
	else:
		var popup := AcceptDialog.new()
		popup.title = "提示"
		popup.dialog_text = "金两不足！"
		add_child(popup)
		popup.popup_centered()

func _on_goto_world_map() -> void:
	get_tree().change_scene_to_file("res://scenes/world_map.tscn")
