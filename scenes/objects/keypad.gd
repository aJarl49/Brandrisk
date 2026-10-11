extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite: Sprite2D = $Sprite2D

@export var normal_texture: Texture2D
@export var highlighted_texture: Texture2D
@export var key_pad_minigame: PackedScene

var player = null
var player_in_area: bool = false
var minigame_instance: Node2D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	interaction_area.action_name = "use keypad"
	interaction_area.interact = Callable(self, "_on_interact")
	
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	
	sprite.texture = normal_texture

func _unhandled_input(event: InputEvent) -> void:
	if minigame_instance != null and event.is_action_pressed("ui_cancel"):
		minigame_instance.queue_free()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = true
		_update_sprite_visuals()

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		_update_sprite_visuals()

func _on_interact() -> void:
	if not key_pad_minigame or minigame_instance != null:
		return
		
	minigame_instance = key_pad_minigame.instantiate()
	
	minigame_instance.z_index = 100
	
	get_tree().current_scene.add_child(minigame_instance)
	
	var cam = get_viewport().get_camera_2d()
	if cam:
		var half_screen = (get_viewport_rect().size * 0.5) / cam.zoom
		minigame_instance.global_position = cam.get_screen_center_position() - half_screen
	
	_set_player_locked(true)
	
	minigame_instance.tree_exited.connect(_on_minigame_closed)

func _on_minigame_closed() -> void:
	minigame_instance = null
	_set_player_locked(false)

func _set_player_locked(locked: bool) -> void:
	if not player:
		return
	player.set_physics_process(not locked)
	player.set_process(not locked)
	if locked:
		player.velocity = Vector2.ZERO
		player.update_animation("idle")

func _update_sprite_visuals() -> void:
	if player_in_area:
		sprite.texture = highlighted_texture
	else:
		sprite.texture = normal_texture
