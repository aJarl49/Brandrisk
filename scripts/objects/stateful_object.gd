extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite: Sprite2D = $Sprite2D

@export_group("Step 1 (Start)")
@export var step1_action_text: String = "interact"
@export var step1_normal_texture: Texture2D
@export var step1_highlighted_texture: Texture2D
@export var step1_required_item: String = ""
@export var step1_gives_item: String = ""
@export var step1_gives_texture: Texture2D
@export var step1_gives_drop_scene: PackedScene

@export_group("Step 2 (Optional)")
@export var enable_step_2: bool = true
@export var step2_action_text: String = "interact again"
@export var step2_normal_texture: Texture2D
@export var step2_highlighted_texture: Texture2D
@export var step2_required_item: String = ""
@export var step2_gives_item: String = ""
@export var step2_gives_texture: Texture2D
@export var step2_gives_drop_scene: PackedScene

@export_group("Final State (Finished)")
@export var final_texture: Texture2D
@export var finish_spawn_scene: PackedScene
@export var finish_spawn_offset: Vector2 = Vector2.ZERO

var player = null
var sprite_index: int = 0
var player_in_area: bool = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	interaction_area.action_name = step1_action_text
	interaction_area.interact = Callable(self, "_on_interact")
	
	if not interaction_area.body_entered.is_connected(_on_interaction_area_body_entered):
		interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	if not interaction_area.body_exited.is_connected(_on_interaction_area_body_exited):
		interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	
	sprite.texture = step1_normal_texture

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = true
		_update_sprite_visuals()

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		_reset_action_text()
		_update_sprite_visuals()

func _on_interact() -> void:
	if not player:
		player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	if sprite_index == 0:
		if not _try_execute_step(step1_required_item, step1_gives_item, step1_gives_texture, step1_gives_drop_scene):
			return
		if enable_step_2:
			sprite_index = 1
			interaction_area.action_name = step2_action_text
			_update_sprite_visuals()
		else:
			_finish_object()
			
	elif sprite_index == 1:
		if not _try_execute_step(step2_required_item, step2_gives_item, step2_gives_texture, step2_gives_drop_scene):
			return
		_finish_object()

func _try_execute_step(req_item: String, give_item: String, give_tex: Texture2D, give_scene: PackedScene) -> bool:
	if req_item != "":
		if not player.inventory.get(req_item, false):
			return false
		player.consume_held_item()
		
	if give_item != "":
		if player.is_carrying_anything():
			interaction_area.action_name = "my hands are full... I need to drop something [Q]"
			return false
		player.pick_up_item(give_item, give_tex, give_scene)
		
	return true

func _finish_object() -> void:
	sprite_index = 2
	if final_texture:
		sprite.texture = final_texture
	if finish_spawn_scene:
		var effect = finish_spawn_scene.instantiate()
		add_child(effect)
		effect.position = finish_spawn_offset
	interaction_area.queue_free()

func _reset_action_text() -> void:
	if sprite_index == 0:
		interaction_area.action_name = step1_action_text
	elif sprite_index == 1:
		interaction_area.action_name = step2_action_text

func _update_sprite_visuals() -> void:
	if sprite_index == 0:
		sprite.texture = step1_highlighted_texture if player_in_area else step1_normal_texture
	elif sprite_index == 1:
		sprite.texture = step2_highlighted_texture if player_in_area else step2_normal_texture
	elif sprite_index == 2 and final_texture:
		sprite.texture = final_texture
