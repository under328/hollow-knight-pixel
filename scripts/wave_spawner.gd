extends Node2D

@onready var boss: CharacterBody2D = %Boss
const SHOCK_WAVE = preload("res://scene/shock_wave.tscn")

func _ready() -> void:
	global_position.y = boss.global_position.y
	
func spawner_wave_left():
	print("l")
	var wave_left = SHOCK_WAVE.instantiate()
	wave_left.position.x = boss.position.x - 32
	wave_left.scale.x = 1.0
	wave_left.direction = 1
	add_child(wave_left)
	
func spawner_wave_right():
	print("r")
	var wave_right = SHOCK_WAVE.instantiate()
	wave_right.position.x = boss.position.x + 32
	wave_right.scale.x = -1.0
	wave_right.direction = -1
	add_child(wave_right)
