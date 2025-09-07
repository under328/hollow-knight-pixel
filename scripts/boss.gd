extends CharacterBody2D

# 定义状态机
enum State{READY, IDLE, SLASH, SLASH_PLAN, PICK_UP, PICK_UP_PLAN,
 RUN, JUMP_UP, JUMP_DOWN, JUMP2, PUNCH_PLAN, PUNCH, PUNCH_END, 
BACK_JUMP_UP, BACK_JUMP_DOWN, SHOCK_WAVE, DASH_PLAN, DASH, DASH_END}
# 当前状态
var currentState = State.READY

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var slash_box: Hitbox = $SlashBox
@onready var pick_up_box: Hitbox = $PickUpBox
@onready var door: CharacterBody2D = %Door
@onready var player: CharacterBody2D = %Player
@onready var guci_spawner: Node2D = %GuciSpawner
@onready var wave_spawner: Node2D = %WaveSpawner
@onready var dash_box: Hitbox = $DashBox

const SPEED = 560
const JUMP_VELOCITY = -720.0
var isStateNew = false

func _process(delta):
	match currentState:
		State.READY:
			process_ready(delta)
		State.IDLE:
			process_idle(delta)
		State.SLASH:
			process_slash(delta)
		State.SLASH_PLAN:
			process_slash_plan(delta)
		State.PICK_UP:
			process_pick_up(delta)
		State.PICK_UP_PLAN:
			process_pick_up_plan(delta)
		State.RUN:
			process_run(delta)
		State.JUMP_UP:
			process_jump_up(delta)
		State.JUMP_DOWN:
			process_jump_down(delta)
		State.JUMP2:
			process_jump2(delta)
		State.PUNCH_PLAN:
			process_punch_plan(delta)
		State.PUNCH:
			process_punch(delta)
		State.PUNCH_END:
			process_punch_end(delta)
		State.BACK_JUMP_UP:
			process_back_jump_up(delta)
		State.BACK_JUMP_DOWN:
			process_back_jump_down(delta)
		State.SHOCK_WAVE:
			process_shock_wave(delta)
		State.DASH_PLAN:
			process_dash_plan(delta)
		State.DASH:
			process_dash(delta)
		State.DASH_END:
			process_dash_end(delta)
	isStateNew = false

# 更改状态
func change_state(newState):
	currentState = newState
	isStateNew = true

# 更改角色方向
func turn_direction():
	if global_position.x < player.global_position.x:
		animated_sprite.scale.x = 1.0
		slash_box.scale.x = 1.0
		pick_up_box.scale.x = 1.0
		dash_box.scale.x = 1.0
	else:
		animated_sprite.scale.x = -1.0
		slash_box.scale.x = -1.0
		pick_up_box.scale.x = -1.0
		dash_box.scale.x = -1.0

func process_ready(_delta: float) -> void:
	animated_sprite.play("idel")
	if player.global_position.x < 960:
		door.close()
		call_deferred("change_state", State.IDLE)

func process_idle(_delta: float) -> void:
	turn_direction()
	if isStateNew:
		animated_sprite.play("idel")
	if !animated_sprite.is_playing():
		if randf() > 0.3: # 0.3
			if abs(player.global_position.x - global_position.x) < 320:
				call_deferred("change_state", State.SLASH_PLAN)
			else:
				if randf() > 0.5:
					call_deferred("change_state", State.RUN)
				else:
					call_deferred("change_state", State.JUMP_UP)
		else:
			if randf() > 0.5: # 0.5
				call_deferred("change_state", State.JUMP2)
			else:
				call_deferred("change_state", State.BACK_JUMP_UP)
				
func process_slash_plan(_delta: float) -> void:
	if isStateNew:
		velocity.x = 0
		animated_sprite.play("slash_plan")
	if !animated_sprite.is_playing():
		call_deferred("change_state", State.SLASH)
		
func process_slash(_delta: float) -> void:
	if isStateNew:
		if slash_box.scale.x == 1.0:
			velocity.x = SPEED * 2
		else:
			velocity.x = -SPEED * 2
		velocity.y = 0
		slash_box.get_node("CollisionPolygon2D").disabled = false
		animated_sprite.play("slash")
	if !animated_sprite.is_playing():
		slash_box.get_node("CollisionPolygon2D").disabled = true
		turn_direction()
		call_deferred("change_state", State.PICK_UP_PLAN)
		
func process_pick_up_plan(_delta: float) -> void:
	if isStateNew:
		velocity.x = 0
		animated_sprite.play("pick_up_plan")
	if !animated_sprite.is_playing():
		call_deferred("change_state", State.PICK_UP)
				
func process_pick_up(_delta: float) -> void:
	if isStateNew:
		if slash_box.scale.x == 1.0:
			velocity.x = 160
		else:
			velocity.x = -160
		velocity.y = JUMP_VELOCITY
		pick_up_box.get_node("CollisionPolygon2D").disabled = false
		animated_sprite.play("pick_up")
	if !animated_sprite.is_playing():
		pick_up_box.get_node("CollisionPolygon2D").disabled = true
		call_deferred("change_state", State.JUMP_DOWN)
				
func process_run(_delta: float) -> void:
	if isStateNew:
		if player.global_position.x > global_position.x:
			velocity.x = 240
		else:
			velocity.x = -240
		velocity.y = 0
		animated_sprite.play("run")
	if abs(player.global_position.x - global_position.x) < 160:
		call_deferred("change_state", State.SLASH_PLAN)

func process_jump_up(_delta: float) -> void:
	if isStateNew:
		velocity.x = (player.global_position.x - global_position.x) / 0.8
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("jump_up")
	if velocity.y > 0:
		call_deferred("change_state", State.JUMP_DOWN)

func process_jump_down(_delta: float) -> void:
	if isStateNew:
		animated_sprite.play("jump_down")
	if is_on_floor():
		velocity.x = 0
		call_deferred("change_state", State.IDLE)

func process_back_jump_up(_delta: float) -> void:
	if isStateNew:
		if player.global_position.x > 300:
			velocity.x = (-380 - global_position.x) /0.8
		else:
			velocity.x = (890 - global_position.x) /0.8
		velocity.y = JUMP_VELOCITY
		if velocity.x < 0 and animated_sprite.scale.x == 1.0:
			animated_sprite.play("back_jump_up")
		elif velocity.x < 0 and animated_sprite.scale.x == -1.0:
			animated_sprite.play("jump_up")
		elif velocity.x > 0 and animated_sprite.scale.x == 1.0:
			animated_sprite.play("jump_up")
		elif velocity.x > 0 and animated_sprite.scale.x == -1.0:
			animated_sprite.play("back_jump_up")
	if velocity.y > 0:
		call_deferred("change_state", State.BACK_JUMP_DOWN)

func process_back_jump_down(_delta: float) -> void:
	if isStateNew:
		if velocity.x < 0 and animated_sprite.scale.x == 1.0:
			animated_sprite.play("back_jump_down")
		elif velocity.x < 0 and animated_sprite.scale.x == -1.0:
			animated_sprite.play("jump_down")
		elif velocity.x > 0 and animated_sprite.scale.x == 1.0:
			animated_sprite.play("jump_down")
		elif velocity.x > 0 and animated_sprite.scale.x == -1.0:
			animated_sprite.play("back_jump_down")
	if is_on_floor():
		velocity.x = 0
		if randf() > 0.5: # 0.5
			call_deferred("change_state", State.SHOCK_WAVE)
			await get_tree().create_timer(0.3).timeout
			spawner_wave()
		else:
			call_deferred("change_state", State.DASH_PLAN)

func spawner_wave():
	if global_position.x > 300.0:
		wave_spawner.spawner_wave_left()
	else:
		wave_spawner.spawner_wave_right()
		

func process_jump2(_delta: float) -> void:
	if isStateNew:
		velocity.x = player.global_position.x - global_position.x
		velocity.y = JUMP_VELOCITY * 1.4
		animated_sprite.play("jump_up")
	if velocity.y > JUMP_VELOCITY/2:
		call_deferred("change_state", State.PUNCH_PLAN)

func process_punch_plan(_delta: float) -> void:
	if isStateNew:
		velocity = Vector2.ZERO
		animated_sprite.play("punch_down_plan")
	if !animated_sprite.is_playing():
		call_deferred("change_state", State.PUNCH)

func process_punch(_delta: float) -> void:
	if isStateNew:
		animated_sprite.play("punch_down")
	velocity.y += 200
	if is_on_floor():
		guci_spawner.spawner_guci()
		velocity.x = 0
		call_deferred("change_state", State.PUNCH_END)
		
func process_punch_end(_delta: float) -> void:
	if isStateNew:
		velocity = Vector2.ZERO
		animated_sprite.play("punch_down_end")
	velocity.y += 200
	if !animated_sprite.is_playing():
		call_deferred("change_state", State.IDLE)

func process_shock_wave(_delta: float) -> void:
	if isStateNew:
		velocity = Vector2.ZERO
		animated_sprite.play("shock_wave")
	if !animated_sprite.is_playing():
		call_deferred("change_state", State.IDLE)

func process_dash_plan(_delta: float) -> void:
	if isStateNew:
		animated_sprite.play("dash_plan")
	if !animated_sprite.is_playing():
		call_deferred("change_state", State.DASH)
		
func process_dash(_delta: float) -> void:
	if isStateNew:
		if animated_sprite.scale.x == -1.0:
			print("L")
			velocity.x = -1000
		elif animated_sprite.scale.x == 1.0:
			print("R")
			velocity.x = 1000
		velocity.y = 0
		animated_sprite.play("dash")
		print(position.x)
	if animated_sprite.scale.x == -1.0 and position.x < -100:
		call_deferred("change_state", State.DASH_END)
	if animated_sprite.scale.x == 1.0 and position.x > 228: #890
		call_deferred("change_state", State.DASH_END)
		
func process_dash_end(delta: float) -> void:
	if isStateNew:
		velocity.x = lerp(0.0, velocity.x, pow(2, -10 * delta))
		animated_sprite.play("dash_end")
	if !animated_sprite.is_playing():
		call_deferred("change_state", State.IDLE)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

func _on_hurtbox_area_entered(_area: Area2D) -> void:
	timer.start()
	animated_sprite.use_parent_material = false

func _on_timer_timeout() -> void:
	animated_sprite.use_parent_material = true
