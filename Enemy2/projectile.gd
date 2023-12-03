extends Node3D

const SPEED = 15

var player_path = "/root/terrain/Player"
var player
var attack_damage = 10

@onready var ray = $RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready(): 
	player = get_node(player_path)
	pass # Replace with function body.

func _process(delta):
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	if ray.is_colliding():
		ray.enabled = false
		if ray.get_collider().is_in_group("player"):
			var dir = global_position.direction_to(player.global_position)
			player.hit(dir, attack_damage)
		queue_free()
		
func _on_timer_timeout():
	queue_free()
