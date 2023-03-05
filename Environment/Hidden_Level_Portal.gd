extends Area2D

func _ready():
	pass


func _on_Hidden_Level_Portal_body_entered(body):
	if body.is_in_group("Monster"):
		Level_Handler.load_level(16);
