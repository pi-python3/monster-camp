extends Light2D

signal destroy;

func _ready():
	$Animation.play("Flicker");
