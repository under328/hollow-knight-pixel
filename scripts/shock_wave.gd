extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction = 0

func _ready() -> void:
	animated_sprite.play("shock_wave")
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _process(_delta: float) -> void:
	if direction == 1:
		velocity.x = -1000
	elif direction == -1:
		velocity.x = 1000
	move_and_slide()
