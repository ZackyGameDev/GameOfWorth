extends Node2D

class_name Cutscene1Dialog

# Called when the node enters the scene tree for the first time.
const master_string = """\\fadein\\

\\image1\\

* In ancient India, there were once two major epics written in Sanskrit.

* One of these was a war epic named, "Mahabharata"

* In it, there is described a unique battle formation.

* It is called, "Chakravyuha"

\\image2\\

* It is said to be a unique spiral like formation

* Enemy trying to break into it, would always find itself trapped further

* With the outside soldiers closing in the further the enemy got.

* Truly, a most effective trap.

\\fadeout\\


"""  

var current_dialogue = ""
var pos = 0
var waiting_for_action = false
var scroll_speed = 25.0
@onready var label: RichTextLabel = $dialogue
@onready var nextbutton: TouchScreenButton = $nextbutton

func _ready() -> void:
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
		"\\image1\\":
			image1()
			next_dialogue()
		"\\image2\\":
			image2()
			next_dialogue()
			
		

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
	get_tree().change_scene_to_file("res://rooms/rm_day1/rm_day1.tscn")

func image1() -> void: 
	var twe = get_tree().create_tween()
	twe.tween_property($warriors, "self_modulate:a", 1,  4)

func image2() -> void :
	var twe = get_tree().create_tween()
	twe.tween_property($warriors, "self_modulate:a", 0,  2)
	twe.chain().tween_property($chakra, "self_modulate:a", 1, 4)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (label.visible_ratio >= 1):
		nextbutton.visible = true
	#else:
		#print("end of the scene.")

func next_dialogue() -> void:
	print("bro think he")
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
		tween.tween_property(label, "visible_ratio", 1, len(current_dialogue)*(1/25.0))
		await tween.finished



func _on_nextbutton_button_activated(_data: Variant) -> void:
	next_dialogue()
