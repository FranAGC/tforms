extends Node

# Input manager - handles player input from keyboard and touchscreen

signal touch_left
signal touch_right
signal pause_requested

var is_touching_left: bool = false
var is_touching_right: bool = false

func _ready():
	pass

func _input(event: InputEvent):
	# Handle keyboard input for testing
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_A or event.keycode == KEY_LEFT:
			emit_signal("touch_left")
		elif event.keycode == KEY_D or event.keycode == KEY_RIGHT:
			emit_signal("touch_right")
	
	# Handle touch input for Android
	if event is InputEventScreenTouch:
		if event.pressed:
			handle_touch_down(event.position)
	
	if event is InputEventScreenDrag:
		handle_touch_drag(event.position)

func handle_touch_down(position: Vector2):
	var screen_width = get_viewport().get_visible_rect().size.x
	
	# Left half of screen = move left
	if position.x < screen_width / 2:
		emit_signal("touch_left")
		is_touching_left = true
	# Right half = move right
	else:
		emit_signal("touch_right")
		is_touching_right = true

func handle_touch_drag(position: Vector2):
	var screen_width = get_viewport().get_visible_rect().size.x
	
	if position.x < screen_width / 2:
		emit_signal("touch_left")
	else:
		emit_signal("touch_right")
