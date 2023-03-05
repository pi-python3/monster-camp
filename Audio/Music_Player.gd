extends AudioStreamPlayer

export(String) var Music_Folder_Path = "res://Audio/Music/";


func play_sound(music_name: String, path := Music_Folder_Path):
	if stream == null || stream.resource_path != path + music_name:
		stream = load(path + music_name);
	play();

func _process(_delta):
	if Global_Effects.paused:
		AudioServer.set_bus_effect_enabled(3,0, true);
	else:
		AudioServer.set_bus_effect_enabled(3,0, false);
