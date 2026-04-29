extends Control

@onready var play_button = $HUD/CenterContainer/VBox/PlayButton
@onready var record_label = $HUD/RecordLabel
@onready var last_score_label = $HUD/LastScoreLabel

var decorative_shapes = []

func _ready():
	_create_decorative_shape(Vector2(200, 300), 60, ShapeType.TRIANGLE, 0.3)
	_create_decorative_shape(Vector2(880, 350), 60, ShapeType.CIRCLE, 0.3)
	_create_decorative_shape(Vector2(150, 800), 50, ShapeType.SQUARE, 0.3)
	_create_decorative_shape(Vector2(900, 1100), 40, ShapeType.TRIANGLE, 0.2)
	_create_decorative_shape(Vector2(200, 1400), 50, ShapeType.CIRCLE, 0.2)
	_create_decorative_shape(Vector2(850, 1500), 35, ShapeType.SQUARE, 0.2)
	
	load_scores()
	play_button.pressed.connect(_on_play_pressed)

func _create_decorative_shape(pos: Vector2, size: float, shape_type: int, alpha: float) -> void:
	var base_node = Node2D.new()
	base_node.position = pos
	add_child(base_node)
	
	var color = ShapeType.get_color(shape_type)
	color.a = alpha
	
	match shape_type:
		ShapeType.TRIANGLE:
			_add_triangle(base_node, size, color)
		ShapeType.CIRCLE:
			_add_circle(base_node, size, color)
		ShapeType.SQUARE:
			_add_square(base_node, size, color)
	
	decorative_shapes.append(base_node)

func _add_triangle(parent: Node, size: float, color: Color) -> void:
	var poly = Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2(0, -size/2), Vector2(-size/2, size/2), Vector2(size/2, size/2)])
	poly.color = color
	poly.antialiased = true
	parent.add_child(poly)
	
	var line = Line2D.new()
	line.width = 2.0
	line.default_color = color
	line.antialiased = true
	line.points = PackedVector2Array([Vector2(0, -size/2), Vector2(-size/2, size/2), Vector2(size/2, size/2), Vector2(0, -size/2)])
	parent.add_child(line)

func _add_circle(parent: Node, size: float, color: Color) -> void:
	var points = PackedVector2Array()
	var segments = 32
	for i in range(segments):
		var angle = (i / float(segments)) * TAU
		points.append(Vector2(cos(angle) * size/2, sin(angle) * size/2))
	
	var poly = Polygon2D.new()
	poly.polygon = points
	poly.color = color
	poly.antialiased = true
	parent.add_child(poly)
	
	var line = Line2D.new()
	line.width = 2.0
	line.default_color = color
	line.antialiased = true
	line.points = points
	line.closed = true
	parent.add_child(line)

func _add_square(parent: Node, size: float, color: Color) -> void:
	var h = size/2
	var poly = Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2(-h, -h), Vector2(h, -h), Vector2(h, h), Vector2(-h, h)])
	poly.color = color
	poly.antialiased = true
	parent.add_child(poly)
	
	var line = Line2D.new()
	line.width = 2.0
	line.default_color = color
	line.antialiased = true
	line.points = PackedVector2Array([Vector2(-h, -h), Vector2(h, -h), Vector2(h, h), Vector2(-h, h), Vector2(-h, -h)])
	parent.add_child(line)

func load_scores():
	var save_file_path = "user://falling_game_data.json"
	if FileAccess.file_exists(save_file_path):
		var file = FileAccess.open(save_file_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			var json = JSON.new()
			var error = json.parse(json_string)
			if error == OK:
				var data = json.data
				var high_score = data.get("high_score", 0)
				var last_score = data.get("last_score", 0)
				record_label.text = "Record: %d" % high_score
				last_score_label.text = "Last Score: %d" % last_score
				return
	
	record_label.text = "Record: 0"
	last_score_label.text = "Last Score: 0"

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
