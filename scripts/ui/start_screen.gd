extends Node2D
signal button_pressed


func _on_button_pressed() -> void:
	button_pressed.emit()
	print("Signal emitted from button")

#func _process(_delta: float) -> void:
#	if Input.is_action_just_pressed("ui_accept"):
#		button_pressed.emit()
#		print("Signal emitted from keyboard")
