extends Node
class_name SaveManager

const SAVE_PATH := "user://save.dat"


func _ready() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		save_game(0, 0, 0)

func save_game(high_score: int, has_beaten_game: int, tasks: int):
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var({
		"high_score": high_score,
		"has_beaten_game": has_beaten_game,
		"tasks": tasks,
	})
	file.close()

func save_beaten(times: int):
	var data = load_game()
	save_game(data[0], times, data[2])

func save_hi_score(score: int):
	var data = load_game()
	save_game(score, data[1], data[2])

func save_tasks(tasks: int):
	var data = load_game()
	save_game(data[0], data[1], tasks)


func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = file.get_var()
	file.close()

	# Keep values in memory
	var high_score = data.get("high_score", 0)
	var has_beaten_game = data.get("has_beaten_game", 0)
	var tasks = data.get("tasks", 0)
	
	return [high_score, has_beaten_game, tasks]
