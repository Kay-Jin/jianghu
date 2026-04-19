## 战斗 UI：回合提示、单位信息、日志、行动按钮
extends CanvasLayer

var _controller = null
var pending_martial_art: String = ""

const _ART_LABELS := {
	"duan_jian_jian_fa": "断剑剑法",
	"po_jun": "破军",
}

func setup(controller, _save_system = null) -> void:
	_controller = controller
	$ActionButtons/AttackButton.pressed.connect(_on_attack_pressed)
	$ActionButtons/SkillButton.pressed.connect(_on_skill_pressed)
	$ActionButtons/WaitButton.pressed.connect(_on_wait_pressed)
	$EndTurnButton.pressed.connect(_on_end_turn_pressed)
	$BattleEndPanel/RestartButton.pressed.connect(_on_restart_pressed)
	_refresh_chrome()

func update_turn_text(text: String) -> void:
	$TurnInfo/TurnLabel.text = text
	_refresh_chrome()

func update_unit_info(unit_data: Dictionary) -> void:
	$UnitInfoPanel.visible = true
	$UnitInfoPanel/UnitName.text = unit_data.get("name", "")
	$UnitInfoPanel/UnitHP.text = "HP: %d/%d" % [unit_data["hp"], unit_data["max_hp"]]
	var mp: int = unit_data.get("mp", 0)
	var max_mp: int = unit_data.get("max_mp", 0)
	$UnitInfoPanel/UnitMP.text = "MP: %d/%d" % [mp, max_mp]
	$UnitInfoPanel/UnitStats.text = "攻击:%d 防御:%d 移动:%d" % [
		unit_data["attack"], unit_data["defense"], unit_data["move_range"]
	]

func add_log_message(text: String) -> void:
	var log: TextEdit = $BattleLog/LogText
	log.text += text + "\n"
	var bar := log.get_v_scroll_bar()
	if bar:
		bar.value = bar.max_value

func show_battle_end(winner: String) -> void:
	$BattleEndPanel.visible = true
	var win_text := "战斗胜利！" if winner == "player" else "战斗失败"
	$BattleEndPanel/BattleEndLabel.text = win_text
	$ActionButtons.visible = false
	$EndTurnButton.visible = false
	$HintLabel.text = ""

func _refresh_chrome() -> void:
	if _controller == null:
		return
	var st: Variant = _controller.current_state
	var player_action: bool = st == _controller.State.PLAYER_ACTION
	$ActionButtons.visible = player_action
	var player_phase: bool = (
		st == _controller.State.PLAYER_TURN_SELECT
		or st == _controller.State.PLAYER_MOVE
		or st == _controller.State.PLAYER_ACTION
	)
	$EndTurnButton.visible = player_phase
	var hint: Label = $HintLabel
	match st:
		_controller.State.PLAYER_TURN_SELECT:
			hint.text = "① 左键点击未行动过的己方单位（蓝色方块）"
		_controller.State.PLAYER_MOVE:
			hint.text = "② 点击地图上的绿色高亮六角格，移动到该格"
		_controller.State.PLAYER_ACTION:
			hint.text = "③ 直接点敌人普攻，或先点「武功」再点敌人；「等待」结束本角色行动"
		_controller.State.ENEMY_TURN:
			hint.text = "敌方行动中…"
		_:
			hint.text = ""

func _on_attack_pressed() -> void:
	pending_martial_art = ""
	add_log_message("普通攻击：请点击敌方格子")

func _on_skill_pressed() -> void:
	if _controller == null or _controller.selected_unit_index < 0:
		add_log_message("请先选择我方单位并完成移动")
		return
	var unit: Dictionary = _controller.units[_controller.selected_unit_index]
	var arts: Array = unit.get("martial_arts", [])
	if arts.is_empty():
		add_log_message("该角色暂无可用武功")
		return
	var menu := PopupMenu.new()
	add_child(menu)
	for idx in arts.size():
		var art_id: String = arts[idx]
		var label: String = _ART_LABELS.get(art_id, art_id)
		menu.add_item(label, idx)
	menu.id_pressed.connect(func(id: int):
		pending_martial_art = arts[id]
		add_log_message("已选择武功，请点击敌方格子")
		menu.queue_free()
	)
	menu.popup(Rect2i(get_viewport().get_mouse_position(), Vector2i.ZERO))

func _on_wait_pressed() -> void:
	if _controller:
		_controller.wait_unit()
	pending_martial_art = ""

func _on_end_turn_pressed() -> void:
	if _controller == null:
		return
	for unit in _controller.units:
		if unit["type"] == "player" and unit["alive"] and not unit["acted"]:
			unit["acted"] = true
	_controller.start_enemy_turn()
	pending_martial_art = ""

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
