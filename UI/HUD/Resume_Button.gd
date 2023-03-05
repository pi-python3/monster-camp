extends TextureButton

const SQUISH = preload("res://Shaders/Squish.tres");
const BIG_SQUISH = preload("res://Shaders/Squish_Big.tres");
onready var pause_popup = owner.get_node_or_null("UI/CenterContainer/Pause_Popup");
#onready var canvas_modulate = owner.get_node_or_null("CanvasModulate");


func _ready():
	$AnimationPlayer.play("Hover");


func _on_Menu_Button_mouse_entered():
	if !disabled:
		Sound_Manager.play_sound_past_pause("Click2.wav");
		material = BIG_SQUISH;


func _on_Menu_Button_mouse_exited():
	material = SQUISH;


func _on_Resume_Button_pressed():
	pause_popup.hide();
