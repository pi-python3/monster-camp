extends Position2D

var beginning = true;
var arrow_input = false;


func _ready():
	$Sprite.animation = "Arrows";
	position = Vector2(0.5, 0.5);
	hide();
	$Timer.start();


func move(delta):
	var monster_top_pos: Vector2 = Monster_Vars.controlled_monster.global_position - Vector2(0,120);
#	if global_position.distance_to(monster_top_pos) < 10:
#		global_position = monster_top_pos;
#	else:
	var motion: Vector2 = monster_top_pos - global_position;
	global_position += motion * delta * 10;


func _process(delta):
	if weakref(Monster_Vars.controlled_monster).get_ref() == null:
		yield(get_tree().create_timer(0.1),"timeout");
		if weakref(Monster_Vars.controlled_monster).get_ref() == null:
			set_process(false);
			$Sprite/Animation.stop();
			hide();
			return;
	
	move(delta);
	
	match $Sprite.animation:
		"Arrows":
			if get_global_input_direction() != Vector2.ZERO && !arrow_input && $Sprite/Animation.current_animation != "Pop_In" && $Timer.is_stopped():
				arrow_input = true;
				print("arrow change!")
				$Sprite/Animation.play("Pop_Out");
		"Attack":
			if Input.is_action_just_pressed("attack"): $Sprite/Animation.play("Pop_Out");
		"Switch":
			if Input.is_action_just_pressed("switch"): $Sprite/Animation.play("Pop_Out");
	


func get_global_input_direction() -> Vector2:
	var input_dir = Vector2();
	input_dir.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"));
	input_dir.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"));

	return input_dir;


func _on_Animation_animation_finished(anim_name):
	match anim_name:
		"Pop_In":
			$Sprite/Animation.play("Idle");
		"Pop_Out":
			$Timer.start();


func _on_Timer_timeout():
	if !beginning && $Sprite.animation == "Arrows": $Sprite.animation = "Attack";
	elif $Sprite.animation == "Arrows": global_position = Monster_Vars.controlled_monster.global_position - Vector2(0,120);
	elif $Sprite.animation == "Attack": $Sprite.animation = "Switch";
	elif $Sprite.animation == "Switch": $Sprite.animation = "Attack";
	$Sprite/Animation.play("Pop_In");
	show();
	beginning = false;
