extends Node
class_name ScoreManager

signal score_changed(new_score: int)
signal high_score_updated(new_high_score: int)
signal last_score_loaded(last_score: int)

var current_score: int = 0
var high_score: int = 0
var last_score: int = 0
var save_file_path: String = "user://falling_game_data.json"

func _ready():
	load_scores()

func add_score(points: int):
	current_score += points
	emit_signal("score_changed", current_score)

func save_last_score(score: int):
	last_score = score
	
	# Update high score if necessary
	if score > high_score:
		high_score = score
		emit_signal("high_score_updated", high_score)
	
	save_scores()
	emit_signal("last_score_loaded", last_score)

func save_scores():
	var data = {
		"high_score": high_score,
		"last_score": last_score,
		"timestamp": Time.get_ticks_msec()
	}
	
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
		print("Scores saved successfully")
	else:
		print("Error saving scores")

func load_scores():
	if FileAccess.file_exists(save_file_path):
		var file = FileAccess.open(save_file_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			var json = JSON.new()
			var error = json.parse(json_string)
			if error == OK:
				var data = json.data
				high_score = data.get("high_score", 0)
				last_score = data.get("last_score", 0)
				return
	
	high_score = 0
	last_score = 0

func reset_current_score():
	current_score = 0
	emit_signal("score_changed", current_score)

func get_high_score() -> int:
	return high_score

func get_last_score() -> int:
	return last_score

func get_current_score() -> int:
	return current_score
