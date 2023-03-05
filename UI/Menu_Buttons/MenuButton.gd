extends TextureButton

const SQUISH = preload("res://Shaders/Squish.tres");
const BIG_SQUISH = preload("res://Shaders/Squish_Big.tres");
onready var options_popup = owner.get_node_or_null("CanvasLayer/UI/Options_Center_Container/Options_Popup");
onready var canvas_modulate = owner.get_node_or_null("CanvasModulate");

enum Type {
	PLAY = 0,
	OPTIONS = 1,
	BACK = 2,
	HOME = 3,
	RESTART = 4,
	FEEDBACK = 5,
};

export(Type) var type;
export(bool) var sparkle = false;

func _ready():
	$AnimationPlayer.play("Hover");
	
	$Sparkle.hide();
	if sparkle:
		$Sparkle.playing = false;
		$Sparkle_Wait.wait_time = randf()*4.0;
		$Sparkle_Wait.start();


func _process(_delta):
	if not type in [Type.PLAY, Type.OPTIONS]:
		set_process(false);
		return;
	
	var options_popup = owner.get_node_or_null("CanvasLayer/UI/Options_Center_Container/Options_Popup");
	if options_popup != null:
		visible = !options_popup.visible;


func _on_Menu_Button_mouse_entered():
	if !disabled:
		Sound_Manager.play_sound("Click2.wav");
		material = BIG_SQUISH;


func _on_Menu_Button_mouse_exited():
	material = SQUISH;


func _on_Menu_Button_focus_entered():
	_on_Menu_Button_mouse_entered();


func _on_Menu_Button_focus_exited():
	_on_Menu_Button_mouse_exited();


func _on_Menu_Button_pressed():
	match type:
		Type.PLAY:
			Level_Handler.load_level_select_menu();
		
		Type.OPTIONS:
			$Tween.interpolate_property(canvas_modulate, "color", canvas_modulate.color, Color(0.3,0.3,0.3), 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT);
			$Tween.start();
			options_popup.popup();
		
		Type.BACK:
			Level_Handler.load_home_menu();
		
		Type.HOME:
			Level_Handler.load_home_menu();
		
		Type.RESTART:
			Level_Handler.restart_level();
		
		Type.FEEDBACK:
			OS.shell_open("https://forms.gle/rGogpB33kCTDJNn1A");


func _on_Options_Popup_popup_hide():
	$Tween.interpolate_property(canvas_modulate, "color", canvas_modulate.color, Color(1,1,1), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN);
	$Tween.start();


func _on_Sparkle_Wait_timeout():
	$Sparkle.playing = true;
	$Sparkle.visible = true;
