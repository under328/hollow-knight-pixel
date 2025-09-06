extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite.play("default")
	collision_polygon.disabled = true

func open():
	animated_sprite.play("open")
	collision_polygon.disabled = true

func close():
	animated_sprite.play("close")
	collision_polygon.disabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
