extends KinematicBody2D

signal destroy;
export(String) var state = "closed";
var combo_meter;

func _ready():
	combo_meter = get_parent().owner.get_node_or_null("HUD/UI/Combo_Meter");
	go_to_state("closed");

func _process(_delta):
	if combo_meter == null: return;
	
	elif Combo_Manager.points >= combo_meter.max_value && not state in ["flash", "open"]:
		go_to_state("open");
	
#	if state == "flash" && $Sprite.frame == 6:
#		go_to_state("open");


func go_to_state(st: String):
	state = st;
	
	match st:
		"closed":
			$Sprite.set_animation("Closed");
			$Sprite.playing = false;
			$Sprite/Open_Particles.emitting = false;
		
		"flash":
			$Sprite.set_animation("Flash");
			$Sprite.playing = true;
		
		"open":
			Game_Data.unlock_skull_chest();
			
			$Sprite.set_animation("Open");
			$Sprite.playing = false;
			$Sprite/Open_Particles.emitting = true;
			$Sprite/Open_Star_Particles.emitting = true;
			Sound_Manager.play_sound("Unlock.wav", true);
			Global_Effects.circle_hit(global_position - Vector2(20,0));
			
			yield(get_tree().create_timer(0.5),"timeout");
			Sound_Manager.play_sound("Combo_Complete.wav", true);


func _on_Sprite_animation_finished():
	if $Sprite.animation == "Flash":
		go_to_state("open");
