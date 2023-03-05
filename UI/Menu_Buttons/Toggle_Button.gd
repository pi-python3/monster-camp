extends TextureButton

const SQUISH = preload("res://Shaders/Squish.tres");
const BIG_SQUISH = preload("res://Shaders/Squish_Big.tres");
onready var options_popup = owner.get_node_or_null("CanvasLayer/UI/CenterContainer2/Options_Popup");
onready var canvas_modulate = owner.get_node_or_null("CanvasModulate");

enum Type {
	SFX = 0,
	MUSIC = 1,
	HAT = 2,
	MOBILE = 3
};

export(Type) var type;
export(bool) var sparkle = false;

export(Texture) var on_hover_texture;
export(Texture) var off_hover_texture;
onready var pressed_texture = texture_pressed;


func _ready():
	match type:
		Type.SFX:
			set_pressed_no_signal(Sound_Manager.muted);
		Type.MUSIC:
			set_pressed_no_signal(Sound_Manager.music_muted);
		Type.HAT:
			visible = Game_Data.can_hat_mode;
			set_pressed_no_signal(!Game_Data.hat_mode);
		Type.MOBILE:
			set_pressed_no_signal(!Game_Data.mobile_buttons);
	
	
	$AnimationPlayer.play("Hover");
	
	$Sparkle.hide();
	if sparkle:
		$Sparkle.playing = false;
		yield(get_tree().create_timer(randf()*4.0),"timeout");
		$Sparkle.playing = true;
		$Sparkle.visible = true;


func _on_Toggle_Button_mouse_entered():
	if !disabled:
		Sound_Manager.play_sound_past_pause("Click2.wav");
		material = BIG_SQUISH;


func _on_Toggle_Button_mouse_exited():
	material = SQUISH;


#func _on_Toggle_Button_focus_entered():
#	_on_Toggle_Button_mouse_entered();
#
#
#func _on_Toggle_Button_focus_exited():
#	_on_Toggle_Button_mouse_exited();


func _on_Toggle_Button_pressed():
	match type:
		Type.SFX:
			Sound_Manager.muted = !Sound_Manager.muted;
			AudioServer.set_bus_mute(1, Sound_Manager.muted);
			AudioServer.set_bus_mute(2, Sound_Manager.muted);
		
		Type.MUSIC:
			Sound_Manager.set_music_muted(!Sound_Manager.music_muted);
		
		Type.HAT:
			if Game_Data.can_hat_mode: Game_Data.hat_mode = !Game_Data.hat_mode;
		
		Type.MOBILE:
			Game_Data.mobile_buttons = !Game_Data.mobile_buttons;
			
			if Game_Data.mobile_buttons:
				InputMap.action_erase_event("attack", click_event);
				print(InputMap.get_action_list("attack"));
			else:
				InputMap.action_add_event("attack", click_event);
				print(InputMap.get_action_list("attack"));

var click_event;
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == BUTTON_LEFT:
			click_event = event;


func _process(_delta):
	if is_hovered():
		if is_pressed():
			texture_pressed = off_hover_texture;
		else:
			texture_pressed = on_hover_texture;
	else:
		if is_pressed():
			texture_pressed = pressed_texture;
#		else:
#			texture_pressed = pressed_texture;
#func _input(event : InputEvent) -> void:
#	if is_hovered() and event is InputEventMouseButton:
#		print("hover!")
