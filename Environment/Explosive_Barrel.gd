extends KinematicBody2D

signal destroy(object);

var explode = false;
var invincible = false;
onready var damage = Game_Balance.find_object(Game_Balance.object_data["objects"], "name", "explosive_barrel")["damage"];
onready var stun = Game_Balance.find_object(Game_Balance.object_data["objects"], "name", "explosive_barrel")["stun"];

var state = "idle";
var cart;


func _ready():
	$Sprite.frame = 0;
	$Sprite.show();
	$Sprite/Shadow.show();
	$Explosion_Hitbox/Collision.disabled = true;
	modulate.a = 1;


func _process(delta):
	if !explode && !invincible: hit_detection();
	
	if state == "idle" && !explode:
		check_cart_pickup();
	
	elif state == "carted" && weakref(cart).get_ref() != null:
		global_position = cart.global_position - Vector2(0, 10);
	
	else:
		state = "idle";


func hit_detection():
	for collider in $Hitbox.get_overlapping_areas():
#		if collider.get_parent() != self: print(collider.get_parent().name)
		if collider.is_in_group("Universal_Hitbox") && collider.owner.is_in_group("Explosive_Barrel"):
			Hit_Manager.get_hit_data(self, collider.owner);
			explode(true);

		elif collider.is_in_group("Monster_Hitbox") || collider.is_in_group("Hero_Hitbox") || collider.is_in_group("Projectile_Hitbox") || collider.is_in_group("Universal_Hitbox"):
			Hit_Manager.get_hit_data(self, collider.owner);
			explode();


func explode(fast=false):
	explode = true;

	if fast:
		$Sprite/Animation.play("Explode");
		Global_Camera.shake("explosion");
		Sound_Manager.play_sound("Explosion.wav");
		$Collision.disabled = true;

	else:
		Sound_Manager.play_sound("Sizzle.wav");
		$Sprite/Animation.play("Explosive_Barrel_Windup");


func _on_Animation_animation_finished(anim_name):
	if anim_name == "Explosive_Barrel_Windup":
		$Sprite/Animation.play("Explode");
		Global_Camera.shake("explosion");
		Sound_Manager.play_sound("Explosion.wav", false, "SFX_Quiet");
		$Collision.disabled = true;
		
		if cart != null:
			$Sprite.hide();

	if anim_name == "Explode":
		destroy();


func check_cart_pickup():
	for collider in $Pickup_Hitbox.get_overlapping_areas():
		var object = collider.get_parent();
		
		if object == self || !object.is_in_group("Cart"): return;
		
		elif object.carted_object == null:
			object.carted_object = self;
			carted(object);


func carted(target_cart):
	cart = target_cart;
	state = "carted";
	$Collision.disabled = true;
	invincible = true;
	$Pickup_Hitbox/Invincible_Wait.start();


func _on_Invincible_Wait_timeout():
	invincible = false;


func _on_Animation_animation_started(anim_name):
	if anim_name == "Explode":
		if weakref(cart).get_ref() != null:
			cart = null;
			$Sprite.hide();

		state = "explode";
		if is_in_group("Cartable"):
			remove_from_group("Cartable");


func destroy():
	if cart != null:
		cart.empty_cart();
		hide();
		set_process(false);
		queue_free();
	emit_signal("destroy", self);
