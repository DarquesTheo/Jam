extends CharacterBody3D

const JUMP_VELOCITY = 3.5
const HIT_STAGGER = 6.0

#Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var neck := $Neck3
@onready var camera := $Neck3/Camera3D
@onready var hit_rect := $UI/HitRect
@onready var flashlight := $Neck3/Camera3D/ak/Flashlight

#GUN
@onready var gun_anim = $Neck3/Camera3D/ak/AnimationPlayer
@onready var gun_barrel = $Neck3/Camera3D/ak/RayCast3D

#Bullets
var bullet = load("res://Weapon/bullet.tscn")
var instance

#player statzs
var max_health : int = 100
var health : int = 100
var armor : int = 0
var walk_speed : float = 4.5
var run_speed_amplifier : float = 1.45

#signal
signal player_hit 

func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

		if Input.is_action_pressed("shoot"):
			if !gun_anim.is_playing():
				gun_anim.play("shoot_ak")
				instance = bullet.instantiate()
				instance.position = gun_barrel.global_position
				instance.transform.basis = gun_barrel.global_transform.basis
				get_parent().add_child(instance)

	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#camera rotation
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * 0.01)
			camera.rotate_x(-event.relative.y * 0.01)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-50), deg_to_rad(60))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var speed = walk_speed
	if Input.is_action_pressed("sprint"):
		speed *= run_speed_amplifier
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()

func _ready():
	hit_rect.visible = false
	randomize()
	pass
	
func take_dmg(amount : int):
	health -= amount
	health = max(0, health)
	
#called when the player is hit
func hit(dir, attack_dmg: int):
	emit_signal("player_hit")
	
	#deal dmg to player
	take_dmg(attack_dmg)
	
	#put the screen in red
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false
	
	#do the knockback
	velocity += dir * HIT_STAGGER
