extends "../Motion.gd"

export(Dictionary) var attack_animations = {
	'left': Resource,
	'right': Resource
	};

export(String) var sound_effect = 'Slash.wav';
export(float) var DECELERATE = 0.7;

var input_direction: Vector2;
onready var sprite = owner.get_node("Sprite");
onready var slash_effect = owner.get_node("Sprite/Slash_Effect");
onready var slash_animation: AnimationPlayer = owner.get_node("Sprite/Slash_Effect/Slash_Animation");

func _ready():
	slash_animation.add_animation('attack_left', attack_animations['left']);
	slash_animation.add_animation('attack_right', attack_animations['right']);
	
func enter():
	if !owner.can_attack: emit_signal("finished", "idle");
	owner.can_attack = false;
	
	animate();
	attack_animation();
	
	Sound_Manager.play_sound(sound_effect);


func attack_animation():
	if sprite.get_flip():
		slash_animation.play('attack_left');
	else:
		slash_animation.play('attack_right');


func exit():
	owner.get_node("UI").stamina_bar_fill();
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
	if owner.current_state == self:
#	if not owner.current_state.name in ["Hit", "Die"]:
		emit_signal("finished", "idle");


func _on_Slash_Animation_animation_finished(_anim_name):
	$Cooldown_Timer.start();
