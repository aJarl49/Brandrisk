extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@export var item_texture: Texture2D
@export var normal_texture: Texture2D
@export var highlighted_texture: Texture2D
@onready var sprite = $Sprite2D
func _ready() -> void:
	interaction_area.action_name = "pick up cotton ball"
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		for item in player.inventory:
			if player.inventory[item] == true:
				interaction_area.action_name = "my hands are full..."
				return

		player.inventory["cotton ball"] = true
		
		var carried_sprite = player.get_node_or_null("CarriedItem")
		if carried_sprite and item_texture:
			carried_sprite.texture = item_texture
			
		queue_free()


func _on_interaction_area_body_entered(body: Node2D) -> void:
	sprite.texture = highlighted_texture


func _on_interaction_area_body_exited(body: Node2D) -> void:
	sprite.texture = normal_texture
