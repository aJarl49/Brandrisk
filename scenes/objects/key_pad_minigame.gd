extends Node2D

@export var code_generator_node: Node
signal keypad_minigame_successful
signal keypad_minigame_failed


var entered_code: Array[int] = []

func _ready() -> void:
	print(PinCodeManager.pin_code)


func register_press(number: int) -> void:
	entered_code.append(number)
	print("Entered so far: ", entered_code)
	
	if entered_code.size() == 4:
		if entered_code == PinCodeManager.pin_code:
			print("Code matched!")
			keypad_minigame_successful.emit()
		else:
			print("Wrong code! Resetting.")
			
		entered_code.clear()

func _on_exit_pressed() -> void:
	keypad_minigame_failed.emit()
