extends CharacterBody3D

@export var speed : float

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var gift_spawner_component: = $GiftSpawnerComponent as SpawnerComponent
@onready var gift_timer: Timer = $GiftTimer

var targets : Array
var target : Node

var can_make_gift : bool = false
var wait : bool = false

func _ready() -> void:
	animation_player.play("walk")

func _physics_process(delta: float) -> void:
	if wait:
		return
	
	if target == null:
		target = targets.pick_random()
	
	var target_global_position = target.global_position
	
	nav_agent.target_position = target_global_position
	
	var dir = global_position.direction_to(nav_agent.get_next_path_position())
	#velocity = dir * speed * delta
	var vel = dir * speed * delta
	var vel_max = Vector3(30,0,30)
	velocity = clamp(vel, -vel_max, vel_max)
	
	look_at(target_global_position)
	move_and_slide()

func _on_gift_timer_timeout() -> void:
	can_make_gift = true


func _on_navigation_agent_3d_target_reached() -> void:
	if target.get_child_count() == 0 and can_make_gift and Globals.gift_count < 10:
		gift_spawner_component.spawn(target.global_position, target)
		Globals.gift_count += 1
		can_make_gift = false
		gift_timer.start()
	animation_player.stop()
	wait = true
	await get_tree().create_timer(1).timeout
	wait = false
	animation_player.play("walk")
	target = targets.pick_random()
