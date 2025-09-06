extends Node2D

@onready var boss: CharacterBody2D = %Boss
const GUCI = preload("res://scene/guci.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position.y = 512


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func spawner_guci():
	for i in range(5):
		var guci_right = GUCI.instantiate()
		guci_right.position.x = boss.position.x + 60 + 60 * i
		if guci_right.position.x < 880 and guci_right.position.x > -380:
			add_child(guci_right)
		var guci_left = GUCI.instantiate()
		guci_left.position.x = boss.position.x - 60 - 60 * i
		if guci_left.position.x < 880 and guci_left.position.x > -380:
			add_child(guci_left)
		await get_tree().create_timer(0.2).timeout
		
