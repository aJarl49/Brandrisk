extends Node2D

@export var code_generator_node: Node
var player = null

var entered_code: Array[int] = []

func _ready() -> void:
	print(PinCodeManager.pin_code)
	player = get_tree().get_first_node_in_group("player")


func register_press(number: int) -> void:
	entered_code.append(number)
	print("Entered so far: ", entered_code)
	
	if entered_code.size() == 4:
		if entered_code == PinCodeManager.pin_code:
			print("Code matched!")
			_on_code_success()
		else:
			print("Wrong code! Resetting.")
			
		entered_code.clear()

func _on_code_success() -> void:
	await get_tree().create_timer(0.3).timeout
	player.global_position.y -= 150
	queue_free()
