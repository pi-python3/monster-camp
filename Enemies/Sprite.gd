extends AnimatedSprite

var flip setget set_flip, get_flip;
var facing: String;
export(float) var flip_speed = 0.3;
var flip_dir;
var flipping = false;


func set_flip(flip_bool: bool, animate: bool = true):
	if flip_bool:
		if scale.x != -1 && (!flipping || flip_bool != flip):
			if animate: flip_animation(flip_bool);
			else: scale.x = -1;
		
		facing = "left";
	else:
		if scale.x != 1 && (!flipping || flip_bool != flip):
			if animate: flip_animation(flip_bool);
			else: scale.x = 1;
		
		facing = "right";


func get_flip():
	return flip;


func flip():
	set_flip(!get_flip());


func _ready():
	set_process(false);
	flip = false;
	facing = "right";
	flipping = false;


func _process(delta):
	if (flip_dir > 0 && scale.x == 1) || (flip_dir < 0 && scale.x == -1): 
#		print(flip_dir);
#		scale.x = 1;
#		flip_h = flip;
		flipping = false;
		set_process(false);
		return;
	
	scale.x = clamp(scale.x + (flip_dir * delta * 50), -1, 1);


func flip_animation(flip_bool: bool):
	flip = flip_bool;
	
	if flip:
		flip_dir = -flip_speed;
	else:
		flip_dir = flip_speed;
		if scale.x > 0: 
			scale.x *= -1;
		elif scale.x == 0:
			scale.x = -0.1;
#		flip_h = true;
	
	flipping = true;
	set_process(true);
