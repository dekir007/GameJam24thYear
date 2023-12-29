extends Node3D

func get_grabbed():
	Globals.stolen_gift_count += 1
	queue_free()
