## 战斗表现：伤害数字、受击闪红、简单震屏、斩击线
extends Node2D

func show_slash_effect(from_pos: Vector2, to_pos: Vector2, color: Color) -> void:
	var line := Line2D.new()
	line.width = 3.0
	line.default_color = color
	line.points = PackedVector2Array([from_pos, to_pos])
	add_child(line)
	var tw := create_tween()
	tw.tween_property(line, "modulate:a", 0.0, 0.15)
	tw.finished.connect(line.queue_free)

func spawn_hit_particles(pos: Vector2) -> void:
	for _i in 6:
		var p := ColorRect.new()
		p.size = Vector2(4, 4)
		p.color = Color(1.0, 0.85, 0.4, 0.9)
		p.position = pos
		add_child(p)
		var tw := create_tween()
		var dir := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * randf_range(16.0, 48.0)
		tw.tween_property(p, "position", pos + dir, 0.25)
		tw.parallel().tween_property(p, "modulate:a", 0.0, 0.25)
		tw.finished.connect(p.queue_free)

func flash_unit_red(sprite: Node2D, duration: float) -> void:
	if sprite == null:
		return
	var orig := sprite.modulate
	sprite.modulate = Color(1.0, 0.35, 0.35)
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", orig, duration)

func screen_shake(amount: float, duration: float) -> void:
	var scene_root := get_parent()
	if scene_root == null:
		return
	var target: Node2D = scene_root.get_node_or_null("BattleCamera") as Camera2D
	if target == null:
		target = scene_root
	var orig: Vector2 = target.position
	var tw := create_tween()
	var steps := 5
	var step_t := duration / float(steps)
	for _i in steps:
		var off := Vector2(randf_range(-amount, amount), randf_range(-amount, amount))
		tw.tween_property(target, "position", orig + off, step_t)
	tw.tween_property(target, "position", orig, step_t)

func show_damage_number(pos: Vector2, damage: int, is_heavy: bool = false) -> void:
	var lbl := Label.new()
	lbl.text = str(damage)
	lbl.add_theme_color_override("font_color", Color.GOLD if is_heavy else Color.WHITE)
	lbl.add_theme_font_size_override("font_size", 18 if is_heavy else 14)
	lbl.position = pos
	add_child(lbl)
	var tw := create_tween()
	tw.tween_property(lbl, "position:y", pos.y - 36.0, 0.55)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.55)
	tw.finished.connect(lbl.queue_free)
