extends Node2D

var port = 6969
var server = "0.0.0.0"

var player

var tick = 0
var input_maps = {}

var input_history = []

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
		

func _physics_process(delta):
	tick += 1
	var input_map = {
		"up": Input.is_action_pressed("up"),
		"down": Input.is_action_pressed("down"),
		"left": Input.is_action_pressed("left"),
		"right": Input.is_action_pressed("right"),
		"primary": Input.is_action_just_pressed("primary"),
		"tick": tick
	}
	
	if !get_tree().is_network_server():
		rpc_id(1, "send_input_map", input_map)
		input_history.append(input_map)
	
	input_maps[get_tree().get_network_unique_id()] = input_map
	
	for id in input_maps:
		input_map = input_maps.get(id)
		var character = get_node_or_null("GameMap/%s" % [id])
		if !character || !input_map:
			continue
		
		execute_input(character, input_map)
			
		character.last_tick = input_map.tick

	if get_tree().is_network_server():
		for enemy in get_tree().get_nodes_in_group("enemies"):
			enemy.ai()

		var units_to_sync = {}
		for unit in get_tree().get_nodes_in_group("syncables"):
			var data = unit.serialized()
			data.tick = unit.last_tick
			units_to_sync[unit.name] = data
		rpc("sync_all_units", units_to_sync)
		
func execute_input(character, input_map):
	var direction = Vector2()
	if input_map.get("right"):
		direction.x += 1
	if input_map.get("left"):
		direction.x -= 1
	if input_map.get("down"):
		direction.y += 1
	if input_map.get("up"):
		direction.y -= 1
		
	character.move(direction.normalized())
	
	if input_map.get("primary"):
		character.attack()

remote func send_input_map(input_map):
	input_maps[get_tree().get_rpc_sender_id()] = input_map

remote func sync_all_units(units_to_sync):
	for id in units_to_sync:
		var data = units_to_sync[id]
		var unit = get_node_or_null(data.path)
		if !unit:
			continue
		unit.sync_data(data)
		
		if unit == player && !input_history.empty():
			var tick = data.tick
			var frame = input_history[0]
			while !input_history.empty() && frame.tick <= tick:
				frame = input_history.pop_front()
				
			for input_map in input_history:
				execute_input(player, input_map)
		
	
		
