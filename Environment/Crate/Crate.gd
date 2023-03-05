extends KinematicBody2D

signal destroy(object);

const NAV_POLY = preload("res://Environment/Medium_Nav_Poly.tscn");

onready var damage = Game_Balance.find_object(Game_Balance.object_data["objects"], "name", "crate")["damage"];

var destroyed = false;
export(int) var max_health = 6;
var health = max_health;
var invincible = false;

export(float) var slide_speed = 50;
export(float) var hit_slide = 300;
export(float) var friction = 0.1;
var motion = Vector2.ZERO;
var slide_motion = Vector2.ZERO;

var state = "idle";
var cart;
var can_push = true;


func _ready():
	$Sprite.frame = 0;
	$Sprite.show();
	$Sprite/Shadow.show();
	modulate.a = 1;
	$Move_Particles.emitting = false;
	$Slide_Hitbox/CollisionShape2D.disabled = true;
	
#	var nav_poly = NAV_POLY.instance();
#	get_tree().root.get_node("Game/Navigation2D").add_child(nav_poly);
#	nav_poly.init(self);


func _physics_process(delta):
	if !destroyed: 
		if weakref(cart).get_ref() == null:
			push_objects();
		if !invincible:
			hit_detection();
	
	if slide_motion != Vector2.ZERO:
		move_and_slide(slide_motion);
		slide_motion *= 1.0 - friction;
		if slide_motion.length() <= 0.01:
			slide_motion = Vector2.ZERO;
		
		if slide_motion.length() >= hit_slide * 0.5:
			$Slide_Hitbox/CollisionShape2D.disabled = false;
		else:
			$Slide_Hitbox/CollisionShape2D.disabled = true;
		
	else:
		$Slide_Hitbox/CollisionShape2D.disabled = true;
	
	if state == "idle":
		check_cart_pickup();
	
	elif state == "carted" && weakref(cart).get_ref() != null:
		global_position = cart.global_position - Vector2(0, 10);


func hit_detection():
	for collider in $Projectile_Hitbox.get_overlapping_areas():
		if collider.is_in_group("Projectile_Hitbox"):
			hit(collider.owner, "projectile");
			return;
	
	for collider in $Hitbox.get_overlapping_areas():
		if collider.is_in_group("Monster_Hitbox"):
			hit(collider.owner, "monster");
			return;
		
		if collider.is_in_group("Hero_Hitbox") && !collider.is_in_group("Projectile_Hitbox"):
			hit(collider.owner, "hero");
			return;
		
		elif collider.is_in_group("Universal_Hitbox")&& collider.get_parent() != self:
			hit(collider.owner, "universal");
			return;


func hit(source, source_type="monster"):
	var damage_amount = 0;
	var hit_strength = 1;
	
	if source_type == "monster":
		hit_strength = (int(source.get_node("Sprite").get_flip())* (-2) ) + 1
		#sign(global_position.x - source.position.x);
		
		if source.is_in_group("Boko"): 
			damage_amount = Game_Balance.boko_data['damage'];
		elif source.is_in_group("Skele"):
			damage_amount = Game_Balance.skele_data['damage'];
		elif source.is_in_group("Keesee"):
			damage_amount = Game_Balance.keesee_data['damage'];
	
	elif source_type == "hero":
		hit_strength = (int(source.get_node("Sprite").get_flip())* (-2) ) + 1
		#sign(global_position.x - source.position.x);
		damage_amount = Hero_Vars.sword_damage;
	
	elif source_type == "projectile":
		hit_strength = sign(global_position.x - source.position.x);
		if source.shooter.is_in_group("Peapo"):
			damage_amount = Game_Balance.peapo_data['damage'];
			source.destroy();
		
		elif "Boomerang" in source.name:
			damage_amount = Hero_Vars.boomerang_damage;
	
	else:
		damage_amount = source.damage;
		hit_strength = sign(global_position.x - source.position.x);
	
	if hit_strength == 0: hit_strength = 1;
	hit_strength *= damage_amount * hit_slide;
	
	Global_Camera.shake("small");
	Global_Camera.freeze_frame("small");
	
	Global_Effects.circle_hit(global_position - Vector2(20,0));
	
	health -= damage_amount;
	$Sprite/Animation.play("Hit");
	
	slide_motion = Vector2(hit_strength, 0);


func _on_Animation_animation_started(anim_name):
	invincible = true;
#	set_process(false);
	
	if anim_name == "Hit":
		var health_percent = (float(health) / float(max_health));
		if health <= 0:
			$Hit_Particles2.emitting = true;
		
		if health_percent <= 0.34:
			$Sprite.frame = 2;
			slide_speed = 60;
		elif health_percent <= 0.67:
			$Sprite.frame = 1;
			slide_speed = 50;
		else:
			$Sprite.frame = 0;
			slide_speed = 40;
		
		Sound_Manager.play_sound("Hit_Wood.wav");
		$Hit_Particles.emitting = true;


func _on_Animation_animation_finished(anim_name):
	if anim_name == "Hit":
		if health <= 0:
			break_crate();
		
		invincible = false;


func push(direction: Vector2):
	if direction == Vector2.ZERO || !can_push: return;
	
	motion = direction.normalized();
	slide_motion = motion * slide_speed;
#	move_and_slide(direction.normalized() * slide_speed);
	
	$Move_Particles.emitting = true;
	$Move_Particles.process_material.direction = Vector3(-motion.x, -motion.y, 0);

	$Move_Particles/Push_Wait.start();
	if !$Push_SFX.playing: $Push_SFX.play();


func _on_Push_Wait_timeout():
	$Move_Particles.emitting = false;


func push_objects():
	if !can_push: return;
	
	for collider in $Hitbox.get_overlapping_areas():
		var object = collider.get_parent();
		if object.is_in_group("Pushable") && object != self && collider.name == "Projectile_Hitbox":
			if (global_position.y >= object.global_position.y - 20) && (global_position.y < object.global_position.y + 20):
				collider.owner.push(Vector2(slide_motion.x, 0));
			elif (global_position.x >= object.global_position.x - 20) && (global_position.x < object.global_position.x + 20):
				collider.owner.push(Vector2(0, slide_motion.y));


func check_cart_pickup():
	for collider in $Pickup_Hitbox.get_overlapping_areas():
		var object = collider.get_parent();
		
		if object == self || !object.is_in_group("Cart"): return;
		
		elif object.carted_object == null:
			object.carted_object = self;
			carted(object);


func carted(target_cart):
	can_push = false;
	cart = target_cart;
	state = "carted";
	$Collision.disabled = true;
	invincible = true;
	$Pickup_Hitbox/Invincible_Wait.start();


func _on_Invincible_Wait_timeout():
	invincible = false;


func break_crate():
	state = "idle";
	
	if cart != null:
		cart.empty_cart();
		cart = null;
	
	$Hit_Particles/Particle_Wait.start();
	$Sprite.hide();
	set_process(false);
	$Collision.disabled = true;


func _on_Particle_Wait_timeout():
	destroy();


func destroy():
	emit_signal("destroy", self);
	
	hide();
	set_process(false);
	queue_free();
