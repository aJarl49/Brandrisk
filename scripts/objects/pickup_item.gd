extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite: Sprite2D = $Sprite2D

@export var item_id: String = "power strip"
@export var action_text: String = "pick up power strip"
@export var item_texture: Texture2D
@export var normal_texture: Texture2D
@export var highlighted_texture: Texture2D

func _ready() -> void:
	interaction_area.action_name = action_text
	interaction_area.interact = Callable(self, "_on_interact")
	
	if not interaction_area.body_entered.is_connected(_on_interaction_area_body_entered):
		interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	if not interaction_area.body_exited.is_connected(_on_interaction_area_body_exited):
		interaction_area.body_exited.connect(_on_interaction_area_body_exited)
		
	if normal_texture:
		sprite.texture = normal_texture

func _on_interact() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
		
	if player.is_carrying_anything():
		interaction_area.action_name = "my hands are full... I need to drop something [Q]"
		return

	var own_scene: PackedScene = load(scene_file_path) if scene_file_path != "" else null
	player.pick_up_item(item_id, item_texture, own_scene, normal_texture, highlighted_texture)
	queue_free()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and highlighted_texture:
		sprite.texture = highlighted_texture

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		interaction_area.action_name = action_text
		if normal_texture:
			sprite.texture = normal_texture
