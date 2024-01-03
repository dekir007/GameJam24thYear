extends CanvasLayer

signal upgrade_chosen_signal

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var label: Label = $Label
@onready var health_orb: Control = $HealthOrb
@onready var health_orb_bar: TextureProgressBar = $HealthOrb/HealthOrbBar
@onready var dash_progress_bar: TextureProgressBar = $DashProgressBar
@onready var get_hit: TextureRect = $GetHit
@onready var time_label: Label = $TimeLabel
@onready var upgrades: HBoxContainer = %Upgrades
@onready var upgrades_container: PanelContainer = $UpgradesContainer
@onready var money_label: Label = %MoneyLabel

const UPGRADE_OPTION = preload("res://scenes/ui/upgrade_option.tscn")

@export var upgrades_options : Array[UpgradeOptionData]

var time_left : int
var wave : int

func _ready() -> void:
	upgrades_container.hide()
	#show_upgrades()
	get_hit.show()
	health_orb.hide()
	get_hit.modulate.a = 0

func _process(_delta: float) -> void:
	label.text = "FPS: %s\nGifts: %s (%s stolen!)\nScore: %s" % [Engine.get_frames_per_second(), Globals.gift_count, Globals.stolen_gift_count,Globals.score]

func show_red():
	var tw = get_tree().create_tween()
	tw.tween_property(get_hit, "modulate:a", float(150)/256, .2).from(0.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tw.tween_property(get_hit, "modulate:a", 0, .2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tw.play()

func start_timer(time:int):
	time_left=time
	time_label.text = "Wave: " + str(wave+1) + ". Time left: " + str(time_left)
	$Timer.start()

func _on_timer_timeout() -> void:
	if time_left > 0:
		time_left -= 1
		time_label.text = "Wave: " + str(wave+1) + ". Time left: " + str(time_left)
	else:
		$Timer.stop()

func show_upgrades():
	get_tree().paused = true
	money_label.text = "Coins left: " + str(Globals.money)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	upgrades_container.show()
	if upgrades.get_child_count() == 0:
		for upgrade_data in upgrades_options:
			var upgrade = UPGRADE_OPTION.instantiate()
			upgrade.data = upgrade_data
			var title = upgrade_data.title.to_lower().replace(' ', '_')
			var callable = (get_parent() as Ded).get("upgrade_%s"%[title])
			upgrades.add_child(upgrade)
			upgrade.upgrade.connect(callable)
			upgrade.upgrade.connect(upgrade_chosen)#.bind(title))

func upgrade_chosen():#(title : String):
	money_label.text = "Coins left: " + str(Globals.money)


func _on_close_button_up() -> void:
	upgrades_container.hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	upgrade_chosen_signal.emit()
