extends AnimatedSprite


func _process(_delta):
	match get_parent().animation:
		"Arrows":
			get_parent().position = Vector2(0.5, 0.5);
			hide();

		"Attack":
			position = Vector2(28.8,-1.6);
			get_parent().position = Vector2(-16, 0);
			show();
			animation = "Left";

		"Switch":
			position = Vector2(16, -1.6);
			get_parent().position = Vector2(-8, 0);
			show();
			animation = "Right";
