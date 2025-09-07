extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var has_black_dash = true

func spawn_blackdash() -> void:
	has_black_dash = false
	animated_sprite.play("black_dash")
	
func _process(_delta: float) -> void:
	if !animated_sprite.is_playing():
		has_black_dash = true
