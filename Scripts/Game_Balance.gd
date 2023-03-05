extends Node

var monsters; 
var hero_data; var equipment_data; var object_data
var monster_data = {};

func _enter_tree():
	monsters = parse_JSON("Game_Balance_Monsters.json");
	for m in get_monster_names(monsters['monsters']):
		monster_data[m] = find_object(monsters['monsters'], 'name', m);

	hero_data = parse_JSON("Game_Balance_Hero_Stats.json");
	equipment_data = parse_JSON("Game_Balance_Hero_Equipment.json");
	object_data = parse_JSON("Game_Balance_Environment.json");


func parse_JSON(file_name: String):
	var file = File.new();
	file.open("res://Resources/" + file_name, file.READ);
	var text = file.get_as_text();
	var dict = JSON.parse(text).result;
	file.close();
	return dict;


func get_monster_names(array: Array):
	var return_array = [];
	for dic in array:
		return_array.append( dic['name'] );
	return return_array;


func find_object(array: Array, key: String, value):
	for object in array:
		if object[key] is Array:
				if value in object[key]: return object;
		
		elif object[key] == value: return object;
	return null;

func find_object_in_level(array: Array, key1: String, value1, level):
	for object in array:
		if object[key1] == value1 && level in object['level']: return object;
	return null;


func get_hero_stats(level: int):
	var stats = {'health':0, 'stamina':0};
	stats['health'] = find_object(hero_data['health'], 'level', level)['health'];
	stats['stamina'] = find_object(hero_data['stamina'], 'level', level)['stamina'];
	
	return stats;


func get_equipment(equipment_name: String, level: int):
	return find_object_in_level(equipment_data['equipment'], 'name', equipment_name, level);
