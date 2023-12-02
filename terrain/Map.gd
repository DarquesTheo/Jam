extends Node3D

@onready var spawns = $Spawns
@onready var navigation_region = $NavigationRegion3D
var zombie = load("res://Enemy/enemy_1.tscn")
var instance

func _ready():
	randomize()

func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)
	
func _on_zombie_spawn_timer_timeout():
	var spawn_point = _get_random_child(spawns).global_position
	instance = zombie.instantiate()
	instance.position = spawn_point
	navigation_region.add_child(instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
