extends Label


func _process(delta):
	text = owner.current_state.name;
