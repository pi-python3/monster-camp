extends "../Motion.gd"

var sprite;
var water;


func enter():
	owner = get_parent().owner;
	
	sprite = owner.get_node("Sprite");
	water = owner.get_node_or_null("Water_Effect");
	
	owner.get_node("UI").stamina_bar['active'] = false;
	owner.get_node("UI").hearts['active'] = false;
	
	sprite.get_node("Animation").play("Drown_Anim");
	
	Sound_Manager.play_sound("Drown.wav");
	
	owner.get_node("Collision").disabled = true;
	owner.get_node("Hitbox/Collision").disabled = true;
	
	owner.get_node("Sprite_Handler").no_shader();
	
	if owner.cart != null:
		owner.cart.empty_cart();
		owner.cart = null;


func _on_animation_finished(anim_name):
	if anim_name == "Drown_Anim":
		owner.emit_signal("die", owner);
		
		owner.get_node("Sprite_Handler").no_shader(); #remove idle/move shaders
		owner.get_node("Effects").stop_shadow_animation();
		
		owner.z_index = -10;
		owner.hide();
		
		#tween alpha to fade monster a bit
#		var tween = Tween.new();
#		add_child(tween);
#		tween.interpolate_property(owner, "modulate", Color(1,1,1,1), Color(1,1,1,0.7), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT);
#		tween.start();
		
