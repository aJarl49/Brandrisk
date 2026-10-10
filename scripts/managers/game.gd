extends Node

@export var intro: PackedScene = load("res://scenes/ui/intro.tscn")
@export var game_over: PackedScene = load("res://scenes/ui/game_over.tscn")
@export var credits: PackedScene = load("res://scenes/ui/credits.tscn")
@export var start_screen: PackedScene = load ("res://scenes/ui/start_screen.tscn")

	

#var intro_instance: Node2D
#var game_over_instance: Node2D
#var credits_instance: Node2D
var loop_started = false
var current_screen:Node

func _ready():
	show_intro()

func clear_current_screen():
	if current_screen != null:
		current_screen.queue_free()
		current_screen = null

func show_intro():
	current_screen = intro.instantiate()
	add_child(current_screen)
	await get_tree().create_timer(2.0).timeout
	show_start_screen()
	
func show_start_screen():
	print("show start screen")
	clear_current_screen()
	current_screen = start_screen.instantiate()
	add_child(current_screen)
	current_screen.button_pressed.connect(_on_button_pressed)
	print ("signal recieved")
	
func _on_button_pressed():
	current_screen.queue_free()
	start_loop()
#	instance.start_loop.connect(_on_start_loop)

func start_loop():
	loop_started = true
	clear_current_screen()
	LevelManager.start_game()

func show_game_over(background_texture = null):
	current_screen = game_over.instantiate()

	if background_texture:
		current_screen.background_texture = background_texture

	add_child(current_screen)

func _on_retry():
	if current_screen:
		current_screen.queue_free()
		current_screen = null

	start_loop()

func _on_exit():
	if current_screen:
		current_screen.queue_free()
		current_screen = null

	show_credits()

func show_credits():
	current_screen = credits.instantiate()
	add_child(current_screen)
	current_screen.finished.connect(_on_credits_finished)

func _on_credits_finished():
	get_tree().quit()
