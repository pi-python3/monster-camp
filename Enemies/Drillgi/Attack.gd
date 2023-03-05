extends "../Motion.gd"

export(float) var DECELERATE = 0.7;

var input_direction: Vector2;
onready var sprite = owner.get_node("Sprite");
onready var slash_effect = owner.get_node("Sprite/Slash_Effect");

func enter():
	if !owner.can_attack: emit_signal("finished", "idle");
	owner.can_attack = false;
	
	animate();
	slash_effect.get_node("Slash_Animation").play("Slash");

	
	Sound_Manager.play_sound("Slash.wav");



func exit():
#	owner.get_node("Stamina_Bar/Bar_Animation").play("Fill");
	
	return;


func update(delta):
	animate();
	move();


func animate():
	if sprite.flipping:
		sprite.scale.x = clamp(sprite.scale.x + (sprite.flip_dir * 50), -1, 1);
#		sprite.scale.x = clamp(sprite.scale.x * 1000, -1, 1);
#	$Slash_Effect.global_position = sprite.global_position;
#	if sprite.get_flip(): slash_effect.offset.x = -8;
	slash_effect.offset.x = 8;
#	slash_effect.flip_h = sprite.get_flip();

func move():
	owner.motion *= DECELERATE;
	if owner.motion.length() < 0.1: owner.motion = Vector2.ZERO;
	owner.move_and_slide(owner.motion);


func _on_Cooldown_Timer_timeout():
	if owner.current_state == self: pass;
#	if not owner.current_state.name in ["Hit", "Die"]:


func _on_Slash_Animation_animation_finished(_anim_name):
	$Cooldown_Timer.start();
	Global_Effects.circle_hit(owner.position + Vector2(-3,5)*5);
	emit_signal("finished", "burrow");
