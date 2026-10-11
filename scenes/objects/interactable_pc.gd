extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite: Sprite2D = $Sprite2D

@export var normal_texture: Texture2D
@export var highlighted_texture: Texture2D
@export var pc_scene: PackedScene

func _ready() -> void:
	interaction_area.action_name = "use PC"
	interaction_area.interact = Callable(self, "_on_interact")
	
	if not interaction_area.body_entered.is_connected(_on_interaction_area_body_entered):
		interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	if not interaction_area.body_exited.is_connected(_on_interaction_area_body_exited):
		interaction_area.body_exited.connect(_on_interaction_area_body_exited)
		
	sprite.texture = normal_texture

func _on_interact() -> void:
	if pc_scene:
		get_tree().change_scene_to_packed(pc_scene)

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite.texture = highlighted_texture

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite.texture = normal_texture
