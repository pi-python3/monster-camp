extends Area2D

var offset = 6;
onready var sprite = owner.get_node("Sprite");
onready var slash_animation = get_parent().get_node("Slash_Animation");

func _ready():
	$CollisionShape2D.disabled = true;


func offset_on():
	if "attack" in slash_animation.current_animation:
		position.x += offset;
#		if !sprite.get_flip(): #right
#			position.x += offset;
#		elif sprite.get_flip(): #left
#			position.x -= offset;


func offset_off():
	position.x -= offset;
	
#	if !sprite.get_flip(): #right
#		position.x -= offset;
#	elif sprite.get_flip(): #left
#		position.x += offset;
