extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite: Sprite2D = $Sprite2D

@export var action_text: String = "use"
@export var normal_texture: Texture2D
@export var highlighted_texture: Texture2D
@export var target_scene: PackedScene
@export var open_as_overlay: bool = false

var player = null
var player_in_area: bool = false
var overlay_instance: Node2D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	interaction_area.action_name = action_text
	interaction_area.interact = Callable(self, "_on_interact")
	
	if not interaction_area.body_entered.is_connected(_on_interaction_area_body_entered):
		interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	if not interaction_area.body_exited.is_connected(_on_interaction_area_body_exited):
		interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	
	if normal_texture:
		sprite.texture = normal_texture

func _unhandled_input(event: InputEvent) -> void:
	if overlay_instance != null and event.is_action_pressed("ui_cancel"):
		overlay_instance.queue_free()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = true
		_update_sprite_visuals()

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		_update_sprite_visuals()

func _on_interact() -> void:
	if not target_scene:
		return
		
	if not open_as_overlay:
		get_tree().change_scene_to_packed(target_scene)
		return
		
	if overlay_instance != null:
		return
		
	overlay_instance = target_scene.instantiate()
	overlay_instance.z_index = 100
	get_tree().current_scene.add_child(overlay_instance)
	
	var cam = get_viewport().get_camera_2d()
	if cam:
		var half_screen = (get_viewport_rect().size * 0.5) / cam.zoom
		overlay_instance.global_position = cam.get_screen_center_position() - half_screen
	
	_set_player_locked(true)
	overlay_instance.tree_exited.connect(_on_overlay_closed)

func _on_overlay_closed() -> void:
	overlay_instance = null
	_set_player_locked(false)

func _set_player_locked(locked: bool) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	player.set_physics_process(not locked)
	player.set_process(not locked)
	if locked:
		player.velocity = Vector2.ZERO
		player.update_animation("idle")

func _update_sprite_visuals() -> void:
	if player_in_area and highlighted_texture:
		sprite.texture = highlighted_texture
	elif normal_texture:
		sprite.texture = normal_texture
