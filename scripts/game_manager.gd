extends Node
class_name GameManager

@export var initial_spawn_interval: float = 2.0
@export var spawn_interval_decrease: float = 0.1
@export var spawn_height: float = -150
@export var max_lives: int = 3

var score_manager: Node
var ui_manager: Node
var player: PlayerShape
var game_over: bool = false
var current_lives: int
var current_score: int = 0

var falling_shapes: Array = []
var falling_shape_scene = preload("res://scenes/falling_item.tscn")

var screen_width: float
var screen_height: float

var flash_rect: ColorRect
var sound_manager: SoundManager

signal game_state_changed
signal score_updated(score: int)
signal lives_updated(lives: int)

func _ready():
	screen_width = get_viewport().get_visible_rect().size.x
	screen_height = get_viewport().get_visible_rect().size.y
	
	score_manager = get_parent().get_node_or_null("HUD/ScoreManager")
	ui_manager = get_parent().get_node_or_null("HUD/UIManager")
	player = get_parent().get_node_or_null("Player")
	
	flash_rect = get_parent().get_node_or_null("HUD/FlashRect")
	sound_manager = get_parent().get_node_or_null("HUD/SoundManager")
	
	current_lives = max_lives
	current_score = 0
	
	if player:
		player.connect("shape_collision", Callable(self, "_on_player_shape_collision"))

func _process(delta: float):
	if game_over:
		return
	
	# Spawn shapes regularly
	spawn_shape()
	
	# Update falling shapes
	update_falling_shapes(delta)

var spawn_timer: float = 0.0

func get_spawn_interval() -> float:
	var steps = current_score / 5
	var interval = initial_spawn_interval - (steps * spawn_interval_decrease)
	return max(0.5, interval)

func get_speed_multiplier() -> float:
	var steps = current_score / 5
	return 1.0 + (steps * 0.1)

func spawn_shape():
	spawn_timer += get_process_delta_time()
	var interval = get_spawn_interval()
	
	if spawn_timer >= interval:
		spawn_timer = 0.0
		
		var shape = falling_shape_scene.instantiate()
		shape.position = Vector2(screen_width / 2, spawn_height)
		shape.fall_speed *= get_speed_multiplier()
		get_parent().add_child(shape)
		falling_shapes.append(shape)
		
		shape.connect("shape_reached_bottom", Callable(self, "_on_shape_reached_bottom"))

func update_falling_shapes(delta: float):
	for i in range(falling_shapes.size() - 1, -1, -1):
		var shape = falling_shapes[i]
		if not is_instance_valid(shape):
			falling_shapes.remove_at(i)

func _on_player_shape_collision(player_shape: int, falling_shape: int):
	if falling_shape == player_shape:
		current_score += 1
		if score_manager:
			score_manager.add_score(1)
		if ui_manager:
			ui_manager.update_score(current_score)
		trigger_match_effect(falling_shape)
	else:
		current_lives -= 1
		if ui_manager:
			ui_manager.update_lives(current_lives)
		trigger_miss_effect()
		
		if current_lives <= 0:
			end_game()

func trigger_match_effect(shape_type: int):
	var color = ShapeType.get_color(shape_type)
	if flash_rect:
		flash_rect.color = Color(color.r, color.g, color.b, 0.3)
		create_tween().tween_property(flash_rect, "color", Color(0, 0, 0, 0), 0.25)
	if sound_manager:
		sound_manager.play_match()

func trigger_miss_effect():
	if flash_rect:
		flash_rect.color = Color(1.0, 0.1, 0.1, 0.3)
		create_tween().tween_property(flash_rect, "color", Color(0, 0, 0, 0), 0.25)
	if sound_manager:
		sound_manager.play_miss()

func _on_shape_reached_bottom(shape_type: int):
	current_lives -= 1
	if ui_manager:
		ui_manager.update_lives(current_lives)
	
	if current_lives <= 0:
		end_game()

func end_game():
	game_over = true
	
	for shape in falling_shapes:
		if is_instance_valid(shape):
			shape.queue_free()
	falling_shapes.clear()
	
	if sound_manager:
		sound_manager.play_game_over()
	
	if score_manager:
		score_manager.save_last_score(current_score)
	
	if ui_manager:
		ui_manager.show_game_over(current_score)

func get_current_score() -> int:
	return current_score

func get_current_lives() -> int:
	return current_lives

func reset_game():
	game_over = false
	current_lives = max_lives
	current_score = 0
	spawn_timer = 0.0
	
	for shape in falling_shapes:
		if is_instance_valid(shape):
			shape.queue_free()
	falling_shapes.clear()
	
	if ui_manager:
		ui_manager.update_score(current_score)
		ui_manager.update_lives(current_lives)
