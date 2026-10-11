extends Node


var pin_code : Array[int] = []
var is_playing: bool = false


func generate_pin_code() -> Array[int]:
	var code: Array[int] = []
	for i in range(4):
		code.append(randi_range(0,9))
	print("Genererad Kod: ", code)

	return code


func _ready() -> void:
	pin_code = generate_pin_code()
