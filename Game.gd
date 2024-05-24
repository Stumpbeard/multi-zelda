extends Node2D

var port = 6969
var server = "0.0.0.0"

var player

func _ready():
	randomize()
	player = get_node("GameMap/Link")
	var peer
	if OS.get_name() == "HTML5":
		peer = WebSocketClient.new()
		connect_network_signals(peer)
		peer.connect_to_url("%s:%s" % [server, port], [], true)
	else:
		peer = WebSocketServer.new()
		connect_network_signals(peer)
		peer.listen(port, [], true)
		player.name = "1"
	get_tree().network_peer = peer
	
func connect_network_signals(peer: NetworkedMultiplayerPeer):
	var _err = peer.connect("peer_connected", self, "_peer_connected")
	_err = peer.connect("connection_succeeded", self, "_connection_succeeded")
	
func _connection_succeeded():
	var id = get_tree().get_network_unique_id()
	player.name = str(id)
	player.set_network_master(id)
	
func _peer_connected(id):
	print("%s connected successfully" % [id])
	var new_player = get_node_or_null("GameMap/%s" % [id])
	if !new_player:
		new_player = load("res://Link.tscn").instance()
		new_player.position = Vector2(128, 88)
		new_player.name = str(id)
		$GameMap.add_child(new_player)
		new_player.set_network_master(id)
		

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
	
	if is_network_master():
		for enemy in get_tree().get_nodes_in_group("enemies"):
			enemy.ai()
			
	if get_tree().is_network_server():
		var units_to_sync = {}
		for unit in get_tree().get_nodes_in_group("syncables"):
			units_to_sync[unit.name] = unit.serialized()
		rpc("sync_all_units", units_to_sync)

remote func sync_all_units(units_to_sync):
	for id in units_to_sync:
		if int(id) == get_tree().get_network_unique_id():
			continue # we don't accept syncs about ourselves
		var data = units_to_sync[id]
		var unit = get_node_or_null(data.path)
		if !unit:
			continue
		unit.sync_data(data)
		
		
