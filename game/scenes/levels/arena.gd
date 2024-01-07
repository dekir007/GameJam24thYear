extends Node3D

@onready var spawner_component: = $SpawnerComponent as SpawnerComponent
@onready var snowmen_spawner_points: Node3D = $SnowmenSpawnerPoints
@onready var boss_spawner_component: = $BossSpawnerComponent as SpawnerComponent
@onready var magic_spawner_component: = $MagicSpawnerComponent as SpawnerComponent
@onready var bad_spawner_component: = $BadSpawnerComponent as SpawnerComponent
@onready var ded: = $ded as Ded
@onready var enemies: Node3D = $Enemies
@onready var battle_music: AudioStreamPlayer = $BattleMusic
@onready var victoty_music: AudioStreamPlayer = $VictotyMusic
@onready var gifts: Node3D = $gifts
@onready var belka: CharacterBody3D = $belka
@onready var deer_marker_3d: Marker3D = $DeerMarker3D

@onready var wave_timer: Timer = $WaveTimer

@onready var thief_timer: Timer = $ThiefTimer
@onready var boss_timer: Timer = $BossTimer
@onready var magic_timer: Timer = $MagicTimer
@onready var bad_timer: Timer = $BadTimer

const DEER = preload("res://ready/deer.tscn")

var difficulty : float = 1
var difficulty_enabled : bool = false

@export var wave : int = 0
var wave_offset : int = 0
@export var waves : Array[Wave]

func _ready() -> void:
	# TODO
	var AGILITY = load("res://scenes/ui/upgrade options/agility.tres")
	var DEFENSE = load("res://scenes/ui/upgrade options/defense.tres")
	var HEAL = load("res://scenes/ui/upgrade options/heal.tres")
	var HEALTH = load("res://scenes/ui/upgrade options/health.tres")
	var RELOAD = load("res://scenes/ui/upgrade options/reload.tres")
	var SPEED = load("res://scenes/ui/upgrade options/speed.tres")
	var STRENGTH = load("res://scenes/ui/upgrade options/strength.tres")
	AGILITY.level = 0
	DEFENSE.level = 0
	HEAL.level = 0
	HEALTH.level = 0
	RELOAD.level = 0
	SPEED.level = 0
	STRENGTH.level = 0
	
	belka.targets = gifts.get_children()
	#if OS.get_name() == "Web":
		#$DirectionalLight3D.light_color = Color(210,210,210)
		#$DirectionalLight3D.light_energy = 3.286
	#ded.upgrade_damage()
	#ded.upgrade_speed()
	#ded.upgrade_defense()
	#ded.upgrade_defense()
	#ded.upgrade_damage()
	#wave = 3
	#waves[0].global_time = 2
	#waves[1].global_time = 1
	#waves[2].global_time = 1
	#waves[3].global_time = 1
	ded.hud.upgrade_chosen_signal.connect(start_wave)
	start_wave()
	
	#spawner_component.spawn(snowmen_spawner_points.get_children().pick_random().global_position, enemies)
	
	Globals.gift_count = get_tree().get_nodes_in_group("gift").size()

func start_wave():
	ded.health_component.heal(50)
	battle_music.play()
	
	
	thief_timer.wait_time = waves[wave].thiefs
	bad_timer.wait_time = waves[wave].bads
	boss_timer.wait_time = waves[wave].boss
	magic_timer.wait_time = waves[wave].mage
	wave_timer.wait_time = waves[wave].global_time
	
	ded.hud.wave = wave + wave_offset
	ded.hud.start_timer(wave_timer.wait_time)
	wave_timer.start()
	if waves[wave].thiefs > 0:
		thief_timer.start()
	if waves[wave].bads > 0:
		bad_timer.start()
	if waves[wave].boss > 0:
		boss_timer.start()
	if waves[wave].mage > 0:
		magic_timer.start()
	

func stop_wave():
	wave += 1
	if wave > waves.size() - 1:
		wave_offset += 1
		wave = waves.size() - 1
		difficulty_enabled = true
		waves[wave].global_time = 120
	
	thief_timer.stop()
	bad_timer.stop()
	boss_timer.stop()
	magic_timer.stop()
	
	Globals.money += Globals.gift_count
	#get_tree().call_group("gift", "null")

func _on_thief_timer_timeout() -> void:
	spawner_component.spawn(snowmen_spawner_points.get_children().pick_random().global_position, enemies)
	if randi() % 3 == 2:
		thief_timer.wait_time = waves[wave].thiefs / 1.5 * difficulty
	else:
		thief_timer.wait_time = waves[wave].thiefs * difficulty
	if difficulty_enabled and difficulty > 0.5:
		difficulty -= 0.0033
	

func _on_boss_timer_timeout() -> void:
	boss_spawner_component.spawn(snowmen_spawner_points.get_children().pick_random().global_position, enemies)
	boss_timer.wait_time = waves[wave].boss * difficulty
	if difficulty_enabled and difficulty > 0.5:
		difficulty -= 0.0033


func _on_magic_timer_timeout() -> void:
	magic_spawner_component.spawn(snowmen_spawner_points.get_children().pick_random().global_position, enemies)
	magic_timer.wait_time = waves[wave].mage * difficulty
	if difficulty_enabled and difficulty > 0.5:
		difficulty -= 0.0033


func _on_bad_timer_timeout() -> void:
	bad_spawner_component.spawn(snowmen_spawner_points.get_children().pick_random().global_position, enemies)
	if randi() % 4 == 0:
		bad_timer.wait_time = waves[wave].bads / 1.5 * difficulty
	else:
		bad_timer.wait_time = waves[wave].bads * difficulty
	if difficulty_enabled and difficulty > 0.5:
		difficulty -= 0.0033

func _on_wave_timer_timeout() -> void:
	stop_wave()
	if enemies.get_child_count() == 0:
		battle_music.stop()
		victoty_music.play()
		await get_tree().create_timer(.5).timeout
		var deer = DEER.instantiate()
		deer.target = $DeerMarker3D2.global_position
		deer.hud = ded.hud
		deer_marker_3d.add_child(deer)
		deer.appear()
		#ded.hud.show_upgrades()


func _on_enemies_child_exiting_tree(_node: Node) -> void:
	if wave_timer.time_left == 0 and enemies.get_child_count() == 1:
		# wave ended
		battle_music.stop()
		victoty_music.play()
		await get_tree().create_timer(.5).timeout
		var deer = DEER.instantiate()
		deer.target = $DeerMarker3D2.global_position
		deer.hud = ded.hud
		deer_marker_3d.add_child(deer)
		deer.appear()
		#ded.hud.show_upgrades()
		# play sani and olenie animation
		# show upgrades
