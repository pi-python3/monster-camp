extends KinematicBody2D

const SEED_BREAK_PARTICLE = preload("res://Enemies/Peapo/Seed_Break_Particles.tscn");

export(float) var speed = 10;
export(float) var steer_strength = 1;
var shooter: KinematicBody2D;
var motion := Vector2.ZERO;
var attack_direction := Vector2.ZERO;
var seek_pos = null;


func _ready():
	set_process(false);


func shoot(_shooter: KinematicBody2D, direction: Vector2):
	shooter = _shooter;
	motion = speed * direction;
	attack_direction = motion.normalized();
	if Hero_Vars.position != Vector2.ZERO:
		seek_pos = Hero_Vars.position;
	set_process(true);


func _process(delta):
	$Sprite.rotation_degrees += delta * 200;
	steer_strength = clamp(steer_strength + (delta*100), 1, 50);
	
	if seek_pos != null:
		seek_pos = Hero_Vars.position;
		motion = steer(seek_pos - global_position, motion, steer_strength);
		motion = set_length(motion, speed);
	
	var collide = move_and_collide(motion * delta);
	if collide:
		if collide.collider is TileMap: destroy();


func steer(desired_motion: Vector2, current_motion: Vector2, steer_strength: float) -> Vector2:
	var steer = desired_motion - current_motion;
	steer = steer.clamped(steer_strength);
	return current_motion + steer;


func seek(hero_position: Vector2, target_position: Vector2, move_speed: float) -> Vector2:
	var desired = target_position - hero_position;
	desired = set_length(desired, move_speed);
	return desired;


func set_length(vector: Vector2, length: float) -> Vector2:
	return vector.normalized() * length;


func destroy():
	$Animation.play("Explode");

	set_process(false);
	$Hitbox/Collision.disabled = true;


func _on_Animation_animation_finished(anim_name):
	if anim_name == "Explode":
		queue_free();
