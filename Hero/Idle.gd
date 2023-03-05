extends "Hero_State.gd"

const IDLE_SHADER = "res://Shaders/Idle.tres";

onready var sprite = owner.get_node("Sprite");
onready var sprite_handler = owner.get_node("Sprite_Handler");


func enter():
	sprite.frame = 0;
	if !owner.invincible: sprite_handler.change_shader(IDLE_SHADER);
	$Attack_Wait.start();


func exit():
	sprite_handler.clear_shader();


func _on_Attack_Wait_timeout():
	if owner.current_state == self:
		emit_signal("finished", "move");
