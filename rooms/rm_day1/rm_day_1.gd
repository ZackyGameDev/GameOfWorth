extends Node2D

class_name Day1

# Called when the node enters the scene tree for the first time.
const master_string = """\\fadein\\

* It's a new day!

* You feel optimistic... Another day to prove yourself!

* Let's go over to the [RIGHT].

\\work\\

* You sit down, and decide to start the day.

\\fadeout\\


"""  

var current_dialogue = ""
var pos = 0
var waiting_for_action = false
@export var scroll_speed = 25.0
@onready var label: RichTextLabel = $dialogue/label
@onready var nextbutton: TouchScreenButton = $dialogue/nextbutton

var dialogue_focused = true

func _ready() -> void:
	$player.controllable = false
	$fg.visible = true
	label.text = ""
	label.visible_ratio = 1
	next_dialogue()

func do_action(action: String) -> void:
	match action:
		"\\fadein\\":
			fade_in()
			next_dialogue()
		"\\fadeout\\":
			nextbutton.pressable = false
			fade_out()
		"\\work\\":
			work()
		

func fade_in() -> void:
	var twe = get_tree().create_tween()
	twe.tween_property($fg, "self_modulate:a", 0, 2)
	await twe.finished
	$fg.visible = false


func fade_out() -> void:
	$fg.visible = true
	var twe = get_tree().create_tween()
	twe.tween_property($fg, "self_modulate:a", 1,  2)
	await twe.finished
	get_tree().change_scene_to_file("res://rooms/rm_arcade_transition/arcade_transition.tscn")

func work() -> void:
	label.visible_ratio = 0
	$player.controllable = true



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (label.visible_ratio >= 1):
		nextbutton.visible = true
	#else:
		#print("end of the scene.")

func next_dialogue() -> void:
	print("bro think he depression")
	nextbutton.visible = false
	var i = pos
	current_dialogue = ""
	while (!(master_string[i] == '\n' and master_string[i+1] == '\n')) and (i < len(master_string)):
		current_dialogue = current_dialogue + master_string[i]
		i += 1
	pos = i + 2
	print("fin ", current_dialogue)
	
	if current_dialogue[0] == "\\":
		do_action(current_dialogue)
	else:
		label.text = current_dialogue
		label.visible_ratio = 0
		var tween = create_tween()
		tween.tween_property(label, "visible_ratio", 1, len(current_dialogue)*(1/scroll_speed))
		await tween.finished

func _on_nextbutton_button_activated(_data: Variant) -> void:
	next_dialogue()
