extends Label

var combo_num = 0;
var showing := false;


func _ready():
	combo_num = Combo_Manager.combo_num;
	modulate.a = 0;
	visible = false;
	showing = visible;


func _process(_delta):
	if modulate.a == 0: visible = false;
	else: visible = true;
	
	var scale_amount = lerp(0.4, 0.5, clamp( float(combo_num) / 6.0, 0.0, 1.0));
	if !$Animation.is_playing(): rect_scale = Vector2(scale_amount, scale_amount);
	
	var q = (Combo_Manager.combo_num > 0) && (get_parent().get_node("Time_Meter").value > 0);
	if showing != q:
		showing = q;
		animate();
	
	if combo_num != Combo_Manager.combo_num:
		combo_num = Combo_Manager.combo_num;
		text = "x" + str(Combo_Manager.combo_num);
		rect_pivot_offset = rect_size / 2;
		get_material().set_shader_param("frequency", clamp(combo_num*7.0, 7.0, 50.0));
		visible = true;
		showing = visible;
		$Animation.play("Pop");


func animate():
	if showing:
		modulate.a = 1.0;
	else:
		$Animation.play("Fade");
