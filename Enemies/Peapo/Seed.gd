extends KinematicBody2D

const SEED_BREAK_PARTICLE = preload("res://Enemies/Peapo/Seed_Break_Particles.tscn");

export(float) var speed = 10;
var shooter: KinematicBody2D;
var motion: Vector2 = Vector2.ZERO;
var attack_direction: Vector2;


func _ready():
	set_process(false);


func shoot(_shooter: KinematicBody2D, direction: Vector2):
	shooter = _shooter;
	position = shooter.position - Vector2(0, 1.5*scale.x);
	motion = speed * direction;
	attack_direction = motion.normalized();
	set_process(true);


func _process(delta):
	var collide = move_and_collide(motion * delta);
	if collide:
		if collide.collider is TileMap || collide.collider.is_in_group("Skull_Chest"):
			destroy();


func spawn_break_particle(direction: int):
	var s = SEED_BREAK_PARTICLE.instance();
	get_parent().add_child(s);
	s.position = position;
	s.emit(direction, 5);
	
	Sound_Manager.play_sound("Boomerang_Bounce.wav");


func destroy():
	spawn_break_particle(1);

	set_process(false);
	hide();
	$Hitbox/Collision.disabled = true;
	queue_free();
