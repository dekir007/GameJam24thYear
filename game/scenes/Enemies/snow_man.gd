extends CharacterBody3D

@export var target : Node
@export var speed : float = 350

@onready var death_spawner_component:  = $DeathSpawnerComponent as SpawnerComponent
@onready var damage_label_spawner_component:  = $DamageLabelSpawnerComponent as SpawnerComponent
@onready var health_component:  = $HealthComponent as HealthComponent
@onready var over_head: Marker3D = $OverHead

func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	var dir = global_position.direction_to(target.global_position)
	velocity = dir * speed * delta
	
	look_at(target.global_position)
	move_and_slide()

func get_hit():
	health_component.apply_damage(2)

func _on_health_component_died() -> void:
	death_spawner_component.spawn(global_position, get_parent())
	queue_free()

func _on_health_component_health_changed(upd: HealthUpdate) -> void:
	damage_label_spawner_component.spawn(over_head.global_position, get_parent(), {"amount" : -(upd.cur_hp-upd.prev_hp)})
