
extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea

func _ready() -> void:
	interaction_area.action_name = "test interact"
	
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	print("Base Template Interact.")
