extends Node

onready var combo_meter = owner.get_node("HUD/UI/Combo_Meter");
var change_level = false;


func _process(_delta):
	if Combo_Manager.points >= combo_meter.max_value && !change_level:
		Game_Data.unlock_level();
		
		change_level = true;
		
		var timer = Timer.new();
		add_child(timer);
		timer.connect("timeout",self,"_on_timer_timeout");
		timer.start(2);
		set_process(false);


func _on_timer_timeout():
	Level_Handler.next_level();
