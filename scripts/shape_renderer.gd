# Utilidad para crear y dibujar figuras geométricas con bordes
extends Node2D
class_name ShapeRenderer

static func create_shape_node(shape_type: int, size: float) -> Node2D:
	var shape_node = Node2D.new()
	var color = ShapeType.get_color(shape_type)
	
	match shape_type:
		ShapeType.TRIANGLE:
			build_triangle(shape_node, size, color)
		ShapeType.CIRCLE:
			build_circle(shape_node, size, color)
		ShapeType.SQUARE:
			build_square(shape_node, size, color)
	
	return shape_node

static func build_triangle(node: Node2D, size: float, color: Color) -> void:
	var polygon = Polygon2D.new()
	polygon.polygon = PackedVector2Array([
		Vector2(0, -size/2),
		Vector2(-size/2, size/2),
		Vector2(size/2, size/2)
	])
	polygon.color = color
	polygon.antialiased = true
	node.add_child(polygon)
	
	var line = Line2D.new()
	line.width = 3.0
	line.default_color = Color.WHITE
	line.antialiased = true
	line.points = PackedVector2Array([
		Vector2(0, -size/2),
		Vector2(-size/2, size/2),
		Vector2(size/2, size/2),
		Vector2(0, -size/2)
	])
	node.add_child(line)

static func build_circle(node: Node2D, size: float, color: Color) -> void:
	var polygon = Polygon2D.new()
	var points = PackedVector2Array()
	var segments = 32
	for i in range(segments):
		var angle = (i / float(segments)) * TAU
		var x = cos(angle) * (size / 2)
		var y = sin(angle) * (size / 2)
		points.append(Vector2(x, y))
	
	polygon.polygon = points
	polygon.color = color
	polygon.antialiased = true
	node.add_child(polygon)
	
	var line = Line2D.new()
	line.width = 3.0
	line.default_color = Color.WHITE
	line.antialiased = true
	line.points = points
	line.closed = true
	node.add_child(line)

static func build_square(node: Node2D, size: float, color: Color) -> void:
	var polygon = Polygon2D.new()
	var half = size / 2
	polygon.polygon = PackedVector2Array([
		Vector2(-half, -half),
		Vector2(half, -half),
		Vector2(half, half),
		Vector2(-half, half)
	])
	polygon.color = color
	polygon.antialiased = true
	node.add_child(polygon)
	
	var line = Line2D.new()
	line.width = 3.0
	line.default_color = Color.WHITE
	line.antialiased = true
	line.points = PackedVector2Array([
		Vector2(-half, -half),
		Vector2(half, -half),
		Vector2(half, half),
		Vector2(-half, half),
		Vector2(-half, -half)
	])
	node.add_child(line)
