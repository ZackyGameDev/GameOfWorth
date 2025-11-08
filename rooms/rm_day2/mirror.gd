extends Interactable

var nothing: float = 4.0

func do_action():
	action_in_progress = true
	var reflection = preload("res://rooms/rm_day2/reflection2.tscn").instantiate()
	reflection.global_position = Vector2(0, 0)
	get_parent().add_child(reflection)
	
	# make shift timer
	var tween = get_tree().create_tween()
	tween.tween_property(self, "nothing", 1, 3)
	await tween.finished 
	
	reflection.get_node("frame0").visible = false
	
	tween = get_tree().create_tween()
	tween.tween_property(self, "nothing", 0, 3)
	await tween.finished 
	
	reflection.queue_free()
	action_in_progress = false
	player.controllable = true
	
