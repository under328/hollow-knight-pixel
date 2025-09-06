extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_polygon: CollisionPolygon2D = $Hitbox/CollisionPolygon2D

# Called when the node enters the scene tree for the first time.


func _ready() -> void:
	animated_sprite.play("guci")
	await get_tree().create_timer(1.0).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
