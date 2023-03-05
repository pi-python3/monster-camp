extends Particles2D

func _process(_delta):
	emitting = get_parent().get_node("Open_Particles").emitting;
