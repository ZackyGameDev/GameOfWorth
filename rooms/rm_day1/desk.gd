extends Interactable

func do_action():
	player.controllable = false
	action_in_progress = true
	get_parent().next_dialogue()
