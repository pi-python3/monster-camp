extends Area2D

onready var offset = 4;

func _ready():
	$CollisionShape2D.disabled = true;


func offset_on():
	if Hero_Vars.facing == "right":
		position.x += offset;
	elif Hero_Vars.facing == "left":
		position.x -= offset;

func offset_off():
	position.x = 0;
#	if Hero_Vars.facing == "right":
#		position.x -= offset;
#	elif Hero_Vars.facing == "left":
#		position.x += offset;
