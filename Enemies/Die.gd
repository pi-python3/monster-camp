extends "Motion.gd"

export(int) var DEATH_SPRITE_FRAME = 4;
export(bool) var DROP_WEAPON = false;
export(Texture) var DROP_WEAPON_TEXTURE;

export(float) var LAUNCH_ANGLE = 60;
var LAUNCH_VEC: Vector2;
export(float) var LAUNCH_SPEED = 300;
export(float) var GRAVITY = 75;
export(float) var TURN_SPEED = 1.299;
export(float) var FRICTION = 0.9;

var current_speed: Vector2;
var launch_phase: int = 0;
var bounce_y: float

onready var sprite = owner.get_node("Sprite");
var dead := false;
var hit_dir;

var random = RandomNumberGenerator.new();


func _ready():
#	yield(owner, "ready");
#	sprite.get_node("Animation").add_animation("death_right", DEATH_ANIM_RIGHT);
#	sprite.get_node("Animation").add_animation("death_left", DEATH_ANIM_LEFT);

	random.randomize();

func enter():
	if dead: return
	dead = true;
	
	owner.emit_signal("remove_target_points");
	
	hit_dir = sign(owner.hit_stats['hit_strength'].x);
	
	sprite.playing = false;
	owner.get_node("UI").set_visible(false)
	
	#stop hat animation
	if sprite.get_node_or_null("Hat") != null:
		sprite.get_node("Hat").playing = false;
	
	#play death animation
	death_launch(owner.hit_stats['hit_strength']);
#	if hit_dir == -1:
#		sprite.set_flip(true, true);
#		sprite.get_node("Animation").play("death_left");
#	else:
#		sprite.set_flip(false, true);
#		sprite.get_node("Animation").play("death_right");
	
	#drop weapon
	if DROP_WEAPON:
		var dropped_weapon = Preloads.DEAD_WEAPON_DROP.instance();
		owner.get_parent().add_child(dropped_weapon);
		dropped_weapon.spawn(DROP_WEAPON_TEXTURE, owner.global_position, hit_dir, 1.1);
	
	Sound_Manager.play_sound("Death2.wav");
	
#	owner.get_node("Collision").disabled = true;
	owner.get_node("Hitbox/Collision").disabled = true;
	
	owner.get_node("Sprite_Handler").no_shader();
	
	if owner.cart != null:
		owner.cart.empty_cart();
		owner.cart = null;


func _on_animation_finished(anim_name):
	if anim_name in ["death_left", "death_right"]:
		owner.emit_signal("die", owner);


func clean_up():
	owner.get_node("Collision").disabled = true;
	
	owner.get_node("Sprite_Handler").no_shader(); #remove idle/move shaders
	if owner.get_node_or_null("Shadow") != null:
		owner.get_node("Shadow").stop_animation();
		
	owner.z_index = -10;
		
	#tween alpha to fade monster a bit
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(owner, "modulate", Color(1,1,1,0.7), 0.5);


func death_launch(dir: Vector2 = Vector2.ZERO):
	if sign(dir.x) == -1: sprite.set_flip(true, false);
	else: sprite.set_flip(false, false);
	
#	if dir == Vector2(0,0):
#		LAUNCH_VEC = Vector2(cos(deg2rad(LAUNCH_ANGLE)), -sin(deg2rad(LAUNCH_ANGLE))).normalized();
#	else:
#		LAUNCH_VEC = Vector2(cos(deg2rad(LAUNCH_ANGLE)) * sign(dir.x), -sin(deg2rad(LAUNCH_ANGLE))).normalized();
#		LAUNCH_VEC = (LAUNCH_VEC + dir.normalized());
	
	LAUNCH_VEC = Vector2(cos(deg2rad(LAUNCH_ANGLE)) * sign(dir.x), -sin(deg2rad(LAUNCH_ANGLE))).normalized();
	
	current_speed = LAUNCH_SPEED * LAUNCH_VEC;
	
	sprite.frame = DEATH_SPRITE_FRAME;

	launch_phase = 1;


func update(delta):
	#launch out
	if launch_phase == 1 && current_speed.y < -LAUNCH_VEC.y * LAUNCH_SPEED:
		owner.move_and_slide(current_speed);
		current_speed.y += GRAVITY * 1000 * delta/60;
		
		sprite.rotation_degrees += TURN_SPEED * sign(LAUNCH_VEC.x) * 50000 * delta/60;
	
	#squish when hit ground
	elif launch_phase == 1:
		owner.emit_signal("die", owner);
		launch_phase = 2;
		squish(0.3);
		bounce_y = (LAUNCH_SPEED * LAUNCH_VEC / 4).y;
		current_speed = Vector2(current_speed.x, bounce_y);
	
	#slide on ground
	elif launch_phase == 3 && abs(current_speed.x) > 10:
		if current_speed.y == -bounce_y * 10:
			owner.move_and_slide(Vector2(current_speed.x, 0));
		else:
			owner.move_and_slide(current_speed);
		
		current_speed.x *= FRICTION;
		
		if current_speed.y <= -bounce_y:
			current_speed.y += GRAVITY * 1000 * delta/60;
		else:
			current_speed.y = -bounce_y * 10;
			
	
	#fully die
	elif launch_phase == 3:
		clean_up();
		launch_phase = 4;


func squish(amount: float = 0.3):
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR);
	launch_phase = 3;
	tween.tween_property(sprite, "scale", Vector2((1.0 - amount) * sign(sprite.scale.x), 1.0 + amount), 0.1);
	tween.tween_property(sprite, "scale", Vector2(sign(sprite.scale.x), 1), 0.1);
