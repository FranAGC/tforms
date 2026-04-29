extends Area2D
class_name FallingShape

@export var fall_speed: float = 200.0
@export var shape_size: float = 100.0

var shape_type: int = ShapeType.TRIANGLE
var is_falling: bool = true
var screen_height: float

signal shape_reached_bottom(shape: int)

func _ready():
	add_to_group("falling_shapes")
	area_entered.connect(_on_area_entered)
	
	# Random shape
	shape_type = randi() % 3
	
	# Get screen height
	screen_height = get_viewport().get_visible_rect().size.y
	
	# Setup visual
	setup_visual()

func _process(delta: float):
	if is_falling:
		position.y += fall_speed * delta
		
		# Check if reached bottom
		if position.y > screen_height + 100:
			shape_reached_bottom.emit(shape_type)
			queue_free()

func setup_visual():
	# Clear previous visual children (keep CollisionShape2D)
	for child in get_children():
		if not child is CollisionShape2D:
			child.queue_free()
	
	# Create shape visual
	var shape_node = ShapeRenderer.create_shape_node(shape_type, shape_size)
	add_child(shape_node)
	
	# Setup collision shape
	var collision = $CollisionShape2D
	var col_shape = CircleShape2D.new()
	col_shape.radius = shape_size / 2.5
	collision.shape = col_shape

func _on_area_entered(area: Area2D):
	pass

func get_shape_type() -> int:
	return shape_type
