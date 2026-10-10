extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite: Sprite2D = $Sprite2D

@export var normal_texture: Texture2D
@export var highlighted_texture: Texture2D
@export var ripped_sprite: Texture2D
@export var highlighted_ripped_sprite: Texture2D
@export var emptied_sprite: Texture2D

var sprite_index: int = 0
var player_in_area: bool = false

func _ready() -> void:
	interaction_area.action_name = "violently open the bear"
	interaction_area.interact = Callable(self, "_on_interact")
	
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	
	sprite.texture = normal_texture

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = true
		_update_sprite_visuals()

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		_update_sprite_visuals()

func _on_interact() -> void:
	if sprite_index == 0:
		sprite_index += 1
		interaction_area.action_name = "take the bears insanely flammable guts..."
		_update_sprite_visuals()
			
	elif sprite_index == 1:
		sprite.texture = emptied_sprite
		sprite_index += 1
		interaction_area.queue_free()

func _update_sprite_visuals() -> void:
	if player_in_area:
		if sprite_index == 0:
			sprite.texture = highlighted_texture
		elif sprite_index == 1:
			sprite.texture = highlighted_ripped_sprite
	else:
		if sprite_index == 0:
			sprite.texture = normal_texture
		elif sprite_index == 1:
			sprite.texture = ripped_sprite
