extends Node

@onready var player = get_tree().get_first_node_in_group("player")
@onready var label = $Label

func _ready() -> void:
	print("InteractManager Initialized")



const base_text = "[E] to "
var active_areas = []
var can_interact = true

func register_area(area: InteractionArea):
	active_areas.push_back(area)
	
func unregister_area(area: InteractionArea):
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)
	
func _process(_delta):
	if active_areas.size() > 0 and can_interact:
		active_areas.sort_custom(_sort_by_distance)
		label.text = base_text + active_areas[0].action_name
		label.global_position = active_areas[0].global_position
		label.global_position.y -= 150
		label.global_position.x -= label.size.x / 2
		label.show()
	else:
		label.hide()
	
func _sort_by_distance(area1, area2):
	var d1 = player.global_position.distance_to(area1.global_position)
	var d2 = player.global_position.distance_to(area2.global_position)
	return d1 < d2

func _input(event):
	if event.is_action_pressed("interact") and can_interact and active_areas.size() > 0:
		can_interact = false
		label.hide()
		await active_areas[0].interact.call()
		can_interact = true
