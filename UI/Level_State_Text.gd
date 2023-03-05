extends CenterContainer

var win_text = "Victory!"
var lose_text = "Camp Wipe!"
var level_state: String;

func _ready():
	$Label.visible = false;
	visible = true;
	Level_Handler.connect("level_over", self, "_on_level_over");


func _on_level_over(state):
	if state == "win":
		$Label.text = win_text;
		$Label.rect_pivot_offset = $Label.rect_size/2;
		$Animation.play("Win_Appear");
	
	else:
		$Label.text = lose_text;
		$Animation.play("Lose_Appear");
	
	level_state = state;


func _on_Animation_animation_finished(_anim_name):
	if level_state == "win":
		if Level_Handler.level == 16:
			Level_Handler.load_home_menu();
		else:
			Level_Handler.next_level();
	else:
		Level_Handler.restart_level();


func fade_in(time := 0.5):
	$Tween2.interpolate_property($Label, "modulate", Color(1,1,1,0), Color(1,1,1,1), time,
	Tween.TRANS_LINEAR, Tween.EASE_IN);
	
	$Tween2.start();


func appear_scale_down(start_value: float = 10, time := 0.3):
	$Label.rect_pivot_offset = Vector2($Label.rect_size.x/2, 0);
	$Label.rect_scale = Vector2(start_value, start_value);
	$Tween.interpolate_property($Label,"rect_scale",$Label.rect_scale,Vector2(1,1),time,
	Tween.TRANS_QUAD, Tween.EASE_IN);
	
	$Tween2.interpolate_property($Label, "modulate", Color(1,1,1,0), Color(1,1,1,1), time,
	Tween.TRANS_QUAD, Tween.EASE_IN);
	
	$Tween.start();
	$Tween2.start();
	
	yield(get_tree().create_timer(time),"timeout");
	Global_Camera.shake('small');
	Sound_Manager.play_sound("Lose_Game_Splat.wav");


func tilt_sideways(degrees: float = 10, time := 0.5):
	$Label.rect_pivot_offset = Vector2(0, $Label.rect_size.y/2);
	$Tween.interpolate_property($Label,"rect_rotation", 0, degrees, time,
	Tween.TRANS_CIRC,Tween.EASE_OUT);
	$Tween.start();


func fall(degrees: float = 90, time := 0.7):
	$Tween.interpolate_property($Label,"rect_rotation", $Label.rect_rotation, degrees, time,
	Tween.TRANS_QUAD,Tween.EASE_IN);
	$Tween2.interpolate_property($Label, "rect_position", $Label.rect_position, Vector2($Label.rect_position.x, 700), time,
	Tween.TRANS_QUAD, Tween.EASE_IN);
	
	$Tween.start();
	$Tween2.start();
	Sound_Manager.play_sound("Lose_Game_Fall.wav");
