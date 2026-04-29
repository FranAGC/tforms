extends Area2D
class_name PlayerShape

@export var shape_size: float = 140.0

var current_shape: int = ShapeType.TRIANGLE
var screen_width: float
var screen_height: float
var input_manager: Node

signal shape_changed(new_shape: int)
signal shape_collision(player_shape: int, falling_shape: int)

func _ready():
	screen_width = get_viewport().get_visible_rect().size.x
	screen_height = get_viewport().get_visible_rect().size.y
	
	position = Vector2(screen_width / 2, screen_height - (screen_height * 0.10))
	
	setup_visual()
	
	input_manager = get_parent().get_node_or_null("InputManager")
	if input_manager:
		input_manager.connect("touch_left", Callable(self, "_on_touch_left"))
		input_manager.connect("touch_right", Callable(self, "_on_touch_right"))
	
	area_entered.connect(_on_area_entered)

func _process(_delta: float):
	# Handle keyboard input
	if Input.is_action_just_pressed("move_left"):
		_on_touch_left()
	elif Input.is_action_just_pressed("move_right"):
		_on_touch_right()

func setup_visual():
	# Clear previous visual children (keep CollisionShape2D)
	for child in get_children():
		if not child is CollisionShape2D:
			child.queue_free()
	
	# Create shape visual
	var shape_node = ShapeRenderer.create_shape_node(current_shape, shape_size)
	add_child(shape_node)
	
	# Setup collision shape
	var collision = $CollisionShape2D
	var col_shape = CircleShape2D.new()
	col_shape.radius = shape_size / 2.5
	collision.shape = col_shape

func _on_touch_left():
	"""Presionar izquierda cambia a la forma anterior en el ciclo"""
	var prev_shape = (current_shape - 1 + 3) % 3
	change_shape(prev_shape)

func _on_touch_right():
	"""Presionar derecha cambia a la siguiente forma en el ciclo"""
	var next_shape = (current_shape + 1) % 3
	change_shape(next_shape)

func change_shape(new_shape: int):
	if current_shape != new_shape:
		current_shape = new_shape
		setup_visual()
		shape_changed.emit(new_shape)

func _on_area_entered(area: Area2D):
	if area.is_in_group("falling_shapes"):
		var falling_shape = area as FallingShape
		if falling_shape:
			shape_collision.emit(current_shape, falling_shape.get_shape_type())
			falling_shape.queue_free()

func get_current_shape() -> int:
	return current_shape
