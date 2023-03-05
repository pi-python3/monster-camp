extends Position2D


func _ready():
	hide();


func signal_out(to_point: Vector2):
	var angle = rad2deg(position.angle_to_point(to_point)) + 180;
	
	rotation_degrees = angle;
	$Sprite/Signal_Animation.play("Signal_Out");
