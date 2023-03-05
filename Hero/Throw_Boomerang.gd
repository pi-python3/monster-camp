extends "Hero_State.gd"

signal lose_stamina(amount);

export(float) var min_throw_range = 100;
export(float) var max_throw_range = 400;

const BOOMERANG = preload("res://Hero/Boomerang.tscn");

onready var sprite = owner.get_node("Sprite");
var direction = 1;

var target;


func enter():
	sprite.set_flip(owner.position > target.get_ref().position);
	
	var dir = "Right"; direction = 1;
	if sprite.get_flip(): 
		dir = "Left"; 
		direction = -1;
	sprite.get_node("Animation").play("Throw_Boomerang_" + dir);
	
	$Cooldown.start();


func exit():
	emit_signal("lose_stamina", 1);


func spawn_boomerang():
	get_parent().get_sight_and_target();
	
	var b = BOOMERANG.instance();
	owner.get_parent().add_child(b);
	
#	var spawn_pos = owner.global_position.move_toward(target.get_ref().global_position, 5);
	var spawn_pos = Vector2(owner.position.x + (direction * 40), owner.position.y);
	b.throw(spawn_pos, direction, target, owner);
	
	Sound_Manager.play_sound("Throw.wav");


func _on_Animation_animation_finished(anim_name):
	if "Throw_Boomerang" in anim_name:
		emit_signal("finished", "idle");


func _on_Cooldown_timeout():
	pass;
