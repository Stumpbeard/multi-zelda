extends Node2D

var port = 6161
var server = "0.0.0.0"

var player

func _ready():
	randomize()
	player = $GameMap/Link
	var peer
	if OS.get_name() == "HTML5":
		peer = WebSocketClient.new()
		connect_network_signals(peer)
		peer.connect_to_url("%s:%s" % [server, port], [], true)
		yield(peer, "connection_succeeded")
	else:
		peer = WebSocketServer.new()
		connect_network_signals(peer)
		peer.listen(port, [], true)
	get_tree().network_peer = peer
	player.name = str(get_tree().get_network_unique_id())
	
func connect_network_signals(peer: NetworkedMultiplayerPeer):
	peer.connect("peer_connected", self, "_peer_connected")
	
func _peer_connected(id):
	print("%s connected successfully" % [id])

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
