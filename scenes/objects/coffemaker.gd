extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite: Sprite2D = $Sprite2D

@export var normal_texture: Texture2D
@export var highlighted_texture: Texture2D
@export var without_can: Texture2D
@export var highlighted_without_can: Texture2D
@export var cotton_ball_texture: Texture2D
@export var highlighted_cotton_ball: Texture2D

var player = null
var sprite_index: int = 0
var player_in_area: bool = false
var has_coffee_pot: bool = true

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	interaction_area.action_name = "take the very liquid coffee"
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
		
		if has_coffee_pot:
			interaction_area.action_name = "take the very liquid coffee"
			
		_update_sprite_visuals()

func _on_interact() -> void:
	if has_coffee_pot:
		if _player_is_carrying_something():
			interaction_area.action_name = "my hands are full... I need to drop something [Q]"
			return 
			
		has_coffee_pot = false
		sprite_index = 1
		player.inventory["coffee pot"] = true 
		
		interaction_area.action_name = "place something very flammable"
		_update_sprite_visuals()
		
	elif not has_coffee_pot:
		if player.inventory.get("cotton ball", false):
			sprite_index = 2
			interaction_area.action_name = "light the cotton ball"
			
			player.inventory["cotton ball"] = false
			
			var carried_sprite = player.get_node_or_null("CarriedItem")
			if carried_sprite:
				carried_sprite.texture = null
				
			_update_sprite_visuals()

func _update_sprite_visuals() -> void:
	if player_in_area:
		if sprite_index == 0:
			sprite.texture = highlighted_texture
		elif sprite_index == 1:
			sprite.texture = highlighted_without_can
		elif sprite_index == 2:
			sprite.texture = highlighted_cotton_ball
	else:
		if sprite_index == 0:
			sprite.texture = normal_texture
		elif sprite_index == 1:
			sprite.texture = without_can
		elif sprite_index == 2:
			sprite.texture = cotton_ball_texture

func _player_is_carrying_something() -> bool:
	if player:
		for item in player.inventory:
			if player.inventory[item] == true:
				return true
	return false
