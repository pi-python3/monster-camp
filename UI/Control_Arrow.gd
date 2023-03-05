extends Position2D

var changing = false;
export(float) var y_offset = 50;
export(float) var tween_time = 0.5;
var wait = 0;
var weak_controlled_monster;

func _ready():
	Monster_Vars.connect("change_monster", self, "_change_monster");
	$AnimationPlayer.play("Hover");
	
	wait = 0;


func _process(delta):
	$CanvasLayer/Sprite.global_position = global_position;
	
	wait += 1;
	if wait < 5: 
		return;
	
	weak_controlled_monster = weakref(Monster_Vars.controlled_monster);
	
	if weak_controlled_monster.get_ref() != null:
		if !changing:
			position = Monster_Vars.controlled_monster.global_position + Vector2(0,-y_offset);
	else:
		visible = false;
	
	if Monster_Vars.lose_game: 
		return;
		visible = false;
	
	if weak_controlled_monster.get_ref() != null: visible = true;
	
	if !changing && Monster_Vars.monsters.size() > 0 && weak_controlled_monster.get_ref() != null:
		position = Monster_Vars.controlled_monster.global_position + Vector2(0,-y_offset);

	if changing: 
		$Switch_Trail_Particles.emitting = true;
		$Switch_Trail_Particles/Trail.visible = true;
	
	else:
		$Switch_Trail_Particles.emitting = false;
		$Switch_Trail_Particles/Trail.visible = false;
		$Switch_Trail_Particles/Trail.clear_points();


func _change_monster():
	if Monster_Vars.lose_game: return;
	
	changing = true;
	
	y_offset = 50;
	if Monster_Vars.controlled_monster.is_in_group('Skele'):
		y_offset = 60;
	
	$Tween.interpolate_property(
		self, "position", 
		position,Monster_Vars.controlled_monster.global_position + Vector2(0,-y_offset),
		tween_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
	);
	$Tween.start();
	
	var dir = (Monster_Vars.controlled_monster.global_position - $Switch_Trail_Particles.global_position).normalized();
	$Switch_Trail_Particles.process_material.set_direction(Vector3(dir.x, dir.y, 0));
	$Trail_Tween.interpolate_property(
		$Switch_Trail_Particles, "global_position", 
		$Switch_Trail_Particles.global_position, Monster_Vars.controlled_monster.global_position + Monster_Vars.controlled_monster.motion*5,
		tween_time, Tween.TRANS_CUBIC
	);
	$Trail_Tween.start();
	
	Sound_Manager.play_sound("Switch4.wav");


func _on_Tween_tween_all_completed():
	changing = false;
