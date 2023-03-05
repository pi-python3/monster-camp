tool
extends Label

export(bool) var show_texture = false;



func _on_Title_Letter_visibility_changed():
	if show_texture:
		self_modulate.a = 0;
		$TextureRect.self_modulate.a = 1;
	else:
		self_modulate.a = 1;
		$TextureRect.self_modulate.a = 0;
