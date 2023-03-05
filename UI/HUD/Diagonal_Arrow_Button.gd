extends TouchScreenButton

var letter_to_direction = {
	"U": "ui_up",
	"D": "ui_down",
	"L": "ui_left",
	"R": "ui_right"
};

func _ready():
	connect("pressed", self, "_on_pressed");
	connect("released", self, "_on_release");

func _process(_delta):
	pass;
#	if pressed:
#		print(name + " pressed!")
#		Input.action_press(letter_to_direction[name.substr(0,1)]);
#		Input.action_press(letter_to_direction[name.substr(1,1)]);


func _on_pressed():
	print(name + " pressed!")
	Input.action_press(letter_to_direction[name.substr(0,1)]);
	Input.action_press(letter_to_direction[name.substr(1,1)]);

func _on_release():
	print(name + " released!")
	Input.action_release(letter_to_direction[name.substr(0,1)]);
	Input.action_release(letter_to_direction[name.substr(1,1)]);
