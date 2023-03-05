extends CanvasLayer

export(int) var combo_max_value = 50;
var canvas_modulate;
var tween;


func _ready():
	$UI/Combo_Meter.set_max_value(combo_max_value);
	
	if Level_Handler.get_current_level() == 0:
		$Hero_Health2.hide();
	
	canvas_modulate = CanvasModulate.new();
	get_parent().call_deferred("add_child", canvas_modulate);
	yield(canvas_modulate, "ready");
	
	tween = Tween.new();
	canvas_modulate.call_deferred("add_child", tween);


func _on_Pause_Popup_about_to_show():
	canvas_modulate.color = Color(0.3,0.3,0.3);
	if Level_Handler.get_current_level() < Level_Handler.MAX_LEVELS:
		$UI/CenterContainer/Pause_Popup/Skull_Chest.self_modulate.a = 0.3 + 0.7 * int(Game_Data.unlocked_skull_chests[Level_Handler.get_current_level()])
#	tween.interpolate_property(canvas_modulate, "color", canvas_modulate.color, Color(0.3,0.3,0.3), 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT);
#	tween.start();


func _on_Pause_Popup_popup_hide():
	if tween.is_inside_tree():
		tween.interpolate_property(canvas_modulate, "color", canvas_modulate.color, Color(1,1,1), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN);
		tween.start();
	else:
		canvas_modulate.color = Color(1,1,1);
