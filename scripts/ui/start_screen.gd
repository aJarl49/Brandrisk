extends Node2D

signal start_pressed
signal settings_pressed
signal credits_pressed
signal quit_pressed


func _on_start_pressed() -> void:
	start_pressed.emit()
	
func _on_credits_pressed() -> void:
	credits_pressed.emit()
	
func _on_quit_pressed() -> void:
	quit_pressed.emit()


	
	
#func _process(_delta: float) -> void:
#	if Input.is_action_just_pressed("ui_accept"):
#		button_pressed.emit()
#		print("Signal emitted from keyboard")
