extends Node

#duration, frequency, amplitude, angle amplitude, priority
const SHAKE_PRESETS = {
#	'small': 0.2,
#	'medium': 0.5,
#	'large': 0.75,
#	'explosion': 1.0
	"small": [0.1, 15, 4, 3, 1],
	"medium": [0.1, 15, 6, 4, 2],
	"large": [0.15, 15, 8, 5, 3],
	"explosion": [0.5, 25, 12, 5, 4]
}

var camera: Camera2D;

var freeze_frame_data = {
	"in_freeze_frame": false,
	"value": 0
};


func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS;
	Level_Handler.connect("new_level", self, "_on_new_level");


func _on_new_level(_level):
	if get_parent().get_node_or_null("Game") != null:
		camera = get_parent().get_node("Game").get_node_or_null("Camera");
	
	freeze_frame_data = {
	"in_freeze_frame": false,
	"value": 0};


func shake(preset: String):
	if camera == null: return;
	
	if preset.to_lower() in SHAKE_PRESETS:
		var params = SHAKE_PRESETS[preset.to_lower()];
		camera.get_node("Screen_Shake").start(params[0], params[1], params[2], params[3], params[4]);
	
	else:
		print("PRESET <" + preset.to_lower() + "> DOES NOT EXIST");


const FREEZE_PRESETS = {
	"small": 0.025,
	"medium": 0.035,
	"large": 0.05
};


func freeze_frame(preset: String):
	if Game_Data.mobile_buttons: return;
	
	if not preset in FREEZE_PRESETS:
		print("FREEZE FRAME PRESET <" + preset + "> NOT FOUND!");
		return;
	if freeze_frame_data['value'] >= FREEZE_PRESETS[preset] || freeze_frame_data['in_freeze_frame']:
		return;
	
	freeze_frame_data['in_freeze_frame'] = true;
	freeze_frame_data['value'] = FREEZE_PRESETS[preset];
	
	get_tree().paused = true;
	yield(get_tree().create_timer(FREEZE_PRESETS[preset]), 'timeout');
	get_tree().paused = false;
	
	freeze_frame_data['in_freeze_frame'] = false;
	freeze_frame_data['value'] = 0;


func zoom_on_position(zoom_position = Vector2(300,300), zoom_amount = 4.0, time = 0.5):
	var pos_tween = Tween.new();
	camera.add_child(pos_tween);
	pos_tween.interpolate_property(camera, "position", camera.position, zoom_position,
	time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT);
	
	var zoom_tween = Tween.new();
	camera.add_child(zoom_tween);
	zoom_tween.interpolate_property(camera, "zoom", camera.zoom, Vector2(1.0/zoom_amount, 1.0/zoom_amount),
	time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT);
	
	pos_tween.start();
	zoom_tween.start();


func reset_zoom(time = 0.01):
	zoom_on_position(Vector2(300,300), 1, time);


#func cinematic_on():
#	camera.get_node("Cinematic_Bars").close();
#
#func cinematic_off():
#	camera.get_node("Cinematic_Bars").open();
