extends Node3D

@onready var marker_3d: Marker3D = $Marker3D
@onready var spawner_component: SpawnerComponent = $SpawnerComponent

func _ready() -> void:
	spawner_component.spawn(marker_3d.global_position)
	Globals.gift_count = get_tree().get_nodes_in_group("gift").size()

func _on_timer_timeout() -> void:
	spawner_component.spawn(marker_3d.global_position)
	if randi()% 3 == 2:
		$Timer.wait_time = .5
	else:
		$Timer.wait_time = 2
