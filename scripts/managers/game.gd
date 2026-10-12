extends Node

@export var intro: PackedScene = load("res://scenes/ui/intro.tscn")
@export var game_over: PackedScene = load("res://scenes/ui/game_over.tscn")
@export var credits: PackedScene = load("res://scenes/ui/credits.tscn")
@export var start_screen: PackedScene = load ("res://scenes/ui/start_screen.tscn")
@export var settings: PackedScene = load ("res://scenes/ui/settings.tscn")
#@onready var intro_animation = preload("res://scenes/ui/intro.tscn").instantiate()
#@onready var animation: AnimationPlayer = intro_animation.get_node("AnimatiomPlayer")

	

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
	
	var animation: AnimationPlayer = current_screen.get_node("AnimationPlayer")
	animation.play("intro")
#	add_child(intro_animation)
#	animation.play("intro")
	await get_tree().create_timer(3.0).timeout
	show_start_screen()
	
func show_start_screen():
	clear_current_screen()
	current_screen = start_screen.instantiate()
	add_child(current_screen)
	current_screen.start_pressed.connect(_on_start_pressed)
	current_screen.credits_pressed.connect(_on_credits_pressed)
	current_screen.quit_pressed.connect(_on_quit_pressed)
	print ("signal recieved")
	
func _on_start_pressed():
	current_screen.queue_free()
	start_loop()
	
func _on_credits_pressed():
	clear_current_screen()
	show_credits()
	
func _on_quit_pressed():
	get_tree().quit()

func start_loop():
	print("loopStarted")
	loop_started = true
	clear_current_screen()
	var level = preload("res://scenes/ui/level_manger.tscn").instantiate()
	add_child(level)

func show_game_over(background_texture = null):
	current_screen = game_over.instantiate()

	if background_texture:
		current_screen.background_texture = background_texture

	add_child(current_screen)

func _on_retry():
	clear_current_screen()
	start_loop()

func _on_exit():
	clear_current_screen()
	show_credits()

func show_credits():
	current_screen = credits.instantiate()
	add_child(current_screen)
	#current_screen.finished.connect(_on_credits_finished)

func _on_credits_finished():
	get_tree().quit()
