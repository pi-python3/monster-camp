extends Position2D

export(float) var LAUNCH_LENGTH = 1.0;
export(float) var LAUNCH_HEIGHT = 1.0;
export(Curve) var LAUNCH_CURVE;
export(int) var X_DIR = 1;
export(float) var TURN_SPEED = 1.0;

var interpolate := 0.0;
var spawn_position;

var random = RandomNumberGenerator.new();


func _enter_tree():
	set_process(false);
	random.randomize();


func spawn(texture: Texture, spawn_pos: Vector2, dir: int = 1, length: float = 1.0, height: float = 1.0):
	$Sprite.texture = texture;
	
	spawn_position = spawn_pos;
	global_position = spawn_position;
	
	X_DIR = sign(dir);
	$Sprite.flip_h = (X_DIR == -1); #flip if direction left
	
	LAUNCH_LENGTH = length;
	LAUNCH_HEIGHT = height;
	
	LAUNCH_LENGTH += random.randf_range(0, LAUNCH_LENGTH / 4);
	LAUNCH_HEIGHT += random.randf_range(-LAUNCH_HEIGHT/4, LAUNCH_HEIGHT / 4);
	
	TURN_SPEED += random.randf_range(-TURN_SPEED/4, TURN_SPEED / 4);
	
	interpolate = 0.0;
	set_process(true)


func _process(delta):
	if interpolate >= 1.0:
		$Fade_Wait.start();
		set_process(false);
	
	else:
		global_position.x = spawn_position.x + (LAUNCH_LENGTH * X_DIR * 100 * interpolate);
		global_position.y = spawn_position.y - (LAUNCH_HEIGHT * 50 * LAUNCH_CURVE.interpolate(interpolate));
		$Shadow.global_position.y = spawn_position.y;
		interpolate += 100.0 * delta/60;
		$Sprite.rotation_degrees += X_DIR * TURN_SPEED * 60000 * delta/60;


func _on_Fade_Wait_timeout():
	#tween alpha to fade weapon a bit
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT);
	tween.tween_property(self, "modulate", Color(1,1,1,0.7), 0.5);
	tween.parallel().tween_property($Shadow, "modulate", Color(1,1,1,0.3), 0.5);
