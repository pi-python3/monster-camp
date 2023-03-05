extends "res://Scripts/State.gd"

const IDLE_SHADER = "res://Shaders/Idle.tres";
const MOVE_SHADER = "res://Shaders/Move.tres";

export(Animation) var ANIMATION;
export(ShaderMaterial) var SHADER;
export(String) var NEXT_STATE_NAME = 'idle';

onready var animation_player = owner.get_node("Sprite/Animation");
onready var sprite_handler = owner.get_node("Sprite_Handler");


func _ready():
	animation_player.connect('animation_finished', self, "_on_animation_player_finished");


func enter():
	if SHADER != null:
		sprite_handler.change_shader(SHADER);
	
	if ANIMATION != null:
		animation_player.add_animation("wakeup_anim", ANIMATION);
		animation_player.play("wakeup_anim");


func exit():
	sprite_handler.clear_shader();
	return;


func update(delta):
	pass;


func _on_animation_player_finished(anim_name: String):
	if "wake" in anim_name.to_lower():
		emit_signal('finished', NEXT_STATE_NAME);
