## 武功表现用简单线条 / 粒子（可后续替换为正式特效）
extends RefCounted

static func create_sword_slash(parent: Node, from_pos: Vector2, to_pos: Vector2, color: Color = Color.WHITE) -> void:
	var line := Line2D.new()
	line.width = 4.0
	line.default_color = color
	line.points = PackedVector2Array([from_pos, to_pos])
	parent.add_child(line)
	var tw := parent.create_tween()
	tw.tween_property(line, "modulate:a", 0.0, 0.2)
	tw.finished.connect(line.queue_free)

static func create_cross_impact(parent: Node, pos: Vector2, color: Color) -> void:
	create_sword_slash(parent, pos + Vector2(-40, -40), pos + Vector2(40, 40), color)
	create_sword_slash(parent, pos + Vector2(-40, 40), pos + Vector2(40, -40), color)

static func create_explosion_particles(parent: Node, pos: Vector2, color: Color, count: int) -> void:
	for _i in count:
		var p := ColorRect.new()
		p.size = Vector2(3, 3)
		p.color = color
		p.position = pos
		parent.add_child(p)
		var tw := parent.create_tween()
		var dir := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * randf_range(24.0, 72.0)
		tw.tween_property(p, "position", pos + dir, 0.45)
		tw.parallel().tween_property(p, "modulate:a", 0.0, 0.45)
		tw.finished.connect(p.queue_free)
