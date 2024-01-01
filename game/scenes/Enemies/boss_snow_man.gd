extends CharacterBody3D

@export var target : Node
@export var speed : float = 350
@export var damage : Damage

@onready var death_spawner_component:  = $DeathSpawnerComponent as SpawnerComponent
@onready var damage_label_spawner_component:  = $DamageLabelSpawnerComponent as SpawnerComponent
@onready var health_component:  = $HealthComponent as HealthComponent
@onready var over_head: Marker3D = $OverHead
@onready var gift_pos: Marker3D = $GiftPos
@onready var gift_spawner_component: = $GiftSpawnerComponent as SpawnerComponent
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var audio_grabbed: AudioStreamPlayer = $AudioGrabbed
@onready var audio_put: AudioStreamPlayer = $AudioPut
@onready var progress_bar:  = $OverHead/ProgressBar as ProgressBar3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var frost_ray: Node3D = $GiftPos/FrostRay

const ICICLE = preload("res://scenes/objects/icicle.tscn")

var can_dash = true
var dashing = false

var is_player_in_range : bool = false

func _ready() -> void:
	animation_player.play("bad walk")
	#grab_gift()
	if damage == null:
		damage = Damage.new()
		damage.damage = 5
	target = get_tree().get_first_node_in_group("player")#get_tree().get_nodes_in_group("gift").reduce(func(accum : Node3D, node : Node3D): return node if node.global_position.distance_to(global_position) < accum.global_position.distance_to(global_position) else accum)
	frost_ray.target = target

func _physics_process(delta: float) -> void:
	#if target == null:
		#target = get_tree().get_nodes_in_group("gift").reduce(func(accum : Node3D, node : Node3D): return node if node.global_position.distance_to(global_position) < accum.global_position.distance_to(global_position) else accum)
		#if target == null:
			#target = get_tree().get_first_node_in_group("player")
	var target_global_position = target.global_position
	
	nav_agent.target_position = target_global_position
	
	var dir = global_position.direction_to(nav_agent.get_next_path_position())
	#velocity = dir * speed * delta
	var vel = dir * speed * delta
	nav_agent.set_velocity(vel)
	
	#velocity = velocity.move_toward(vel, vel.length_squared()/30)
	var dist = global_position.distance_to(target_global_position) 
	#print(self, dist)
	if dist > 5 and dist < 6:
		dash()
	elif dist < 2:
		pass
	
	look_at(target_global_position)

func dash():
	if can_dash:
		velocity *= 4
		dashing = true
		can_dash = false
		await get_tree().create_timer(.3).timeout
		dashing = false
		await get_tree().create_timer(1.7).timeout
		can_dash = true

func _on_health_component_died() -> void:
	death_spawner_component.spawn(global_position, get_parent())
	Globals.score += 100
	var num = randi_range(6, 12)
	for i in range(num):
		var a = PI * i * (2. / num)
		var dir = Vector3.FORWARD.rotated(Vector3.UP, a)
		var icicle = ICICLE.instantiate()
		icicle.dir = dir #global_position.direction_to(get_tree().get_first_node_in_group("player").global_position)
		icicle.speed = 10
		icicle.damage = Damage.new()
		icicle.damage.damage = randi_range(5, 15)
		get_parent().add_child(icicle)
		icicle.global_position = global_position
	
	
	queue_free()

func _on_hit_box_component_hit(hit_context: HitBoxComponent.HitContext) -> void:
	health_component.apply_damage(hit_context.damage)
	damage_label_spawner_component.spawn(over_head.global_position, get_parent(), {"amount" : hit_context.damage})

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	var vel_max = Vector3(30,30,30) # снеговики могут улететь в стратосферу, когда сверху перса
	velocity = clamp(lerp(velocity, safe_velocity, get_process_delta_time() * 10), -vel_max, vel_max)
	move_and_slide()


func _on_navigation_agent_3d_target_reached() -> void:
	if target != null:
		print("boss reached ded")
		animation_player.play("bad attack")


func _on_health_component_health_changed(upd: HealthUpdate) -> void:
	progress_bar.value = float(upd.cur_hp) / upd.max_hp 

func hit():
	if is_player_in_range:
		# TODO with hit box
		target.hit_box_component.get_hit(damage)

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if !animation_player.is_playing():
		animation_player.play("bad walk")

func _on_check_player_body_entered(_body: Node3D) -> void:
	is_player_in_range = true

func _on_check_player_body_exited(_body: Node3D) -> void:
	is_player_in_range = false
