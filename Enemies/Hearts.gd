extends Node2D

const X_OFFSET = 4;
const Y_OFFSET = 4;

const HEART = preload("res://Enemies/Heart.tscn");

export(int) var max_hearts = 3;
export(int) var hearts_per_row = 3;
var hearts = max_hearts;
var rows: int;

var hit_heart_ls = [];


func _ready():
	$"%Heart_Icon".hide(); 
	
	yield(get_parent(), "draw");
#	if !get_parent().hearts['active']: return;
	
	$X_Center.position.y = get_parent().hearts['y_offset'];

	if get_parent().monster.health:
		max_hearts = get_parent().monster.health;
		hearts = max_hearts;
	
	rows = ceil( float(max_hearts) / float(hearts_per_row) );
	
	$X_Center.position.x = float( (hearts_per_row * X_OFFSET) - 1) / -2
	
	reset();


func reset():
	var heart_count = hearts;
	var current_x_offset = 0;
	var current_y_offset = 0;
	
#	$X_Center.position.y -= (rows - 1) * Y_OFFSET;
	
	for i in range(rows):
		current_x_offset = 0;
		for j in range(hearts_per_row):
			create_heart(Vector2(current_x_offset, current_y_offset));
			heart_count -= 1;
			current_x_offset += X_OFFSET;
				
			if heart_count <= 0:
				break;
		current_y_offset -= Y_OFFSET;
	
	scale = Vector2(1,1);


func create_heart(pos: Vector2):
	var h = HEART.instance();
	$X_Center.add_child(h);
	h.add_to_group("No_Flash");
	h.position = pos;


func _on_hit(current_health):
	var health_difference = clamp(-(current_health - hearts), 0, hearts);
	hearts = max(current_health, 0);
	rows = ceil( float(hearts) / float(hearts_per_row) );
	
	var hearts_ls = $X_Center.get_children();
	for i in range(health_difference):
		hit_heart_ls.append( hearts_ls[hearts_ls.size() - (i + 1)] );

	for hit_heart in hit_heart_ls:
		if hit_heart.is_in_group("No_Flash"):
			hit_heart.remove_from_group("No_Flash");
	
	$Sprite_Handler.sprites = get_all_sprites($X_Center);
	$Animation.play("Hit");


func _on_Animation_animation_finished(anim_name):
	if anim_name == "Hit":
		for hit_heart in hit_heart_ls:
			hit_heart.hide();
			hit_heart.queue_free();
		
		hit_heart_ls.clear();


func get_all_sprites(node: Node):
	var sprites = [];
	
	for n in node.get_children():
		if (n is Sprite) and !n.is_in_group("No_Flash"):
			sprites.append(n);
	return sprites;
