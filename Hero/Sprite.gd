extends AnimatedSprite

var flip setget set_flip, get_flip;
var facing: String;
export(float) var flip_speed = 0.3;
var flip_dir;
var flipping = false;

#var original_scale;
#const pulse_time = 0.3;
#var tween_done = false;

#func set_flip(flip_bool: bool):
#	if flip_bool:
#		if (!flipping || flip_bool != flip):
#			flip_animation(flip_bool);
#
#		facing = "left";
#	else:
#		if (!flipping || flip_bool != flip):
#			flip_animation(flip_bool);
#
#		facing = "right";
#
#	Hero_Vars.facing = facing;


#func get_flip():
#	return flip;


#func _ready():
#	set_process(false);
#	flipping = false;
#	facing = "right";
#	Hero_Vars.facing = facing;
#	flipping = false;


#func _process(delta):
##	if Hero_Vars.health <= 0: return;
#
#	if (flip_dir > 0 && scale.x == 1) || (flip_dir < 0 && scale.x == -1): 
##		scale.x = 1;
##		flip_h = flip;
#		flipping = false;
#		set_process(false);
#		print('flip done: ' + str(scale.x))
#		return;
#
#	scale.x = clamp(scale.x + (flip_dir * delta * 50.0), -1.0, 1.0);


#func flip_animation(flip_bool: bool):
#	flip = flip_bool;
#	flip_h = flip;
#	return;
#
#	if flip:
#		flip_dir = -flip_speed;
#	else:
#		flip_dir = flip_speed;
#		if scale.x > 0: 
#			scale.x *= -1;
#		elif scale.x == 0:
#			scale.x = -0.1;
##		flip_h = true;
#
#	flipping = true;
#	set_process(true);


func _ready():
	set_process(false);
	flipping = false;
	facing = "right";
	Hero_Vars.facing = facing;


func _physics_process(_delta):
	if not owner.current_state.name in ["Throw_Boomerang"]:
		if Hero_Vars.sword_damage == 1:
			set_animation("Weak");
		elif Hero_Vars.sword_damage == 2:
			set_animation("Medium");
		elif Hero_Vars.sword_damage == 3:
			set_animation("Strong");


func _process(delta):
	if Hero_Vars.health <= 0: return;
	
	
	
	if (flip_dir > 0 && scale.x == 1) || (flip_dir < 0 && scale.x == -1): 
		scale.x = 1;
		flip_h = flip;
		flipping = false;
		set_process(false);
		return;
	
	scale.x = clamp(scale.x + flip_dir, -1, 1);


func set_flip(flip_bool: bool, animate := true):
	if animate:
		if flip_bool:
			if !flip_h && (!flipping || flip_bool != flip):
				flip_animation(flip_bool);
			facing = "left";
		else:
			if flip_h && (!flipping || flip_bool != flip):
				flip_animation(flip_bool);
			facing = "right";
	else:
		scale.x = 1;
		flip_h = flip_bool;
		if flip_bool: facing = "left";
		else: facing = "right";
	
	Hero_Vars.facing = facing;
	flip = flip_bool;


func flip_animation(flip_bool: bool):
	flip = flip_bool;
	
	if flip:
		flip_dir = -flip_speed;
	else:
		flip_dir = flip_speed;
#		flip_h = true;
		if scale.x > 0: 
			scale.x *= -1;
		elif scale.x == 0:
			scale.x = -0.1;
	
	flipping = true;
	set_process(true);


func get_flip():
	return flip;



#func pulse():
#	return;
#
#	if $Tween.is_active():
#		$Tween.stop_all();
#		scale = original_scale;
#
#	tween_done = false;
#	original_scale = scale;
#	$Tween.interpolate_property(self, "scale", scale, scale * 1.3,
#	pulse_time/2, Tween.TRANS_LINEAR,Tween.EASE_IN);
#	$Tween.start();
#
#
#func _on_Tween_tween_all_completed():
#	if !tween_done:
#		tween_done = true;
#		$Tween.interpolate_property(self, "scale", scale, original_scale,
#		pulse_time/2, Tween.TRANS_BACK,Tween.EASE_OUT);
#		$Tween.start();
