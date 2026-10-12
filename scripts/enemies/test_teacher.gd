extends CharacterBody2D

@export var pin_code_sounds: Array[AudioStreamWAV] = []

@onready var timer: Timer = $waiting_timer
@onready var code_lock_player = $code_lock_player

func _ready() -> void:
	timer.wait_time = 5.0
	timer.one_shot = true
	if not timer.timeout.is_connected(_on_waiting_timer_timeout):
		timer.timeout.connect(_on_waiting_timer_timeout)
	timer.start()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		PinCodeManager.generate_pin_code()

func _on_waiting_timer_timeout() -> void:
	await play_code_lock_sound()
	timer.start(5.0)

func play_code_lock_sound() -> void:
	for digit in PinCodeManager.pin_code:
		if digit < pin_code_sounds.size() and pin_code_sounds[digit]:
			code_lock_player.stream = pin_code_sounds[digit]
			code_lock_player.play()
			await code_lock_player.finished
