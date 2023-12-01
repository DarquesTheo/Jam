extends Node

class_name EntitiesStats

var max_health : int
var health : int
var speed : float
var armor : int

func _init():
	self.max_health = 0
	self.health = 0
	self.speed = 0
	self.armor = 0

func set_max_health(new_max_health : int):
	self.max_health = new_max_health

func set_health(new_health : int):
	self.health = new_health

func set_speed(new_speed : float):
	self.speed = new_speed

func set_armor(new_armor : int):
	self.armor = new_armor
	
func get_max_health() -> int:
	return self.max_health
	
func get_health() -> int:
	return self.health

func get_speed() -> float:
	return self.speed
	
func get_armor() -> int:
	return self.armor

func take_damage(amount : int):
	self.health -= amount
	self.health = max(0, self.health)
	emit_signal("health_changed", self.health)
	
func heal(amount : int):
	self.health += self.amount
	self.health = min(self.health, self.max_health)
	emit_signal("health_changed", self.health)
	
func calculate_armor_reduction() -> float:
	var damage_mitigation : float
	damage_mitigation = self.armor
	return damage_mitigation

# Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
