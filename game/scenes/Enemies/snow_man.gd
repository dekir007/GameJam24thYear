extends CharacterBody3D

@export var target : Node
@export var speed : float = 350

@onready var death_spawner_component:  = $DeathSpawnerComponent as SpawnerComponent
@onready var damage_label_spawner_component:  = $DamageLabelSpawnerComponent as SpawnerComponent
@onready var health_component:  = $HealthComponent as HealthComponent
@onready var over_head: Marker3D = $OverHead

var can_dash = true
var dashing = false

func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	var dir = global_position.direction_to(target.global_position)
	#velocity = dir * speed * delta
	var vel = dir * speed * delta
	
	velocity = lerp(velocity, vel, delta*10)
	#velocity = velocity.move_toward(vel, vel.length_squared()/30)
	var dist = global_position.distance_to(target.global_position) 
	#print(self, dist)
	if dist > 5 and dist < 6:
		dash()
	
	look_at(target.global_position)
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
	pass

func _on_health_component_died() -> void:
	death_spawner_component.spawn(global_position, get_parent())
	queue_free()

func _on_hit_box_component_hit(hit_context: HitBoxComponent.HitContext) -> void:
	health_component.apply_damage(hit_context.damage)
	damage_label_spawner_component.spawn(over_head.global_position, get_parent(), {"amount" : hit_context.damage})
