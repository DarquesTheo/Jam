extends CharacterBody3D

const JUMP_VELOCITY = 3.0
const HIT_STAGGER = 4.0

#Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var neck := $Neck3
@onready var camera := $Neck3/Camera3D
@onready var hit_rect := $UI/HitRect
@onready var gun_camera := $Neck3/Camera3D/SubViewportContainer/SubViewport/GunCam

#GUN
@onready var gun_anim = $Neck3/Camera3D/full_ak/AnimationPlayer
@onready var gun_barrel = $Neck3/Camera3D/full_ak/RayCast3D

#Bullets
var bullet = load("res://Weapon/bullet.tscn")
var instance

#player statzs
var max_health : int = 100
var health : int = 100
var armor : int = 0
var walk_speed : float = 4.5
var health_regen : float = 0.0
var run_speed_amplifier : float = 1.45
var money : int = 0
var shooting : bool = false

#camera state
var shake_state = 0

#signal
signal player_hit

func get_max_health():
	return max_health

func het_health():
	return health

func get_armor():
	return armor
	
func get_walk_speed():
	return walk_speed

func get_health_regen():
	return health_regen

func get_money():
	return money

func set_max_health(value : int):
	max_health = value

func set_health(value: int):
	health = value

func set_armor(value : int):
	armor = value

func set_walk_speed(value : float):
	walk_speed = value

func set_health_regen(value : float):
	health_regen = value

func set_money(value : int):
	money = value

func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#camera rotation
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * 0.005)
			camera.rotate_x(-event.relative.y * 0.005)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-70), deg_to_rad(70))

func _input(event):
	if event.is_action_pressed("shoot"):
		shooting = true
	if event.is_action_released("shoot"):
		shooting = false
		
func shake_right():
	neck.rotation.z = lerp_angle(neck.rotation.z, deg_to_rad(-3), 0.05)

func shake_left():
	neck.rotation.z = lerp_angle(neck.rotation.z, deg_to_rad(3), 0.05)

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
	var forward : bool = Input.is_action_pressed("move_forward")
	var back : bool = Input.is_action_pressed("move_back")
	var right : bool = Input.is_action_pressed("move_right")
	var left : bool = Input.is_action_pressed("move_left")
	var speed = walk_speed
	if Input.is_action_pressed("sprint"):
		speed *= run_speed_amplifier

	if right:
		speed *= 0.8
		if not left:
			shake_right()
	elif left:
		speed *= 0.8
		shake_left()
	else:
		neck.rotation.z = lerp_angle(neck.rotation.z, deg_to_rad(0), 0.05)

	if back:
		speed = walk_speed * 0.5

	if Input.is_action_pressed("shoot"):
		speed *= 0.85
	if !is_on_floor():
		speed *= 0.8

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()
	
	RenderingServer.global_shader_parameter_set("player_pos", position)

func _process(_delta):
	gun_camera.global_transform = camera.global_transform
	if shooting == true:
		if !gun_anim.is_playing():
			gun_anim.play("shoot_ak")
			instance = bullet.instantiate()
			instance.position = gun_barrel.global_position
			instance.transform.basis = gun_barrel.global_transform.basis
			get_parent().add_child(instance)

func _ready():
	hit_rect.visible = false
	randomize()
	pass

func die():
	pass

func take_dmg(amount : int):
	health -= amount
	health = max(0, health)
	if health == 0:
		die()
	
#called when the player is hit
func hit(dir, attack_dmg: int):
	emit_signal("player_hit")
	
	#deal dmg to player
	take_dmg(attack_dmg)
	
	#do the knockback
	velocity += dir * HIT_STAGGER
	
	#put the screen in red
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false
