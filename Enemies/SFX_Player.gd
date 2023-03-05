extends AudioStreamPlayer

export(String) var SFX_Folder_Path = "res://Audio/SFX/";


func play_sound(sfx_name: String, path := SFX_Folder_Path):
	if stream == null || stream.resource_path != path + sfx_name:
		stream = load(path + sfx_name);
	
	play();
