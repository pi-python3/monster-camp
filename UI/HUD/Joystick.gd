extends TouchScreenButton

var input_dir = [
	Vector2(1,0),
	Vector2(-1,0),
	Vector2(0,1),
	Vector2(0,-1),
	Vector2(1,1).normalized(),
	Vector2(-1,-1).normalized(),
	Vector2(-1,1).normalized(),
	Vector2(1,-1).normalized()
];

var dir_to_input = {
	Vector2(0,-1): "ui_up",
	Vector2(0,1): "ui_down",
	Vector2(-1,0): "ui_left",
	Vector2(1,0): "ui_right"
};

func _ready():
	$Inner_Circle.hide();


func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed && event.position.x > 280:
			return;
	
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if is_pressed():
			$Inner_Circle.show();
			input_direction(
				vector_to_input_dir(
					calc_move_vector(event.position) ));
			keep_inner_circle_inside( event.position - (Vector2(2.5,2.5)*scale.x) );
#			$Inner_Circle.global_position = event.position - (Vector2(2.5,2.5)*scale.x);
	
	if event is InputEventScreenTouch:
		if !event.pressed:
			input_clear();
			$Inner_Circle.hide();


func calc_move_vector(event_pos):
	var center: Vector2 = global_position + (Vector2(10.5,10.5)*scale.x);
	return (event_pos - center).normalized();


func vector_to_input_dir(vector: Vector2):
	var best_dir = input_dir[0];
	
	for i in input_dir:
		if vector.dot(i) > vector.dot(best_dir):
			best_dir = i;
	
	return best_dir;


func input_direction(dir: Vector2, clear_inputs:= true):
	if dir.x != 0 && dir.y != 0:
		var dir1 = Vector2(dir.x, 0).normalized();
		var dir2 = Vector2(0, dir.y).normalized();
		input_direction(dir1);
		input_direction(dir2, false);
		return;
	
	if clear_inputs: input_clear();
	Input.action_press(dir_to_input[dir]);


func input_clear():
	for i in input_dir:
		if i.x != 0 && i.y != 0: continue;
		else: Input.action_release(dir_to_input[i]);


func keep_inner_circle_inside(pos: Vector2):
	var center := global_position + (Vector2(8,8)*scale.x);
	
	var vector: Vector2 = pos - center;
	if vector.length() > 80:
		vector = vector.normalized() * 80;
	$Inner_Circle.global_position = center + vector;
