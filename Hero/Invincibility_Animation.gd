extends Node2D

export(float) var FLASH_PER_SEC = 3;
onready var sprite_handler = owner.get_node("Sprite_Handler");
var animate = false;
var alpha_on = false;


func start():
	$Flash_Time.wait_time = 1 / FLASH_PER_SEC;
	alpha_on = true;
	animate = true;
	
	alpha_on = alpha_switch(alpha_on);


func alpha_switch(alpha: bool):
	if not animate: return !alpha;
	
	if alpha:
		sprite_handler.alpha_off();
	else:
		sprite_handler.change_alpha();
	
	$Flash_Time.start();
	return !alpha;


func _on_Flash_Time_timeout():
	alpha_on = alpha_switch(alpha_on);


func stop():
	animate = false;
	$Flash_Time.stop();
	sprite_handler.alpha_off();
