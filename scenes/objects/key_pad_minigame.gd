extends Node2D

@export var code_generator_node: Node
## Kryssa i om knappsatsen ska byta bana direkt via LevelManager, 
## annars flyttas spelaren y -= 150 (förbi dörren/väggen).
@export var change_level_on_success: bool = false

var player = null
var entered_code: Array[int] = []

signal keypad_minigame_successful
signal keypad_minigame_failed

func _ready() -> void:
	print("PIN-kod är: ", PinCodeManager.pin_code)
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
	keypad_minigame_successful.emit()
	await get_tree().create_timer(0.3).timeout
	
	if change_level_on_success:
		var level_manager = _find_level_manager(get_tree().root)
		if level_manager:
			level_manager._on_door_entered("next")
	elif player:
		player.global_position.y -= 150
		
	queue_free()

func _on_exit_pressed() -> void:
	keypad_minigame_failed.emit()
	queue_free()

func _find_level_manager(node: Node) -> Node:
	if node.has_method("_on_door_entered"):
		return node
	for child in node.get_children():
		var found = _find_level_manager(child)
		if found:
			return found
	return null
