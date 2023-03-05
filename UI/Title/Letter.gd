tool
extends Sprite

enum Letter {M = 0, O = 1, N = 2, S = 3, T = 4, E = 5, R = 6, C = 7, A = 8, P = 10};

export(Letter) var letter;

func _ready():
	frame = letter;
	$Shadow.frame = frame;
