extends PopupPanel

onready var hat_mode := Game_Data.hat_mode;


func _process(_delta):
	if Game_Data.hat_mode && !hat_mode:
		hat_mode = true;
		popup();
		hide();
		rect_size = Vector2(960,81);
		set_margin(MARGIN_RIGHT, -80);
		$AnimationPlayer.play("Slide_Down");
		$Timer.start();
		set_process(false);
		
		yield(get_tree().create_timer(0.1),"timeout");
		show();


func _on_Timer_timeout():
	$AnimationPlayer.play_backwards("Slide_Down");


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Slide_Down" && $Timer.is_stopped():
		hide();
