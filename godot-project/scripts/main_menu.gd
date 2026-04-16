## 江湖打工人 - 主菜单
extends Control

func _ready():
	print("🎮 江湖打工人 - 主菜单")
	print("引擎：Godot 4.3")
	print("项目：六边形战棋 RPG")
	print("版本：Demo v0.1")

func _on_tutorial_button_pressed():
	print("📖 启动序章教学...")
	get_tree().change_scene_to_file("res://scenes/tutorial.tscn")

func _on_start_button_pressed():
	print("🎮 启动六边形战棋战斗...")
	get_tree().change_scene_to_file("res://scenes/battle.tscn")

func _on_town_button_pressed():
	print("🏯 进入断剑山庄...")
	get_tree().change_scene_to_file("res://scenes/duanjian_town.tscn")

func _on_map_button_pressed():
	print("🗺️ 打开世界大地图...")
	get_tree().change_scene_to_file("res://scenes/world_map.tscn")

func _on_save_button_pressed():
	print("💾 打开存档...")
	get_tree().change_scene_to_file("res://scenes/save_scene.tscn")

func _on_load_button_pressed():
	print("📂 打开读档...")
	get_tree().change_scene_to_file("res://scenes/save_scene.tscn")

func _on_affection_button_pressed():
	print("💕 打开好感度...")
	get_tree().change_scene_to_file("res://scenes/affection_scene.tscn")

func _on_settings_button_pressed():
	print("⚙️ 设置菜单（待实现）")

func _on_quit_button_pressed():
	print("👋 再见！")
	get_tree().quit()
