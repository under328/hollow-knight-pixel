extends Camera2D

var player_position = Vector2.ZERO
func _ready() -> void:
	global_position.x = 1560
	global_position.y = 420

func match_player_position():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		player_position = player.global_position

func _process(delta: float) -> void:
	match_player_position()
	global_position.y = player_position.y - 350
	if player_position.x > 1000 and player_position.x < 2200:
		global_position.x = lerp(player_position.x, global_position.x, pow(2, -7 * delta))
	if player_position.x < 1000:
		global_position.x = lerp(240.0, global_position.x, pow(2, -7 * delta))
	if player_position.x > 2200:
		global_position.x = lerp(2200.0, global_position.x, pow(2, -7 * delta))
