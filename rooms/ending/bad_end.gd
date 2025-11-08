extends Node2D

class_name BadEnd

# Called when the node enters the scene tree for the first time.
const master_string = """The Everyday cycle of hoping and then failing...
You eventually lose your spirit in the infinite loop.
Every day, you try to push yourself hard into it.
Only to get trapped in the cycle further.

Perhaps if you had done [something else] you might have 
reached a different outcome?

You have reached
Merry Bad End.

\\fadeout\\


"""  

var current_dialogue = ""
var pos = 0
var waiting_for_action = false
var scroll_speed = 25.0
@onready var label: RichTextLabel = $dialogue
@onready var nextbutton: TouchScreenButton = $nextbutton

func _ready() -> void:
	label.text = ""
	label.visible_ratio = 0
	next_dialogue()

func do_action(action: String) -> void:
	match action:
		"\\fadeout\\":
			nextbutton.pressable = false
			fade_out()
			
		

func fade_in() -> void:
	var twe = get_tree().create_tween()
	twe.tween_property($fg, "self_modulate:a", 0, 2)
	await twe.finished
	$fg.visible = false


func fade_out() -> void:
	if SaveSystem.load_game()[1] == 0:
		SaveSystem.save_beaten(1)
	get_tree().change_scene_to_file("res://rooms/rm_title/rm_title.tscn")

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
