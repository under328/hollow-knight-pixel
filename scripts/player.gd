extends CharacterBody2D

# 定义状态机
enum State{NORMAL, DASH, ATTACK, ATTACK_UP, ATTACK_DOWN, ATTACK_JUMP, HURT}
# 当前状态
var currentState = State.NORMAL

@onready var black_dash: Node2D = $BlackDash
@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var attack_1: Hitbox = $Attack1
@onready var attack_2: Hitbox = $Attack2
@onready var attack_up: Hitbox = $AttackUp
@onready var attack_down: Hitbox = $AttackDown
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var wudi_timer: Timer = $WudiTimer

const SPEED = 560
const JUMP_VELOCITY = -800.0
var direction := 0.0
var isStateNew = false
var can_dash = true
var jump_count = 1
var attack_index = 0
var hurt_direction := 0.0

func _process(delta):
	match currentState:
		State.NORMAL:
			process_normal(delta)
		State.DASH:
			process_dash(delta)
		State.ATTACK:
			process_attack(delta)
		State.ATTACK_UP:
			process_attack_up(delta)
		State.ATTACK_DOWN:
			process_attack_down(delta)
		State.ATTACK_JUMP:
			process_attack_jump(delta)
		State.HURT:
			process_hurt(delta)
			
	move_and_slide()
	isStateNew = false

# 更改状态
func change_state(newState):
	currentState = newState
	isStateNew = true

# 更改角色方向
func turn_direction():
	if direction < 0:
		animated_sprite.scale.x = -1.0
		attack_1.scale.x = -1.0
		attack_2.scale.x = -1.0
		attack_up.scale.x = -1.0
		attack_down.scale.x = -1.0
	elif direction > 0:
		animated_sprite.scale.x = 1.0
		attack_1.scale.x = 1.0
		attack_2.scale.x = 1.0
		attack_up.scale.x = 1.0
		attack_down.scale.x = 1.0
		
func update_animation():
	animated_sprite.offset.x = 0
	# 更新动画
	if !is_on_floor():
		if jump_count == 2 and Input.is_action_pressed("jump"):
			animated_sprite.play("double_jump")
		else:
			if velocity.y < 0:
				animated_sprite.play("jump_up")
			else:
				animated_sprite.play("jump_down")
	elif direction != 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
	turn_direction()
	
func process_normal(delta: float) -> void:
	direction = Input.get_axis("left", "right")
	update_animation()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 2.0
	else:
		jump_count = 1
		can_dash = true
	# Handle jump.
	if jump_count < 2 and Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		else:
			velocity.y = JUMP_VELOCITY
			jump_count = 2
		# 短按减速
	if velocity.y < 0  and Input.is_action_just_released("jump"):
		velocity.y =  JUMP_VELOCITY / 2
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if Input.is_action_just_pressed("dash") and can_dash:
		can_dash = false
		call_deferred("change_state", State.DASH)
	if Input.is_action_just_pressed("attack") and attack_timer.is_stopped():
		call_deferred("change_state", State.ATTACK)
	if Input.is_action_just_pressed("attack") and Input.get_action_strength("up") and attack_timer.is_stopped():
		call_deferred("change_state", State.ATTACK_UP)
	if Input.is_action_just_pressed("attack") and Input.get_action_strength("down") and !is_on_floor() and attack_timer.is_stopped():
		call_deferred("change_state", State.ATTACK_DOWN)

func process_dash(delta):
	var has_black_dash = black_dash.has_black_dash
	if isStateNew:
		if animated_sprite.scale.x == -1.0:
			animated_sprite.offset.x = 16
		else:
			animated_sprite.offset.x = -16
		if has_black_dash:
			hurtbox.get_node("CollisionShape2D").disabled = true
			black_dash.spawn_blackdash()
			animated_sprite.play("black_sprint")
		else:
			animated_sprite.play("sprint")
		velocity.x = direction * SPEED * 3.6
		velocity.y = 0
	velocity.x = lerp(0.0, velocity.x, pow(2.0, -6 * delta))
	if !animated_sprite.is_playing():
		if wudi_timer.is_stopped():
			hurtbox.get_node("CollisionShape2D").disabled = false
		call_deferred("change_state", State.NORMAL)

func process_attack(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta * 2.0
	if isStateNew:
		if attack_index == 0:
			animated_sprite.play("attack1")
			attack_1.get_node("CollisionPolygon2D").disabled = false
		else:
			animated_sprite.play("attack2")
			attack_2.get_node("CollisionPolygon2D").disabled = false
	if !animated_sprite.is_playing():
		attack_1.get_node("CollisionPolygon2D").disabled = true
		attack_2.get_node("CollisionPolygon2D").disabled = true
		attack_timer.start()
		attack_index = 1 - attack_index
		call_deferred("change_state", State.NORMAL)
	if Input.is_action_just_pressed("dash") and can_dash:
		can_dash = false
		call_deferred("change_state", State.DASH)
	
func process_attack_up(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta * 2.0
	if isStateNew:
		animated_sprite.play("attack_up")
		attack_up.get_node("CollisionPolygon2D").disabled = false
	if !animated_sprite.is_playing():
		attack_up.get_node("CollisionPolygon2D").disabled = true
		attack_timer.start()
		call_deferred("change_state", State.NORMAL)
	if Input.is_action_just_pressed("dash") and can_dash:
		can_dash = false
		call_deferred("change_state", State.DASH)
	
func process_attack_down(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta * 2.0
	if isStateNew:
		animated_sprite.play("attack_down")
		attack_down.get_node("CollisionPolygon2D").disabled = false
	if !animated_sprite.is_playing():
		attack_down.get_node("CollisionPolygon2D").disabled = true
		attack_timer.start()
		call_deferred("change_state", State.NORMAL)
	if Input.is_action_just_pressed("dash") and can_dash:
		can_dash = false
		call_deferred("change_state", State.DASH)

func process_attack_jump(_delta):
	if isStateNew:
		can_dash = true
		jump_count = 1
		velocity.x = 0
		velocity.y = -560
	if velocity.y <= -140:
		call_deferred("change_state", State.NORMAL)
	if Input.is_action_just_pressed("dash") and can_dash:
		can_dash = false
		call_deferred("change_state", State.DASH)

func process_hurt(_delta) -> void:
	if isStateNew:
		wudi()
		velocity.x = -300 if hurt_direction == 1 else 300
		velocity.y = -300
		if hurt_direction < 0:
			animated_sprite.scale.x = -1.0
		elif hurt_direction > 0:
			animated_sprite.scale.x = 1.0
		animated_sprite.play("hurt")
	if !animated_sprite.is_playing():
		call_deferred("change_state", State.NORMAL)

func wudi():
	hurtbox.get_node("CollisionShape2D").disabled = true
	wudi_timer.start()
	# 小骑士闪烁
	while true:
		animated_sprite.visible = false
		await get_tree().create_timer(0.06).timeout
		animated_sprite.visible = true
		await get_tree().create_timer(0.06).timeout
		if wudi_timer.is_stopped():
			hurtbox.get_node("CollisionShape2D").disabled = false
			break

func _on_hurtbox_area_entered(area: Area2D) -> void:
	# 受击回弹
	if area.global_position.x > global_position.x:
		hurt_direction = 1
	else:
		hurt_direction = -1
	
	call_deferred("change_state", State.HURT)

func _on_attack_1_area_entered(_area: Area2D) -> void:
	if animated_sprite.scale.x == 1.0:
		global_position.x -= 10
	else:
		global_position.x += 10


func _on_attack_2_area_entered(_area: Area2D) -> void:
	if animated_sprite.scale.x == 1.0:
		global_position.x -= 10
	else:
		global_position.x += 10


func _on_attack_up_area_entered(_area: Area2D) -> void:
	pass # Replace with function body.


func _on_attack_down_area_entered(_area: Area2D) -> void:
	call_deferred("change_state", State.ATTACK_JUMP)
