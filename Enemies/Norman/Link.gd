extends Line2D

onready var head: KinematicBody2D = owner.get_parent().find_node("*Head*");

func _ready():
	show();


func _physics_process(_delta):
	global_position = Vector2(0,0);
	if owner.scale.x < 0: scale.x = -1;
	clear_points();
	var scalar: float = 5
	add_point(Vector2(owner.position.x, owner.position.y - (5*scalar)) / scalar);
	add_point(Vector2(owner.position.x, owner.position.y - (13*scalar)) / scalar);
	add_point(head.global_position/scalar);


func _on_Norman_Hand_die(_object):
	hide();
