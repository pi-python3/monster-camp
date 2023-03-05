extends Node

var game;
const COMBO_POINT = preload("res://UI/Combo/Combo_Point.tscn");


var points := 0;
var combo_buffer = [];
const max_combo_time = 4.0;
var deltatime = max_combo_time;
var combo_num = 0;

func _ready():
	Level_Handler.connect("new_level", self, "_new_level");


func _new_level(_lvl):
	points = 0;
	combo_buffer = [];
	deltatime = max_combo_time;
	combo_num = 0;
	
"""
combo criteria
	-hit hero with monster
		-more damage higher score
		-more speed higher score
	-environment hurts hero
		-highest score given
	-hit environment
"""

func add_hit(target, source, damage, hit_dir):
	var target_type = Hit_Manager.get_damage_type(target);
	var source_type = Hit_Manager.get_damage_type(source);
	var before_deltatime = deltatime;
	var points_added = 0;
	
	if before_deltatime < max_combo_time:
		combo_num += 1;
	else:
		combo_num = 1;
	play_combo_sound();
	
	
	if target_type == "universal": #hitting environment
		deltatime = 0;
	
	elif target_type == "hero":
		deltatime = 0;
		
		var multiplier = 1;
		
		if combo_buffer.size() >= 3: combo_buffer.pop_front();
		if (not source in combo_buffer) && combo_num > 1: multiplier = 1.5; #1.5x boost for new monsters added in combo
		combo_buffer.append(source);
		
		if before_deltatime < max_combo_time:
			for i in range(combo_num-1):
				multiplier *= 1.2; #continuing combo increases each score
		
		multiplier += 1.5 * (1.0 - (before_deltatime / max_combo_time)); #inverse percent of max combo time
		
		if source_type == "universal": multiplier *= 1.5; #environment gets 1.5x boost
		
		points_added = round(multiplier * damage * 5);
		points += points_added;
	
	game = get_tree().root.get_node_or_null('Game');
	if game != null:
		var cp = COMBO_POINT.instance();
		game.add_child(cp);
		cp.appear(points_added, target.position, hit_dir);


func _process(delta):
	if deltatime < max_combo_time:
		deltatime += delta; #seconds passed
		if deltatime > max_combo_time: pass; #TIME!! #print("TIME!");
	else:
		combo_buffer.clear();


const num_to_note = {
	1: "C",
	2: "C#",
	3: "D",
	4: "D#",
	5: "E",
	6: "F",
	7: "F#",
	8: "G",
	9: "G#",
	10: "A",
	11: "A#",
	12: "B",
	13: "C2"
};

func play_combo_sound():
	var note = "";
	if combo_num >= num_to_note.keys().size(): note = "Combo_Hit_" + num_to_note.values().back() + ".wav";
	else: note = "Combo_Hit_" + num_to_note[combo_num] + ".wav";
	
	Sound_Manager.play_sound(note, true);
