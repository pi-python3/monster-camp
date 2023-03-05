extends Node

var position = Vector2.ZERO;
var max_health;
var health;
var facing;
var sword_damage;
#var has_bow;
#var bow_damage;
var boomerang_damage;
var boomerang_in_hand;
var max_stamina;
var stamina = max_stamina;
var revenge_target;

func _ready():
	Level_Handler.connect("new_level", self, '_on_new_level');
	_on_new_level(1);


func _on_new_level(level):
	if level == 0: return;
	
	position = Vector2.ZERO;
	
	max_health = Game_Balance.get_hero_stats(level)['health'];
	health = max_health;
	
	facing = "right";
	
	sword_damage = Game_Balance.get_equipment('sword', level)['damage'];
	
#	var bow = Game_Balance.get_equipment('bow', level);
#	has_bow = bow != null;
#	if has_bow: bow_damage = bow['damage'];
	
	var boomerang = Game_Balance.get_equipment('boomerang', level);
	if boomerang: 
		boomerang_damage = boomerang['damage'];
		boomerang_in_hand = true;
	else:
		boomerang_in_hand = false;
	
	
	max_stamina = Game_Balance.get_hero_stats(level)['stamina'];
	stamina = max_stamina;
	
	revenge_target = null;


func _process(_delta):
	if weakref(revenge_target).get_ref() == null:
		revenge_target = null;
