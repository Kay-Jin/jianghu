## 江湖打工人 - 主菜单
extends Control

func _ready():
	print("🎮 江湖打工人 · 主菜单")
	_check_continue_available()

func _check_continue_available() -> void:
	var meta := SaveSystem.get_slot_meta(0)
	var continue_btn := get_node_or_null("CenterLayer/MenuColumn/ContinueButton") as Button
	if continue_btn:
		if meta.is_empty():
			continue_btn.disabled = true
			continue_btn.text = "继续游戏（无存档）"
		else:
			continue_btn.text = "继续游戏  第%d天 Lv.%d" % [meta.get("game_day",1), meta.get("level",1)]

func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/character_creation.tscn")

func _on_continue_button_pressed() -> void:
	if SaveSystem.load_game(0):
		get_tree().change_scene_to_file("res://scenes/world_map.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/character_creation.tscn")

func _on_tutorial_button_pressed():
	_change_scene_if_exists("res://scenes/tutorial.tscn", "序章教学")

func _on_town_button_pressed():
	GlobalState.set_flag("pending_town", "duanjian_manor")
	get_tree().change_scene_to_file("res://scenes/town_base.tscn")

func _on_map_button_pressed():
	get_tree().change_scene_to_file("res://scenes/world_map.tscn")

func _on_save_button_pressed():
	SaveSystem.save_game(0)
	print("✅ 快速存档完成")

func _on_load_button_pressed():
	if SaveSystem.load_game(0):
		get_tree().change_scene_to_file("res://scenes/world_map.tscn")

func _on_affection_button_pressed():
	_change_scene_if_exists("res://scenes/affection_scene.tscn", "好感度")

func _on_settings_button_pressed():
	print("⚙️ 设置菜单（待实现）")

func _on_quit_button_pressed():
	print("👋 再见！")
	get_tree().quit()

func _change_scene_if_exists(path: String, label: String) -> void:
	if ResourceLoader.exists(path):
		get_tree().change_scene_to_file(path)
	else:
		print("暂未开放：", label)
