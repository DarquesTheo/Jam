extends CharacterBody3D

var player = null
var state_machine
var hp = 14
var multiplier
var attack_damage = 10
var instance
var projectile = load("res://Enemy2/projectile.tscn")

const SPEED = 4
const ATTACK_RANGE = 10.0

@export var player_path := "/root/terrain/Player"

@onready var spawn_spell = $RayCast3D
@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(player_path)
	multiplier = get_parent().get_parent().multiplier
	hp = hp * multiplier
	attack_damage = attack_damage * multiplier
	state_machine = anim_tree.get("parameters/playback")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	velocity = Vector3.ZERO
	match state_machine.get_current_node():
		"Walk":
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			look_at(Vector3(global_position.x + velocity.x, global_position.y, global_position.z + velocity.z), Vector3.UP)
		"Attack":
			look_at(Vector3(player.global_position.x, player.global_position.y, player.global_position.z), Vector3.UP)
		"Die":
			anim_tree.root_motion_track = ""
			$walk.set_stream_paused(true)
		"End":
			queue_free()
	
	#Conditions
	if state_machine.get_current_node() != "Die":
		anim_tree.set("parameters/conditions/attack", _target_in_range())
		anim_tree.set("parameters/conditions/run", !_target_in_range())
	
	anim_tree.get("parameters/playback")
	
	move_and_slide()

func _target_in_range():
	if state_machine.get_current_play_position() > 3.4:
		state_machine.start("Attack", true)
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 2.0:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir, attack_damage)

func _on_area_3d_body_part_hit(dam):
	hp -= dam
	if hp <= 0:
		$Armature/Skeleton3D/head/Area3D/CollisionShape3D.disabled = true
		$Armature/Skeleton3D/whole_body/Area3D/CollisionShape3D.disabled = true
		$CollisionShape3D.disabled = true
		player.earn_money(10 * multiplier * 2)
		anim_tree.set("parameters/conditions/die", true)
		
func _cast_spell():
	instance = projectile.instantiate()
	instance.position = spawn_spell.global_position
	instance.transform.basis = spawn_spell.global_transform.basis
	get_parent().add_child(instance)
