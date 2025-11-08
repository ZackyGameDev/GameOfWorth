extends Interactable

func _ready():
	#SaveSystem.save_beaten(1)
	if SaveSystem.load_game()[1] == 0:
		queue_free()
	super()

func do_action():
	player.controllable = false
	var t = get_tree().create_tween()
	t.tween_property($gdfg, "self_modulate", Color(2, 2, 2), 4.5)
	t.parallel().tween_property($gdfg, "self_modulate:a", 1, 4.5)
	await t.finished
	get_tree().change_scene_to_file("res://rooms/ending/good_end.tscn")
	
