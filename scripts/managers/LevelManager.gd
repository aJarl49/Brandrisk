extends Node2D

@onready var door = "res://scenes/door.tscn"
@export var hud_scene: PackedScene
@export var game_over_scene: PackedScene
@export var first_scene_index : int = 0;
@export var editor_scenes : Array[PackedScene];

var loadable_scenes : Array[LoadableScene];
var current_level_index: int = 0
var current_scene : LoadedScene;
var time : float = 0;
var has_advanced : bool = false;
var hud_instance = null;
var _initialized = false

func _process(_delta):
	if not _initialized:
		if loadable_scenes.size() > 0:
			load_level_scene_by_index(first_scene_index)
			_initialized = true

func _ready() -> void:
	print("Editor scenes assigned: ", editor_scenes.size())
	populate_loadable_scenes_list();
	print("Loadable scenes created: ", loadable_scenes.size())
	return;

func load_level_scene_by_index(index: int) -> LoadedScene:
	if index < 0 or index >= loadable_scenes.size():
		return null
	return load_level_scene(loadable_scenes[index], index)
	
func load_scen_by_name(scene_name : String) -> LoadedScene:
	var i = 0;
	while i < loadable_scenes.size():
		if(scene_name == loadable_scenes[i].scene_name):
			return load_level_scene(loadable_scenes[i], i);
		i += 1;
	return null;
	
func load_level_scene(scene_to_load : LoadableScene, index : int) -> LoadedScene:
	current_level_index = index 
	if(!scene_to_load.scene.instantiate()):
		return null;
	if (current_scene != null):
		current_scene.scene.queue_free();
		current_scene = null;
	var new_scene : Node = scene_to_load.scene.instantiate();
	if (new_scene == null):
		return null;
	current_scene = LoadedScene.new();
	current_scene.scene = new_scene;
	current_scene.scene_index = index;
	current_scene.scene_name = scene_to_load.scene_name
	call_deferred("add_child", new_scene)
	call_deferred("_connect_doors_deferred", new_scene)
	call_deferred("spawn_hud")
	return current_scene;
	
func _connect_doors_deferred(new_scene):
	for d in new_scene.get_tree().get_nodes_in_group("Doors"):
		if d.has_signal("door_entered") and not d.is_connected("door_entered", Callable(self, "_on_door_entered")):
			d.connect("door_entered", Callable(self, "_on_door_entered"))
	print("Doors connected in:", new_scene.name)	

func _on_door_entered(door_type):
	print("Door entered:", door_type)
	match door_type:
		"next":
			var next_index = current_scene.scene_index + 1
			if next_index < loadable_scenes.size():
				load_level_scene_by_index(next_index)
			else:
				print("No more levels to load!")
		"restart":
			restart_game()
		"exit":
			get_tree().quit()

func populate_loadable_scenes_list() -> void:
	for scene in editor_scenes:
		print(add_level_scene_to_array(scene))
		
func add_level_scene_to_array(scene: PackedScene) -> int:
	if (scene==null):
		return -1;
	var scene_name : String = scene.resource_path.get_file().get_basename()
	var i : int = 0;
	var loadable_scene : LoadableScene = LoadableScene.new();
	while i<loadable_scenes.size():
		if scene_name == loadable_scenes[i].scene_name:
			printerr("Duplicate scene witth the name: " + name);
			return -1
		i+=1
	loadable_scene.scene_name = scene_name
	loadable_scene.scene = scene
	loadable_scenes.append(loadable_scene)
	return loadable_scenes.size() - 1;
	
func remove_level_scene_from_array_by_index(index : int) ->bool:
	if (index < 0 || index > loadable_scenes.size()):
		return false;
	loadable_scenes.remove_at(index);
	readjust_current_level_scenes_index();
	return true;
	
func remove_level_scene_from_array_by_name(scene_name : String) -> bool:
	var i : int = 0;
	while i < loadable_scenes.size():
		if(loadable_scenes[i].scene_name == scene_name):
			loadable_scenes.remove_at(i);
			readjust_current_level_scenes_index();
			return true;
		i += 1
	return false;
	
func readjust_current_level_scenes_index() -> void:
	var i : int = 0 
	while i < loadable_scenes.size():
		if(loadable_scenes[i].scene_name == current_scene.scene_name):
			current_scene.scene_index = 1;
			return;
		i += 1
		
func restart_game():
	#GameManager.reset_game()
	if hud_instance:
		hud_instance.queue_free()
		hud_instance = null
	_initialized = false
	get_tree().paused = false
	load_level_scene_by_index(0)
	
func show_game_over():
	var ui = game_over_scene.instantiate()
	get_tree().root.add_child(ui)

func spawn_hud():
	if hud_instance:
		return
	hud_instance = hud_scene.instantiate()
	get_tree().root.add_child(hud_instance)
	
class LoadedScene:
	var scene_index : int;
	var scene_name : String
	var scene : Node;
	
class LoadableScene:
	var scene_name :String
	var scene : PackedScene
