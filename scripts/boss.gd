extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

func _on_hurtbox_area_entered(area: Area2D) -> void:
	timer.start()
	animated_sprite.use_parent_material = false


func _on_timer_timeout() -> void:
	animated_sprite.use_parent_material = true
