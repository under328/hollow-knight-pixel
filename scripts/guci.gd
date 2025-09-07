extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_polygon: CollisionPolygon2D = $Hitbox/CollisionPolygon2D

func _ready() -> void:
	animated_sprite.play("guci")
	await get_tree().create_timer(1.0).timeout
	queue_free()
