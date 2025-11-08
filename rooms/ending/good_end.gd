extends Node2D

class_name GoodEnd

# Called when the node enters the scene tree for the first time.
const master_string = """\\fadein\\

You decided to go outside.

You heard the birds chirp, the leaves rustle.

You saw people laughing.

It, somehow makes you think that,

"Maybe theres more to life than proving my worth."

An old epic from ancient times, comes to mind.

"Perhaps..."

"Perhaps the only way to win against a Chakravyuha.."

"Is to not enter it at all..."

        ...You win!
        (Good Ending)

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
		
		"\\fadein\\":
			fade_in()
			next_dialogue()
		
		"\\fadeout\\":
			nextbutton.pressable = false
			fade_out()
			
		

func fade_in() -> void:
	var twe = get_tree().create_tween()
	twe.tween_property($fg, "self_modulate:a", 0, 4.2)
	await twe.finished
	$fg.visible = false


func fade_out() -> void:
	SaveSystem.save_beaten(2)
	nextbutton.pressable = false
	$fg.visible = true
	var twe = get_tree().create_tween()
	twe.tween_property($fg, "self_modulate:a", 1, 3)
	await twe.finished
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
