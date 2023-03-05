extends TextureButton

const SQUISH = preload("res://Shaders/Squish.tres");
const BIG_SQUISH = preload("res://Shaders/Squish_Big.tres");

export(int) var level = 1;


func reset(lvl):
	level = lvl;
	$CenterContainer/Label.visible = !disabled;
	$CenterContainer/Label.text = str(level);
	
	if disabled:
		$AnimationPlayer.stop();
		material = null;
	else:
		$AnimationPlayer.play("Hover");
		material = SQUISH;


func _on_Level_Select_Button_pressed():
	Level_Handler.load_level(level - 1);


func _on_Level_Select_Button_focus_entered():
	_on_Level_Select_Button_mouse_entered();


func _on_Level_Select_Button_focus_exited():
	_on_Level_Select_Button_mouse_exited();


func _on_Level_Select_Button_mouse_entered():
	if disabled:
		material = null;
	else:
		Sound_Manager.play_sound("Click2.wav");
		material = BIG_SQUISH;


func _on_Level_Select_Button_mouse_exited():
	if disabled:
		material = null;
	else:
		material = SQUISH;
