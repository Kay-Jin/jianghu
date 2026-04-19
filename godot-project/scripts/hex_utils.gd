## 六边形网格工具函数
class_name HexUtils

static func hex_distance(a: Vector2i, b: Vector2i) -> int:
	var ax = a.x
	var az = a.x + a.y
	var bx = b.x
	var bz = b.x + b.y
	return max(abs(ax - bx), abs(az - bz), abs((-ax - az) - (-bx - bz)))

static func hex_neighbors(pos: Vector2i) -> Array[Vector2i]:
	var x = pos.x
	var y = pos.y
	var parity = y & 1
	var directions_odd: Array[Vector2i] = [
		Vector2i(+1, 0), Vector2i(0, -1),
		Vector2i(-1, 0), Vector2i(0, +1),
		Vector2i(+1, +1), Vector2i(-1, +1)
	]
	var directions_even: Array[Vector2i] = [
		Vector2i(+1, 0), Vector2i(+1, -1),
		Vector2i(-1, 0), Vector2i(-1, +1),
		Vector2i(0, +1), Vector2i(0, -1)
	]
	
	if parity == 1:
		return directions_odd
	else:
		return directions_even

static func get_cells_in_range(center: Vector2i, max_range: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var visited: Dictionary = {}
	var queue: Array[Vector2i] = [center]
	visited[center] = 0
	
	while queue.size() > 0:
		var current = queue.pop_front()
		var current_dist = visited[current]
		
		if current_dist <= max_range:
			result.append(current)
			
			if current_dist < max_range:
				for neighbor in hex_neighbors(current):
					if not visited.has(neighbor):
						visited[neighbor] = current_dist + 1
						queue.append(neighbor)
	
	return result

static func is_in_range(from: Vector2i, to: Vector2i, max_range: int) -> bool:
	return hex_distance(from, to) <= max_range

## 与 Godot TileMap 六角格邻接一致（BFS 步数 = 移动消耗）
static func get_cells_in_range_tilemap(tm: TileMap, center: Vector2i, max_range: int, grid_w: int, grid_h: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var visited: Dictionary = {}
	var queue: Array[Vector2i] = [center]
	visited[center] = 0
	while queue.size() > 0:
		var current: Vector2i = queue.pop_front()
		var current_dist: int = visited[current]
		if current_dist <= max_range:
			result.append(current)
			if current_dist < max_range:
				for neighbor: Vector2i in tm.get_surrounding_cells(current):
					if neighbor.x < 0 or neighbor.y < 0 or neighbor.x >= grid_w or neighbor.y >= grid_h:
						continue
					if not visited.has(neighbor):
						visited[neighbor] = current_dist + 1
						queue.append(neighbor)
	return result

static func is_in_range_tilemap(tm: TileMap, from: Vector2i, to: Vector2i, max_range: int, grid_w: int, grid_h: int) -> bool:
	for c: Vector2i in get_cells_in_range_tilemap(tm, from, max_range, grid_w, grid_h):
		if c == to:
			return true
	return false

static func move_toward(from: Vector2i, to: Vector2i, max_steps: int) -> Vector2i:
	var current = from
	for step in range(max_steps):
		if current == to:
			break
		
		var neighbors = hex_neighbors(current)
		var best_neighbor = current
		var best_dist = hex_distance(current, to)
		
		for neighbor in neighbors:
			var dist = hex_distance(neighbor, to)
			if dist < best_dist:
				best_dist = dist
				best_neighbor = neighbor
		
		if best_neighbor != current:
			current = best_neighbor
		else:
			break
	
	return current
