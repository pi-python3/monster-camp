extends "Hero_State.gd"

signal lose_stamina(amount);

export(float) onready var attack_range = 10;

var input_direction: Vector2;
onready var sprite = owner.get_node("Sprite");
onready var slash_effect = owner.get_node("Sprite/Slash_Effect");
onready var telegraph = owner.get_node("Sprite/Telegraph_Effect");


func _ready():
	attack_range *= owner.scale.x;


func enter():
	var closest_target = find_closest_target();
	if closest_target != null:
		sprite.set_flip(closest_target.global_position.x < owner.global_position.x, false);
	telegraph.get_node("Telegraph_Animation").play("Exclamation");


func slash():
#	sprite.frame = 1;
#	animate();
	var animation = slash_effect.get_node("Slash_Animation");
	animation.play("Front_Slash");
	
	owner.motion = Vector2.ZERO;
	
	Sound_Manager.play_sound("Slash.wav");


func exit():
	slash_effect.get_node("Slash_Animation").stop();
	owner.get_node("Sprite/Slash_Effect/Slash_Hitbox/CollisionShape2D").disabled = true;
	owner.get_node("Sprite/Slash_Effect").visible = false;
	emit_signal("lose_stamina", 1);


func update():
	animate();


func animate():
	if sprite.flip_h:
		slash_effect.offset.x = -8;
	else:
		slash_effect.offset.x = 8;
	
	slash_effect.flip_h = sprite.flip_h


func _on_Cooldown_Timer_timeout():
	if owner.current_state == self: emit_signal("finished", "idle");


func _on_Slash_Animation_animation_finished(_anim_name):
	$Cooldown_Timer.start();


func _on_Telegraph_Animation_animation_finished(_anim_name):
	if owner.current_state.name == self.name:
		slash();
