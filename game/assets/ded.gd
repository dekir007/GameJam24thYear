extends CharacterBody3D
class_name Ded

@export var SPEED : = 500.0
@export var damage : Damage #= Damage.new(5,0)


const JUMP_VELOCITY = 4.5

@onready var camera = $CameraRig/Camera3D
@onready var cursor: MeshInstance3D = $Cursor
@onready var camera_rig: Node3D = $CameraRig
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var marker_3d: Marker3D = $Marker3D
@onready var shoot_sound: AudioStreamPlayer = $ShootSound
@onready var shoot_timer: Timer = $ShootTimer
@onready var hud: CanvasLayer = $Hud
@onready var hit_sound: AudioStreamPlayer = $HitSound
@onready var over_head: Marker3D = $OverHead

@onready var spawner_component:  = $SpawnerComponent as SpawnerComponent
@onready var health_component: = $HealthComponent as HealthComponent
@onready var hit_box_component:  = $HitBoxComponent as HitBoxComponent
@onready var damage_label_spawner_component:  = $DamageLabelSpawnerComponent as SpawnerComponent


var can_shoot : bool = true

var can_dash : bool = true
var dashing : bool = false
var dash_cooldown : float = 1.7

var shift_pressed : bool = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var init_dist : Vector3

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	init_dist = Vector3(0,17.2,7.2)
	
	hud.upgrade_chosen_signal.connect(func(): 
		if shift_pressed:
			SPEED /= 1.5
			shift_pressed = false
		)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	#print(transform.basis.z.normalized())
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

#region Velocity Calculation
	if !dashing:
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
		
		var max_vel = Vector3(1,0,1) * 30
		var vel = move_direction.normalized()*SPEED*delta
		velocity = clamp((velocity.move_toward(vel, get_process_delta_time()*200)), -max_vel, max_vel)
	
	if Input.is_action_just_pressed("shift") and !shift_pressed:
		shift_pressed = true
		SPEED *= 1.5
		print(SPEED)
	if Input.is_action_just_released("shift") and shift_pressed:
		shift_pressed = false
		SPEED /= 1.5
		print(SPEED)
#endregion
	
	if Input.is_action_pressed("click"):
		shoot()
	
	if Input.is_action_just_pressed("dash"):
		dash()
	
	camera_follows_player()
	move_and_slide()
	look_at_cursor()
	
	handle_anim()

func dash():
	if can_dash:
		#var tw = get_tree().create_tween()
		#tw.tween_property(self, "SPEED", 500, .3).from(2500).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
		velocity *= 5
		print(velocity)
		var length = 40
		velocity = velocity.clamp(Vector3(-1,0,-1)*length, Vector3(1,0,1)*length)
		print(velocity, " ",velocity.length())
		dashing = true
		can_dash = false
		var tw = get_tree().create_tween()
		tw.tween_property(hud.dash_progress_bar, "value", 0, 0.2).from(100)
		tw.play()
		await get_tree().create_timer(.2).timeout
		dashing = false
		velocity /= 5
		tw = get_tree().create_tween()
		tw.tween_property(hud.dash_progress_bar, "value", 100, dash_cooldown).from(0)
		tw.play()
		await get_tree().create_timer(dash_cooldown).timeout
		can_dash = true

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
	camera_rig.global_position = lerp(camera_rig.global_position, player_pos+init_dist, 0.3)

func look_at_cursor():
	# Create a horizontal plane, and find a point where the ray intersects with it
	var player_pos = global_transform.origin
	var dropPlane  = Plane(Vector3(0, 1, 0), player_pos.y)
	# Project a ray from camera, from where the mouse cursor is in 2D viewport
	var ray_length = 1000
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var cursor_pos = dropPlane.intersects_ray(from,to) as Vector3
	#print(mouse_pos,from, to, cursor_pos)
	
	
	if cursor_pos != null:
		# Set the position of cursor visualizer
		cursor.global_position = cursor_pos + Vector3(0,1,0)
		# Make player look at the cursor
		look_at(cursor_pos)#.rotated(Vector3.UP, -PI/260))
		#print(marker_3d.global_position.signed_angle_to(cursor.global_position.project(marker_3d.global_position), Vector3.UP))

func shoot():
	if !can_shoot:
		return
	can_shoot = false
	spawner_component.spawn(marker_3d.global_position, self, damage)
	shoot_sound.play()
	shoot_timer.start()

func _on_shoot_timer_timeout() -> void:
	can_shoot = true

func _on_hit_box_component_hit(hit_context: HitBoxComponent.HitContext) -> void:
	health_component.apply_damage(hit_context.damage)
	hud.show_red()
	hit_sound.play()
	damage_label_spawner_component.spawn(over_head.global_position, get_parent(), {"amount" : hit_context.damage})

func _on_health_component_health_changed(upd: HealthUpdate) -> void:
	hud.health_bar.value = float(upd.cur_hp)/upd.max_hp * 100
	hud.health_label.text = "%s/%s" % [upd.cur_hp, upd.max_hp]

func _on_health_component_died() -> void:
	Globals.game_over()

func upgrade_dash():
	dash_cooldown -= 0.2

func upgrade_speed():
	SPEED += 75 * (1.5 if shift_pressed else 1)
	#print(SPEED)

func upgrade_damage():
	damage.damage += 1
	damage.penetration += .15
	print("damage ", damage.damage)

func upgrade_defense():
	hit_box_component.defense.defense += 0.12
	print("defense ", hit_box_component.defense.defense)

func upgrade_reload():
	shoot_timer.wait_time -= 0.02
	
func upgrade_heal():
	health_component.heal(25)

func upgrade_max_health():
	health_component.max_health += 15
	health_component.heal(15)
	print("max_health ", health_component.max_health)
