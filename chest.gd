extends StaticBody2D

var player_in_range: bool = false

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = true
		print("Tryck E för att interagera")
		
		


func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false
		print("Lämnat Collision")
		
func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		interact()

func interact() -> void:
	print("Interaktion utförd! Här kan du öppna en dialog eller plocka upp föremålet.")
