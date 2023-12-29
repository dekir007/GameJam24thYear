extends Node3D

@onready var marker_3d: Marker3D = $Marker3D
@onready var spawner_component: SpawnerComponent = $SpawnerComponent

func _ready() -> void:
	spawner_component.spawn(marker_3d.global_position)

func _on_timer_timeout() -> void:
	spawner_component.spawn(marker_3d.global_position)
