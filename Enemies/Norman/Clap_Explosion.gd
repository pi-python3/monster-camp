extends Node2D

var left_hand: KinematicBody2D;
var right_hand: KinematicBody2D;


func _ready():
	right_hand = get_parent().find_node("*Right");
	left_hand = get_parent().find_node("*Left");


func spawn(spawn_pos: Vector2):
	global_position = spawn_pos;
	$Animation.play("Explode");


func _process(_delta):
	global_position = (left_hand.global_position + right_hand.global_position) * 0.5


func _on_Animation_animation_finished(anim_name):
	if anim_name == "Explode":
		queue_free();
