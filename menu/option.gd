extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_back_pressed():
	get_tree().change_scene_to_file("res://menu/menu.tscn")
