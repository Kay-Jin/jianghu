## SaveSystem — 存档/读档（Autoload）
## JSON 格式，存储在 user://saves/
extends Node

const SAVE_DIR := "user://saves/"
const MAX_SLOTS := 5

signal save_success(slot: int)
signal load_success(slot: int)
signal save_failed(slot: int, reason: String)
signal load_failed(slot: int, reason: String)

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

# ── 存档 ─────────────────────────────────────
func save_game(slot: int = 0) -> bool:
	if slot < 0 or slot >= MAX_SLOTS:
		save_failed.emit(slot, "槽位超出范围")
		return false
	var state: Dictionary = GlobalState.to_dict()
	state["save_time"] = Time.get_datetime_string_from_system()
	state["play_seconds"] = _get_play_seconds()
	var json_str: String = JSON.stringify(state, "\t")
	var path: String = SAVE_DIR + "save_%d.json" % slot
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		save_failed.emit(slot, "无法写入文件")
		return false
	file.store_string(json_str)
	file.close()
	save_success.emit(slot)
	print("[SaveSystem] 存档 %d 成功" % slot)
	return true

# ── 读档 ─────────────────────────────────────
func load_game(slot: int = 0) -> bool:
	var path: String = SAVE_DIR + "save_%d.json" % slot
	if not FileAccess.file_exists(path):
		load_failed.emit(slot, "存档文件不存在")
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		load_failed.emit(slot, "无法读取文件")
		return false
	var json_str: String = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(json_str)
	if not (parsed is Dictionary):
		load_failed.emit(slot, "存档格式损坏")
		return false
	GlobalState.from_dict(parsed)
	load_success.emit(slot)
	print("[SaveSystem] 读档 %d 成功" % slot)
	return true

# ── 快存快读 ─────────────────────────────────
func quick_save() -> bool:
	return save_game(0)

func quick_load() -> bool:
	return load_game(0)

# ── 存档元数据（不加载完整状态）────────────
func get_slot_meta(slot: int) -> Dictionary:
	var path: String = SAVE_DIR + "save_%d.json" % slot
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return {}
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary): return {}
	return {
		"slot": slot,
		"save_time": parsed.get("save_time", "未知"),
		"game_day": parsed.get("game_day", 0),
		"location": parsed.get("current_location", ""),
		"level": parsed.get("protagonist", {}).get("level", 1),
		"play_seconds": parsed.get("play_seconds", 0),
	}

func get_all_slots_meta() -> Array:
	var result: Array = []
	for i in MAX_SLOTS:
		result.append(get_slot_meta(i))
	return result

func delete_slot(slot: int) -> void:
	var path: String = SAVE_DIR + "save_%d.json" % slot
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)

# ── 辅助 ─────────────────────────────────────
var _session_start_time: int = 0

func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		_session_start_time = Time.get_ticks_msec()

func _get_play_seconds() -> int:
	return int((Time.get_ticks_msec() - _session_start_time) / 1000.0)
