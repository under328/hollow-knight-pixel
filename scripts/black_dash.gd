extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var has_black_dash = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	has_black_dash = true


func spawn_blackdash() -> void:
	has_black_dash = false
	animated_sprite.play("black_dash")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !animated_sprite.is_playing():
		has_black_dash = true
