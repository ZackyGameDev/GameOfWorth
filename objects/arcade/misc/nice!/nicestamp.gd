extends Node2D
class_name PromptStamp

@export var delay = 1

func _ready() -> void:
	#var sprite = $sprite  # your Sprite2D or TextureRect or Label
	var original_scale = scale
	var original_modulate = modulate
	
	# start invisible and large
	modulate.a = 0.0
	scale = original_scale * 2.0
	
	var tween = create_tween()
	
	tween.tween_property(self, "scale", original_scale, 0.7) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", original_modulate.a, 0.4) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "modulate:a", 0.0, 0.8) \
		.set_delay(delay) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN)
	
	await tween.finished
	queue_free()
