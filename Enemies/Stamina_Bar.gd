extends AnimatedSprite

var sprite: AnimatedSprite;
var attack_recharge : float;
var playback_speed: float;


func _ready():
	yield(get_parent(), "ready");
	if not get_parent().stamina_bar['active']: return;
	
	attack_recharge = get_parent().stamina_bar['recharge_time'];

	playback_speed = 2.5 / attack_recharge;
	
	sprite = get_parent().monster.get_node("Sprite");
	sprite.modulate = Color.white;
	hide();
	$Bar_Animation.playback_speed = playback_speed;
	set_process(false);
	
	if !$Bar_Animation.is_connected("animation_finished", self,"_on_Bar_Animation_animation_finished"):
		$Bar_Animation.connect("animation_finished", self,"_on_Bar_Animation_animation_finished");
	if !$Bar_Animation.is_connected("animation_started", self,"_on_Bar_Animation_animation_started"):
		$Bar_Animation.connect("animation_started", self,"_on_Bar_Animation_animation_started");


func fill():
	if not get_parent().stamina_bar['active']: return;
	
	#attack recharge changes here!
	#base stats don't change, just dicitonary entry
	get_parent().stamina_bar['recharge_time'] = get_parent().monster.get_monster_stat(get_parent().monster.monster_type, 'attack_recharge');
	attack_recharge = get_parent().stamina_bar['recharge_time'];

	playback_speed = 2.5 / attack_recharge;
	$Bar_Animation.playback_speed = playback_speed;
	$Bar_Animation.play("Stamina_Fill_Anim");


func _process(_delta):
	if owner.monster.controlled:
		$Bar_Animation.playback_speed = playback_speed * 0.7;
#		modulate = Color.red;
		
	else:
		$Bar_Animation.playback_speed = playback_speed;


func _on_Bar_Animation_animation_finished(anim_name):
	if anim_name == "Stamina_Fill_Anim":
		owner.monster.can_attack = true;
		set_process(false);
		modulate = Color.white;
		hide();
		$Bar_Animation.playback_speed = playback_speed;
		if owner.monster.controlled && owner.monster.health > 0:
			Sound_Manager.play_sound("Stamina_Up.wav");


func _on_Bar_Animation_animation_started(anim_name):
	if anim_name == "Stamina_Fill_Anim":
		set_process(true);
