extends CharacterBody3D

@export var target : Node
@export var speed : float = 350

@onready var death_spawner_component:  = $DeathSpawnerComponent as SpawnerComponent
@onready var damage_label_spawner_component:  = $DamageLabelSpawnerComponent as SpawnerComponent
@onready var health_component:  = $HealthComponent as HealthComponent
@onready var over_head: Marker3D = $OverHead
@onready var gift_pos: Marker3D = $GiftPos
@onready var gift_spawner_component:  = $GiftSpawnerComponent as SpawnerComponent
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var can_dash = true
var dashing = false

func _ready() -> void:
	#grab_gift()
	target = get_tree().get_nodes_in_group("gift").reduce(func(accum : Node3D, node : Node3D): return node if node.global_position.distance_to(global_position) < accum.global_position.distance_to(global_position) else accum)

func _physics_process(delta: float) -> void:
	if target == null:
		target = get_tree().get_nodes_in_group("gift").reduce(func(accum : Node3D, node : Node3D): return node if node.global_position.distance_to(global_position) < accum.global_position.distance_to(global_position) else accum)
		if target == null:
			target = get_tree().get_first_node_in_group("player")
	var target_global_position = target.global_position
	
	nav_agent.target_position = target_global_position
	
	var dir = global_position.direction_to(nav_agent.get_next_path_position())
	#velocity = dir * speed * delta
	var vel = dir * speed * delta
	
	velocity = lerp(velocity, vel, delta*10)
	#velocity = velocity.move_toward(vel, vel.length_squared()/30)
	var dist = global_position.distance_to(target_global_position) 
	#print(self, dist)
	if dist > 5 and dist < 6:
		dash()
	elif dist < 2:
		if target != null:
			if !has_gift() and target.is_in_group("gift"):
				grab_gift()
			elif target.is_in_group("escape_points"):
				put_gift()
	
	look_at(target_global_position)
	move_and_slide()

func dash():
	if can_dash:
		velocity *= 4
		dashing = true
		can_dash = false
		await get_tree().create_timer(.3).timeout
		dashing = false
		await get_tree().create_timer(1.7).timeout
		can_dash = true

func grab_gift():
	target.get_grabbed()
	var gift = gift_spawner_component.spawn(gift_pos.global_position, gift_pos) as Node3D
	gift.remove_from_group("gift")
	gift.scale /= 3
	
	target = get_tree().get_nodes_in_group("escape_points").pick_random()

func put_gift():
	var gift = gift_pos.get_child(0)
	gift.queue_free()
	target = get_tree().get_nodes_in_group("gift").reduce(func(accum : Node3D, node : Node3D): return node if node.global_position.distance_to(global_position) < accum.global_position.distance_to(global_position) else accum)
	Globals.stolen_gift_count -= 1
	Globals.gift_count -= 1
	if Globals.gift_count == 0:
		Globals.game_over()

func has_gift():
	return gift_pos.get_child_count() > 0

func _on_health_component_died() -> void:
	death_spawner_component.spawn(global_position, get_parent())
	Globals.score += 10
	if has_gift(): # + Vector3.UP * 5
		gift_spawner_component.spawn(global_position , get_tree().current_scene)
		Globals.stolen_gift_count -= 1
	queue_free()

func _on_hit_box_component_hit(hit_context: HitBoxComponent.HitContext) -> void:
	health_component.apply_damage(hit_context.damage)
	damage_label_spawner_component.spawn(over_head.global_position, get_parent(), {"amount" : hit_context.damage})
