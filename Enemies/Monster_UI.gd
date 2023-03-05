tool
extends Node2D

export(Dictionary) var stamina_bar = {
	'active': true,
	'visible': true,
	'recharge_time': 2.5,
	'y_offset': 6
	};
	
export(Dictionary) var hearts = {
	'visible': true,
	'hearts_per_row': 3,
	'y_offset': -7
	};

var monster: KinematicBody2D;


func _ready():
	if not Engine.editor_hint:
		scale = Vector2(1,1);
		$Stamina_Bar.position.y = stamina_bar['y_offset'];
		get_parent().connect("hit", self, "_on_hit");
		$Hearts.hearts_per_row = hearts['hearts_per_row'];
		monster = get_parent();
		stamina_bar['recharge_time'] = monster.get_monster_stat(monster.monster_type, 'attack_recharge');
		$Stamina_Bar.attack_recharge = stamina_bar['recharge_time'];


func _process(_delta):
	if Engine.editor_hint:
		$Stamina_Bar.visible = stamina_bar['visible'] && stamina_bar['active'];
		$Hearts/X_Center/Heart_Icon.visible = hearts['visible'];
		$Hearts/X_Center.position.y = hearts['y_offset'];
		
		$Stamina_Bar.position.y = stamina_bar['y_offset'] * 5;
		scale = Vector2(0.25,0.25);
	
	if not Engine.editor_hint:
		if !stamina_bar['visible'] && stamina_bar['active']: $Stamina_Bar.hide();
		if !hearts['visible']: $Hearts.hide();


func _on_hit(current_health):
	$Hearts._on_hit(current_health);


func set_visible(visible: bool):
	for i in get_children():
		i.visible = visible;


func stamina_bar_fill():
	$Stamina_Bar.fill();
