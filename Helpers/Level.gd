extends Node2D

signal level_loaded;


func _ready():
	connect('level_loaded', Level_Handler, "_level_loaded");
	emit_signal("level_loaded");
	
	Global_Effects.slow_motion(0);
	Combo_Manager.points = 0;
