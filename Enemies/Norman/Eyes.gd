extends Sprite

export(bool) var enabled = true;

const dir_to_frame: Dictionary = {
	'MM': 0,
	'BR': 1,
	'BM': 2,
	'BL': 3,
	'ML': 4,
	'TL': 5,
	'TM': 6,
	'TR': 7,
	'RM': 8
};

var vec_to_dir: Dictionary = {
	Vector2(0,0): 'MM',
	Vector2(1,1).normalized(): 'BR',
	Vector2(0,1): 'BM',
	Vector2(-1,1).normalized(): 'BL',
	Vector2(-1,0): 'ML',
	Vector2(-1,-1).normalized(): 'TL',
	Vector2(0,-1): 'TM',
	Vector2(1,-1).normalized(): 'TR',
	Vector2(1,0): 'RM'
};

onready var sprite = get_parent();


func _ready():
	visible = false;


func _process(_delta):
	visible = enabled;
	self_modulate = Color('ffffff') if owner.controlled else Color('2c132f');
	flip_h = get_parent().flip_h;
	
	if sprite.animation == 'Default' && sprite.frame == 1:
		frame = 9;
	else:
		frame = dir_to_frame[vec_to_dir[get_closest_vector()]];


func get_closest_vector() -> Vector2:
	var hero_pos: Vector2 = Hero_Vars.position;
	var pos: Vector2 = owner.global_position;
	var to_hero_vec: Vector2 = (hero_pos - pos).normalized();
	
	var best_vec: Vector2 = vec_to_dir.keys()[0];
	
	for vector in vec_to_dir.keys():
		if abs(to_hero_vec.dot(vector.normalized()) - 1) < abs(to_hero_vec.dot(best_vec) - 1):
			best_vec = vector;
	
	return best_vec;


func _on_draw():
	if material == Preloads.FLASH_SHADER:
		self_modulate = Color('ffffff');
