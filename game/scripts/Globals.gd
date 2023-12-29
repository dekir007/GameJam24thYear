extends Node

var gift_count : int = 0
var stolen_gift_count : int = 0

var score : int = 0

func game_over():
	var gameover_event = InputEventAction.new()
	gameover_event.action = "game_over"
	gameover_event.pressed = true
	Input.parse_input_event(gameover_event)
