extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_button_pressed()->void:
	emit_signal("start_pressed")
	
func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("start_pressed")
	
