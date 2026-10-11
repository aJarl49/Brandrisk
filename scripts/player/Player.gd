extends CharacterBody2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var carried_item_sprite: Sprite2D = $CarriedItem
@export var movement_speed: float = 200
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.15
@export var double_tap_time: float = 0.25
@export var cotton_ball_scene: PackedScene
@export var cotton_ball_texture: Texture2D
@export var coffe_pot_scene: PackedScene
@export var coffe_pot_texture: Texture2D
@export var power_strip_scene: PackedScene
@export var power_strip_texture: Texture2D


var character_direction: Vector2 = Vector2.ZERO
var last_tap_direction: Vector2 = Vector2.ZERO
var tap_timer: float = 0.0
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

var inventory = {
	"cotton ball" : false,
	"coffee pot" : false, 
	"power strip" : false
}

func _ready() -> void:
	update_animation("idle")

func _process(delta: float) -> void:
	if tap_timer > 0:
		tap_timer -= delta
		
	if Input.is_action_just_pressed("drop_item"):
		drop_held_item()

func _physics_process(delta: float) -> void:
	if is_dashing:
		velocity = dash_speed * dash_direction
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
		move_and_slide()
		return
	
	var tap_direction := Vector2.ZERO

	if Input.is_action_just_pressed("move_right"):
		tap_direction = Vector2.RIGHT
	elif Input.is_action_just_pressed("move_left"):
		tap_direction = Vector2.LEFT
	elif Input.is_action_just_pressed("move_up"):
		tap_direction = Vector2.UP
	elif Input.is_action_just_pressed("move_down"):
		tap_direction = Vector2.DOWN

	if tap_direction != Vector2.ZERO:
		if last_tap_direction == tap_direction and tap_timer > 0:
			start_dash(tap_direction)
		else:
			last_tap_direction = tap_direction
			tap_timer = double_tap_time

	character_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if character_direction != Vector2.ZERO:
		velocity = character_direction * movement_speed
		update_animation("walking")
			
		if character_direction.x > 0:
			sprite.flip_h = true
		elif character_direction.x < 0:
			sprite.flip_h = false
	else:
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed)
		update_animation("idle")

	move_and_slide()

func start_dash(dir: Vector2) -> void:
	is_dashing = true
	dash_direction = dir
	dash_timer = dash_duration
	tap_timer = 0.0

func is_carrying_anything() -> bool:
	for item_name in inventory:
		if inventory[item_name] == true:
			
			return true
	return false

func update_animation(base_anim: String) -> void:
	var target_anim = base_anim
	
	if is_carrying_anything():
		target_anim = "carry_" + base_anim
		if inventory["cotton ball"] == true:
			carried_item_sprite.texture = cotton_ball_texture
		elif inventory["coffee pot"] == true:
			carried_item_sprite.texture = coffe_pot_texture
		elif inventory["power strip"] == true:
			carried_item_sprite.texture = power_strip_texture
			
		
	if anim_player.current_animation != target_anim:
		anim_player.play(target_anim)
	
	

func drop_held_item() -> void:
	var dropped_item_name = ""
	
	for item_name in inventory:
		if inventory[item_name] == true:
			dropped_item_name = item_name
			inventory[item_name] = false
			break 
			
	if dropped_item_name == "":
		return
		
	print("Släppte: ", dropped_item_name)
	
	carried_item_sprite.texture = null
	
	var drop_instance = null
	
	if dropped_item_name == "cotton ball" and cotton_ball_scene:
		drop_instance = cotton_ball_scene.instantiate()
	elif dropped_item_name == "coffee pot" and coffe_pot_scene:
		drop_instance = coffe_pot_scene.instantiate()
	elif dropped_item_name == "power strip" and power_strip_scene:
			drop_instance = power_strip_scene.instantiate()
	if drop_instance:
		get_tree().current_scene.add_child(drop_instance)
		
		var drop_offset = Vector2(0, 10) 
		if character_direction != Vector2.ZERO:
			drop_offset = character_direction * 20
			
		drop_instance.global_position = global_position + drop_offset

	if character_direction != Vector2.ZERO:
		update_animation("walking")
	else:
		update_animation("idle")
