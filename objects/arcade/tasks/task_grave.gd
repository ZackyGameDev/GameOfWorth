extends Node2D
class_name TaskGrave

'''
The particles MUST have a lifetime less than the tween duration here 
otherwise the particle effect may get cutoff
'''

var displayed_points: int = 0

func _ready() -> void:
	$deathparticles.emitting = true
	
	var label = $points 
	label.text = "+" + str(round(displayed_points)) + "!"
	var start_pos = label.position
	var end_pos = start_pos + Vector2(0, -6)

	var tween = create_tween()
	tween.tween_property(label, "position", end_pos, 3.0) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
	
	await tween.finished
	queue_free()
