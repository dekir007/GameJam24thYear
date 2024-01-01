extends Node3D

@onready var spawner_component: SpawnerComponent = $SpawnerComponent
@onready var snowmen_spawner_points: Node3D = $SnowmenSpawnerPoints
@onready var boss_spawner_component: SpawnerComponent = $BossSpawnerComponent

var difficulty : float = 1

func _ready() -> void:
	#if OS.get_name() == "Web":
		#$DirectionalLight3D.light_color = Color(210,210,210)
		#$DirectionalLight3D.light_energy = 3.286
	
	spawner_component.spawn(snowmen_spawner_points.get_children().pick_random().global_position)
	Globals.gift_count = get_tree().get_nodes_in_group("gift").size()

func _on_timer_timeout() -> void:
	spawner_component.spawn(snowmen_spawner_points.get_children().pick_random().global_position)
	if randi()% 3 == 2:
		$Timer.wait_time = 1.25 * difficulty
	else:
		$Timer.wait_time = 4 * difficulty
	if difficulty < 0.3:
		difficulty -= 0.01
	

func _on_boss_timer_timeout() -> void:
	boss_spawner_component.spawn(snowmen_spawner_points.get_children().pick_random().global_position)
