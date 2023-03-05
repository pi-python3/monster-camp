extends "Hero_State.gd"

onready var sprite = owner.get_node("Sprite");


func enter():
	sprite.set_flip(sprite.get_flip(), false);
	
	if sprite.get_flip():
		sprite.get_node("Animation").play("Stun_Left");
	else:
		sprite.get_node("Animation").play("Stun_Right");
	
	Sound_Manager.play_sound("Stun.wav");


func exit():
	owner.get_node("Sprite/Animation").stop();
	owner.get_node("Sprite").rotation_degrees = 0;
	owner.get_node("Sprite").position = Vector2.ZERO;
	owner.get_node("Stun_Stars").visible = false;


func _on_Animation_animation_finished(anim_name):
	if "Stun" in anim_name:
		emit_signal("finished", "move");
