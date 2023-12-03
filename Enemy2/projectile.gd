extends Node3D

const SPEED = 15

@onready var ray = $RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	if ray.is_colliding():
		ray.enabled = false
		if ray.get_collider().is_in_group("player"):
			ray.get_collider().hit()
		queue_free()
		
func _on_timer_timeout():
	queue_free()
