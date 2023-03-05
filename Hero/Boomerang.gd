extends KinematicBody2D

const equipment_name = "boomerang";

export(float) var steer_strength = 50;
export(float) var speed = 300;
var motion := Vector2.ZERO;
var attack_direction: Vector2;
export(int) var life_points_max = 300;
onready var life_points = life_points_max;
var dead = false;

var target;
var hit_target = false;
var shooter = null;


func _ready():
	$Animation.play("Spin");
	modulate.a = 1;


func throw(pos, direction, throw_target, shooter):
	position = pos;
	motion.x = sign(direction) * speed;
	attack_direction = motion.normalized();
	target = throw_target;
	self.shooter = shooter;
	
	Hero_Vars.boomerang_in_hand = false;


func _process(delta):
	check_life_points();
	if !dead: move(delta);
	else: move_to_hero();


func move(delta):
	var desired;
	
	if target.get_ref():
		desired = desired_motion(position, target.get_ref().position);
	
	else:
		desired = desired_motion(position, find_closest_monster().position);

	
	motion = steer(desired, motion) * speed;
	attack_direction = motion.normalized();
	var collide = move_and_collide(motion * delta);
	
	if collide: collision(collide);


func move_to_hero():
	var desired = desired_motion(position, Hero_Vars.position);
	motion = steer(desired, motion) * speed;
	move_and_slide(motion);


func desired_motion(from_pos: Vector2, to_pos: Vector2):
	return to_pos - from_pos;


func steer(desired_motion: Vector2, current_motion: Vector2) -> Vector2:
	var steer = desired_motion - current_motion;
	steer = steer.clamped(self.steer_strength);
	var steer_motion = current_motion + steer;
	return steer_motion.normalized();


func find_closest_monster():
	var min_distance = 999999999;
	var close_monster;
	
	for monster in Monster_Vars.monsters:
		var dis = position.distance_to(monster.position)
		if dis < min_distance: 
			min_distance = dis;
			close_monster = monster;
	
	return close_monster;


func collision(_collide):
	motion *= -1;
	life_points -= 50;
	
	Sound_Manager.play_sound("Boomerang_Bounce.wav");


func check_life_points():
	if find_closest_monster() == null: life_points = 0;
	
	if life_points <= 0:
		$Hitbox/Collision.disabled = true;
		$Collision.disabled = true;
		dead = true;
		modulate.a = 0.5;


func _on_Flying_Time_timeout():
	life_points -= 10;


func _on_Hitbox_area_entered(area):
	if area.is_in_group("Monster_Hitbox") || area.is_in_group("Projectile_Hitbox"):
		motion *= -1;
		life_points -= 100;
		hit_target = true;
		
		Sound_Manager.play_sound("Boomerang_Bounce.wav");
	
	elif area.owner.is_in_group("Monster"):
		collision(area.owner);
		hit_target = true;


func _on_Search_Area_body_entered(body):
	if life_points > life_points_max * 0.9: return;
	
	if body.name == "Hero":
		Sound_Manager.play_sound("Boomerang_Bounce.wav");
		put_in_hand();


func destroy():
	life_points = 0;


func put_in_hand():
	Hero_Vars.boomerang_in_hand = true;
		
	Sound_Manager.play_sound("Boomerang_Bounce.wav");
		
	hide();
	set_process(false);
	queue_free();
