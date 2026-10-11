extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite: Sprite2D = $Sprite2D

@export var normal_texture: Texture2D
@export var highlighted_texture: Texture2D
@export var ripped_sprite: Texture2D
@export var highlighted_ripped_sprite: Texture2D
@export var emptied_sprite: Texture2D
@export var cotton_ball: Texture2D

var player = null
var sprite_index: int = 0
var player_in_area: bool = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
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
		
		# Återställ texten ifall den ändrades till "my hands are full"
		if sprite_index == 0:
			interaction_area.action_name = "violently open the bear"
		elif sprite_index == 1:
			interaction_area.action_name = "take the bears insanely flammable guts..."
			
		_update_sprite_visuals()

func _on_interact() -> void:
	if sprite_index == 0:
		# Slita upp björnen går bra även om händerna är fulla
		sprite_index += 1
		interaction_area.action_name = "take the bears insanely flammable guts..."
		_update_sprite_visuals()
			
	elif sprite_index == 1:
		# Kolla först om vi REDAN bär på något
		if _player_is_carrying_something():
			interaction_area.action_name = "my hands are full... I need to drop something [Q]"
			return 
			
		# Om jag har fria händer, plocka upp tussen
		sprite.texture = emptied_sprite
		player.inventory["cotton ball"] = true
		
		if player.carried_item_sprite and cotton_ball:
			player.carried_item_sprite.texture = cotton_ball
			
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

# Hjälpfunktion för att kolla om vi har något i händerna
func _player_is_carrying_something() -> bool:
	if player:
		for item in player.inventory:
			if player.inventory[item] == true:
				return true
	return false
