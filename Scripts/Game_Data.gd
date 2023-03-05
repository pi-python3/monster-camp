extends Node

var unlocked_skull_chests_amount: int = 0;
var unlocked_skull_chests: Dictionary;
var current_unlocked_level: int = 0;
var skull_chests: int = 0;

var can_hat_mode := false;
var hat_mode := false;

var mobile_buttons := false;


func _ready():
	for i in range(Level_Handler.MAX_LEVELS):
		unlocked_skull_chests[i] = false;


func unlock_level(level = Level_Handler.get_current_level()+1):
	current_unlocked_level = max(level, current_unlocked_level);


func unlock_skull_chest(level = Level_Handler.get_current_level()):
	if unlocked_skull_chests[level] == false:
		skull_chests += 1;
	unlocked_skull_chests[level] = true;
	
	if skull_chests >= 10:
		can_hat_mode = true;
		hat_mode = true;


func get_unlocked_skull_chests_amount() -> int:
	var amount: int = 0;
	for unlocked in unlocked_skull_chests.values():
		if unlocked: amount += 1;
	
	unlocked_skull_chests_amount = amount;
	return unlocked_skull_chests_amount;
