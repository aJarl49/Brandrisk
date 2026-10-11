extends TextureButton

var master_fun_bus_index: int
func _ready()-> void:
	master_fun_bus_index = AudioServer.get_bus_index("Master")
	toggled.connect(_on_toggled)
	

func _on_toggled(is_muted: bool) -> void:
	AudioServer.set_bus_mute(master_fun_bus_index, is_muted)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_M:
			button_pressed = not button_pressed
