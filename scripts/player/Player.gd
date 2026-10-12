extends CharacterBody2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var carried_item_sprite: Sprite2D = $CarriedItem


@export var movement_speed: float = 200.0
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.15
@export var double_tap_time: float = 0.25
@export var default_drop_scene: PackedScene

var character_direction: Vector2 = Vector2.ZERO
var last_tap_direction: Vector2 = Vector2.ZERO
var tap_timer: float = 0.0
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

var inventory: Dictionary = {}
var held_item_id: String = ""
var held_item_texture: Texture2D = null
var held_drop_scene: PackedScene = null
var held_normal_tex: Texture2D = null
var held_highlight_tex: Texture2D = null

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
	return held_item_id != ""

func pick_up_item(item_id: String, item_tex: Texture2D, drop_scene: PackedScene = null, normal_tex: Texture2D = null, highlight_tex: Texture2D = null) -> void:
	held_item_id = item_id
	held_item_texture = item_tex
	held_drop_scene = drop_scene if drop_scene else default_drop_scene
	held_normal_tex = normal_tex
	held_highlight_tex = highlight_tex
	
	inventory[item_id] = true
	carried_item_sprite.texture = item_tex
		
	update_animation("idle" if character_direction == Vector2.ZERO else "walking")

func consume_held_item() -> void:
	if held_item_id != "":
		inventory[held_item_id] = false
	held_item_id = ""
	held_item_texture = null
	held_drop_scene = null
	held_normal_tex = null
	held_highlight_tex = null
	carried_item_sprite.texture = null
	update_animation("idle" if character_direction == Vector2.ZERO else "walking")

func update_animation(base_anim: String) -> void:
	var target_anim = base_anim
	if is_carrying_anything():
		target_anim = "carry_" + base_anim
		carried_item_sprite.texture = held_item_texture
		
	if anim_player.current_animation != target_anim:
		anim_player.play(target_anim)

func drop_held_item() -> void:
	if not is_carrying_anything():
		return
		
	var scene_to_spawn = held_drop_scene if held_drop_scene else default_drop_scene
	if scene_to_spawn:
		var drop_instance = scene_to_spawn.instantiate()
		if "item_id" in drop_instance:
			drop_instance.item_id = held_item_id
			drop_instance.action_text = "pick up " + held_item_id
			if held_item_texture:
				drop_instance.item_texture = held_item_texture
			if held_normal_tex:
				drop_instance.normal_texture = held_normal_tex
			if held_highlight_tex:
				drop_instance.highlighted_texture = held_highlight_tex
				
		get_tree().current_scene.add_child(drop_instance)
		var drop_offset = character_direction * 20 if character_direction != Vector2.ZERO else Vector2(0, 10)
		drop_instance.global_position = global_position + drop_offset

	consume_held_item()
