extends KinematicBody2D

signal destroy(object);

onready var damage = Game_Balance.find_object(Game_Balance.object_data["objects"], "name", "crate")["damage"];

var destroyed = false;
var invincible = false;

export(float) var slide_speed = 50;
export(float) var hit_slide = 350;
export(float) var friction = 0.1;
var motion = Vector2.ZERO;
var slide_motion = Vector2.ZERO;

var carted_object;



func _ready():
	$Sprite.frame = 0;
	$Sprite.show();
	modulate.a = 1;
	$Sprite/Shadow.show();
	$Move_Particles.emitting = false;
	$Slide_Hitbox/CollisionShape2D.disabled = true;
	z_index -= 5;


func _physics_process(delta):
	if !destroyed: 
		push_objects();
		pickup_objects();
		$Sprite.speed_scale = slide_motion.length() / 200.0;
		if !invincible:
			hit_detection();
		if weakref(carted_object).get_ref() != null:
			if weakref(carted_object.cart).get_ref() == null:
				empty_cart();
	


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
		
		elif collider.is_in_group("Universal_Hitbox") && collider.get_parent().is_in_group("Explosion"):
			hit(collider.owner, "explosion");
			return;
		
		elif collider.is_in_group("Universal_Hitbox") && collider.get_parent() != self:
			hit(collider.owner, "universal");
			return;


func hit(source, source_type="monster"):
	var hit_strength = 1;
	
	if source_type == "monster":
		hit_strength = (int(source.get_node("Sprite").get_flip())* (-2) ) + 1
	
	elif source_type == "hero":
		hit_strength = (int(source.get_node("Sprite").get_flip())* (-2) ) + 1
	
	elif source_type == "projectile":
		hit_strength = sign(global_position.x - source.global_position.x);
		if source.shooter.is_in_group("Peapo"):
			source.destroy();
	
	elif source_type == "explosion":
		hit_strength = sign(global_position.x - source.global_position.x);
		break_cart();
	
	else:
		hit_strength = sign(global_position.x - source.global_position.x);
	
	if hit_strength == 0: hit_strength = 1;
	hit_strength *= hit_slide;
	
	Global_Camera.shake("small");
	Global_Camera.freeze_frame("small");
	
	Global_Effects.circle_hit(global_position - Vector2(20,0));
	
#	health -= damage;
	$Sprite/Animation.play("Hit");
	
	slide_motion = Vector2(hit_strength, 0);


func _on_Animation_animation_started(anim_name):
	if anim_name == "Hit":
		invincible = true;
		
		Sound_Manager.play_sound("Hit_Wood.wav");
		$Hit_Particles.emitting = true;


func _on_Animation_animation_finished(anim_name):
	if anim_name == "Hit":
		invincible = false;


func push(direction: Vector2):
	if direction == Vector2.ZERO: return;
	
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
	for collider in $Hitbox.get_overlapping_areas():
		var object = collider.get_parent();
		if object == self: return;
		
		elif object.is_in_group("Pushable") && collider.name == "Projectile_Hitbox":
			if (global_position.y >= object.global_position.y - 20) && (global_position.y < object.global_position.y + 20):
				collider.owner.push(Vector2(slide_motion.x, 0));
			elif (global_position.x >= object.global_position.x - 20) && (global_position.x < object.global_position.x + 20):
				collider.owner.push(Vector2(0, slide_motion.y));


func pickup_objects():
	if carted_object != null: return
	
	for collider in $Pickup_Hitbox.get_overlapping_areas():
		var object = collider.get_parent();
		if object == self: return;
		
		if object.is_in_group("Cartable"):
			
			carted_object = object;
			object.carted(self);


func empty_cart():
	carted_object = null;


func break_cart():
	destroyed = true;
	$Hit_Particles/Particle_Wait.start();
	$Sprite.hide();
	set_process(false);
	$Collision.disabled = true;


func destroy():
	destroyed = true;
	emit_signal("destroy", self);
	
	hide();
	set_process(false);
	queue_free();


func _on_Particle_Wait_timeout():
	destroy();
