extends "../Motion.gd"

var stick_target;
var stick_offset;

func enter():
	owner.get_node("Sprite/Animation").play("Windup 2");
	Sound_Manager.play_sound("Sizzle.wav");
	
	if weakref(owner.stick_target).get_ref() != null:
		stick_target = owner.stick_target;
		stick_offset = get_parent().get_node("Stick").offset;


func update(_delta):
	if weakref(stick_target).get_ref() != null:
		owner.position = stick_target.global_position + stick_offset;


func _on_Animation_animation_finished(anim_name):
	if anim_name == "Windup 2":
		Global_Camera.shake("explosion");
		Sound_Manager.play_sound("Explosion.wav", false, "SFX_Quiet");
		owner.get_node("Sprite/Animation").play("Explode");
		stick_target = null;
		
		owner.emit_signal("die", owner);
		Monster_Vars.monsters.erase(owner);
	
	elif anim_name == "Explode":
		destroy();


func destroy():
#	owner.emit_signal("die", owner);
	owner.queue_free();
