extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var audio_player: AudioStreamPlayer2D = $"../AudioStreamPlayer2D"

@export var button_index: int = 0
@export var button_textures: Array[Texture2D] = []
@export var button_sound: AudioStream

var start_y: float
var is_pressing: bool = false

func _ready() -> void:
	start_y = position.y
	
	if button_index >= 0 and button_index < button_textures.size():
		sprite.texture = button_textures[button_index]
		
	input_event.connect(_on_input_event)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		press_button()

func press_button() -> void:
	if is_pressing:
		return
		
	is_pressing = true
	position.y = start_y + 2
	
	if button_sound:
		audio_player.stream = button_sound
		audio_player.play()
	
	if get_parent().has_method("register_press"):
		get_parent().register_press(button_index)
		
	await get_tree().create_timer(0.1).timeout
	position.y = start_y
	is_pressing = false
