extends Node
class_name UIManager

@onready var score_label: Label = get_parent().get_node("ScoreLabel")
@onready var lives_label: Label = get_parent().get_node("LivesLabel")
@onready var game_over_panel: ColorRect = get_parent().get_node("GameOverPanel")
@onready var last_score_label: Label = get_parent().get_node("GameOverPanel/LastScoreLabel")
@onready var restart_button: Button = get_parent().get_node("GameOverPanel/RestartButton")
@onready var menu_button: Button = get_parent().get_node("GameOverPanel/MenuButton")

func _ready():
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	
	update_score(0)
	update_lives(3)
	game_over_panel.hide()

func update_score(score: int):
	score_label.text = "Score: %d" % score

func update_lives(lives: int):
	lives_label.text = "Lives: %s" % ("❤ ".repeat(lives))

func show_game_over(final_score: int):
	last_score_label.text = "Last Score: %d" % final_score
	game_over_panel.show()

func _on_restart_pressed():
	game_over_panel.hide()
	var game_manager = get_parent().get_parent().get_node_or_null("GameManager")
	if game_manager:
		game_manager.reset_game()

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
