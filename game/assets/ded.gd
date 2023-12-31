extends CharacterBody3D


@export var SPEED : = 500.0
const JUMP_VELOCITY = 4.5

@onready var camera = $CameraRig/Camera3D
@onready var cursor: MeshInstance3D = $Cursor
@onready var camera_rig: Node3D = $CameraRig
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var marker_3d: Marker3D = $Marker3D
@onready var shoot_sound: AudioStreamPlayer = $ShootSound
@onready var shoot_timer: Timer = $ShootTimer
@onready var hud: CanvasLayer = $Hud

@onready var spawner_component:  = $SpawnerComponent as SpawnerComponent
@onready var health_component: = $HealthComponent as HealthComponent


var can_shoot : bool = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var init_dist : Vector3

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	init_dist = Vector3(0,17.2,7.2)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

#region Velocity Calculation
	var move_direction = Vector3()
	var camera_basis = camera.get_global_transform().basis
	if Input.is_action_pressed("move_up"):
		move_direction -= camera_basis.z
	elif Input.is_action_pressed("move_down"):
		move_direction += camera_basis.z
	if Input.is_action_pressed("move_left"):
		move_direction -= camera_basis.x
	elif Input.is_action_pressed("move_right"):
		move_direction += camera_basis.x
	move_direction.y = 0
	
	velocity = move_direction.normalized()*SPEED*delta
	if Input.is_action_pressed("shift"):
		velocity *= 1.5
#endregion
	
	if Input.is_action_pressed("click"):
		shoot()
	
	camera_follows_player()
	move_and_slide()
	look_at_cursor()
	
	handle_anim()

func handle_anim():
	if velocity.length_squared() > 0:
		var dot = get_global_transform().basis.z.dot(velocity)
		if get_global_transform().basis.z.dot(velocity) > 0:
			animation_player.play_backwards("walk")
		else:
			animation_player.play("walk")
	else:
		animation_player.play("idle")

func camera_follows_player():
	var player_pos = global_position
	camera_rig.global_position = player_pos+init_dist

func look_at_cursor():
	# Create a horizontal plane, and find a point where the ray intersects with it
	var player_pos = global_transform.origin
	var dropPlane  = Plane(Vector3(0, 1, 0), player_pos.y)
	# Project a ray from camera, from where the mouse cursor is in 2D viewport
	var ray_length = 1000
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var cursor_pos = dropPlane.intersects_ray(from,to)
	#print(mouse_pos,from, to, cursor_pos)
	
	
	if cursor_pos != null:
		# Set the position of cursor visualizer
		cursor.global_transform.origin = cursor_pos + Vector3(0,1,0)
		# Make player look at the cursor
		look_at(cursor_pos, Vector3.UP)

func shoot():
	if !can_shoot:
		return
	can_shoot = false
	spawner_component.spawn(marker_3d.global_position, self)
	shoot_sound.play()
	shoot_timer.start()

func _on_shoot_timer_timeout() -> void:
	can_shoot = true

func _on_hit_box_component_hit(hit_context: RefCounted) -> void:
	health_component.apply_damage(10)
	print("ded hit")

func _on_health_component_health_changed(upd: HealthUpdate) -> void:
	hud.texture_progress_bar.value = float(upd.cur_hp)/upd.max_hp * 100

func _on_health_component_died() -> void:
	Globals.game_over()
