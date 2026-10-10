extends Node

@export var editor_scenes : Array[PackedScene]
@export var hud: PackedScene = load("res://scenes/ui/hud.tscn")


@export var first_scene_index : int = 0;

var current_level_index: int = 0

var time : float = 0;
var has_advanced : bool = false


var hud_instance = null;
var _initialized = false;




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not _initialized:
			_initialized = true


	
func spawn_hud():
	if hud_instance:
		return
	hud_instance = hud.instantiate()
	get_tree().root.add_child(hud_instance)

func restart_game():
	if hud_instance:
		hud_instance.queue_free()
		hud_instance = null
	_initialized = false
	get_tree().pause = false
