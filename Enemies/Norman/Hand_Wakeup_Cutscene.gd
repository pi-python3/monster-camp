extends "../Motion.gd"

const IDLE_SHADER = "res://Shaders/Idle.tres";
const MOVE_SHADER = "res://Shaders/Move.tres";

export(Animation) var ANIMATION;

onready var animation_player = owner.get_node("Sprite/Animation");
onready var sprite_handler = owner.get_node("Sprite_Handler");


func enter():
	sprite_handler.change_shader(IDLE_SHADER);
	
	if ANIMATION != null:
		animation_player.add_animation("wakeup_anim", ANIMATION);
		animation_player.play("move_anim");
		
	
	owner.motion = Vector2.ZERO;
	
	if on_enter['reset_frame']: sprite.frame = 0;
	
	if on_enter['animation'] != '':
		sprite.animation = on_enter['animation'];
		sprite.frame = 0;
		sprite.playing = true;
	
	if on_enter['animate_shadow']:
		owner.get_node("Effects").shadow_grow_shrink();


func exit():
	sprite_handler.clear_shader();
	if on_enter['animation'] != '':
		sprite.playing = false;
	
	return;


func update(delta):
	pass;
