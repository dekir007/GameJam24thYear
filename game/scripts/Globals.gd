extends Node

var gift_count : int = 0
var stolen_gift_count : int = 0

var score : int = 0 :
	set(val):
		score = val

var money : int = 0

var menu_theme_sound = preload("res://assets/sounds/Snowland Loop.wav")
var menu_theme_player : AudioStreamPlayer

func _ready() -> void:
	menu_theme_player = AudioStreamPlayer.new()
	menu_theme_player.stream = menu_theme_sound
	menu_theme_player.bus = "Music"
	add_child(menu_theme_player)

func start_playing():
	if !menu_theme_player.playing:
		menu_theme_player.play()
	
func stop_playing():
	menu_theme_player.stop()

func reset():
	gift_count = 0
	stolen_gift_count = 0
	score = 0

func game_over():
	var gameover_event = InputEventAction.new()
	gameover_event.action = "game_over"
	gameover_event.pressed = true
	Input.parse_input_event(gameover_event)


