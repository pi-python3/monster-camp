extends Control

onready var camera = get_parent();


func _process(delta):
	rect_scale = camera.zoom;

func close(): $Animation.play("Close");
func open(): $Animation.play("Open");
