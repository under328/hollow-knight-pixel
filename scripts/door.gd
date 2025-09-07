extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D

func _ready() -> void:
	animated_sprite.play("default")
	collision_polygon.disabled = true

func open():
	animated_sprite.play("open")
	collision_polygon.disabled = true

func close():
	animated_sprite.play("close")
	collision_polygon.disabled = false
