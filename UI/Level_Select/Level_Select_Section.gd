extends Control

const MONSTER_COUNTER = preload("res://UI/Level_Select/Monster_Counter.tscn");

export(int) var level = 1;
var chest_unlocked := false;
var locked := true;

var monster_count = {
	"boko": 0,
	"skele": 0,
	"keesee": 0,
	"peapo": 0,
	"bombo": 0
};

const object_name = {
	0: "boko",
	1: "skele",
	2: "keesee",
	3: "peapo",
	4: "bombo"
};


func _ready():
	locked = level - 1 > Game_Data.current_unlocked_level;
	if locked: $Level_Select_Button.disabled = true;
	$Level_Select_Button.reset(level);
	
	if level > Level_Handler.MAX_LEVELS:
		$Skull_Chest.hide();
	
	if Game_Data.unlocked_skull_chests.values().size() > level-1:
		chest_unlocked = Game_Data.unlocked_skull_chests[level-1];
		if !chest_unlocked: $Skull_Chest.modulate.a = 0.5;
	
	
	
#	lvl_load = load("res://Main_Scenes/Level_" + str(level) + ".tscn").instance();
#	add_child(lvl_load);
#	monster_tiles = lvl_load.get_node("Environment/Monster_Tiles");
#
#
#	if monster_tiles != null:
#		for cell in monster_tiles.get_used_cells():
#			print("cells")
#			if cell != -1:
#				spawn_counter(cell);
#
#	get_node("Game").queue_free();
	

#func spawn_counter(cell):
#	monster_count[object_name[cell]] += 1; #increase counter
#
#	var mc = MONSTER_COUNTER.instance();
#	mc.monster_num = cell;
#	mc.amount = monster_count[object_name[cell]];
#	$GridContainer.add_child(mc);
