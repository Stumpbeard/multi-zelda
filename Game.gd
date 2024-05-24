extends Node2D

var player

func _ready():
	randomize()
	player = $GameMap/Link

func _physics_process(_delta):
	var direction = Vector2()
	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("up"):
		direction.y -= 1
		
	player.move(direction.normalized())
	
	if Input.is_action_just_pressed("primary"):
		player.attack()
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.ai()
