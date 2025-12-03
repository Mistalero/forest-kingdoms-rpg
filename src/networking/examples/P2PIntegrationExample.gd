# P2P Integration Example for Forest Kingdoms RPG
# This example demonstrates how to use the integrated P2P components with Godot

extends Node

# Reference to the P2P framework
var p2p_framework

func _ready():
	# Get the P2P framework instance
	p2p_framework = P2PFramework.get_instance()
	
	if p2p_framework == null:
		push_error("P2P framework not initialized")
		return
	
	# Connect to framework signals
	connect_to_framework_signals()
	
	# Initialize the local peer
	initialize_local_peer()
	
	# Start the framework
	p2p_framework.start()
	
	print("P2P integration example initialized")
	
	# Run the demo
	run_demo()

# Connect to framework signals
func connect_to_framework_signals():
	p2p_framework.connect("peer_connected", Callable(self, "_on_peer_connected"))
	p2p_framework.connect("peer_disconnected", Callable(self, "_on_peer_disconnected"))
	p2p_framework.connect("message_received", Callable(self, "_on_message_received"))
	p2p_framework.connect("error_occurred", Callable(self, "_on_error_occurred"))

# Initialize the local peer
func initialize_local_peer():
	# Set local peer information
	var peer_name = "Player_" + str(randi() % 1000)
	p2p_framework.session_manager.set_local_peer_info(peer_name)
	
	print("Local peer initialized as: ", peer_name)

# Run the demo
func run_demo():
	print("Running P2P integration demo...")
	
	# Demonstrate CRDT creation and usage
	demo_crdt_usage()
	
	# Demonstrate state serialization
	demo_state_serialization()
	
	# Demonstrate node information
	demo_node_info()

# Demonstrate CRDT usage
func demo_crdt_usage():
	print("Demonstrating CRDT usage...")
	
	# Create a CRDT for player position
	var player_position_crdt = p2p_framework.create_game_state_crdt("player-position-1", "LWWRegister", {"x": 0, "y": 0})
	if player_position_crdt != null:
		print("Created player position CRDT")
		
		# Update the position
		player_position_crdt.set({"x": 10, "y": 20})
		print("Updated player position: ", player_position_crdt.get())
	
	# Create a CRDT for player inventory
	var player_inventory_crdt = p2p_framework.create_game_state_crdt("player-inventory-1", "ORSet", ["sword", "shield"])
	if player_inventory_crdt != null:
		print("Created player inventory CRDT")
		
		# Add an item to the inventory
		# Note: This is a simplified example, real implementation would depend on the CRDT type
		print("Player inventory: ", player_inventory_crdt.get())

# Demonstrate state serialization
func demo_state_serialization():
	print("Demonstrating state serialization...")
	
	# Serialize game state
	# Note: In a real implementation, this would serialize all CRDTs
	var serialized_state = "{}"  # Placeholder
	print("Serialized state: ", serialized_state)
	
	# Deserialize game state
	# Note: In a real implementation, this would deserialize and merge CRDTs
	print("State deserialized")

# Demonstrate node information
func demo_node_info():
	print("Demonstrating node information...")
	
	# Get node ID
	var node_id = p2p_framework.p2p_adapter.get_node_id()
	print("Node ID: ", node_id)
	
	# Get DID document
	var did_document = p2p_framework.p2p_adapter.get_did_document()
	print("DID Document: ", did_document)

# Create a game session
func create_game_session(session_name: String, max_players: int):
	var session_id = p2p_framework.create_session(session_name, max_players)
	if session_id != -1:
		print("Created game session: ", session_name, " (ID: ", session_id, ")")
		return session_id
	else:
		push_error("Failed to create session")
		return -1

# Join a game session
func join_game_session(session_id: int):
	p2p_framework.join_session(session_id)
	print("Attempting to join session: ", session_id)

# Send a chat message
func send_chat_message(peer_id: int, text: String):
	var chat_data = {
		"text": text,
		"sender": p2p_framework.session_manager.get_local_peer_info().name,
		"timestamp": Time.get_ticks_msec()
	}
	
	p2p_framework.send_message(peer_id, "chat", chat_data)

# Send game data
func send_game_data(peer_id: int, game_data: Dictionary):
	p2p_framework.send_message(peer_id, "game_data", game_data)

# Signal handlers
func _on_peer_connected(peer_id: int):
	print("New peer connected: ", peer_id)
	
	# Send welcome message
	var welcome_data = {
		"message": "Welcome to the game!",
		"session_info": p2p_framework.session_manager.get_active_sessions()
	}
	
	p2p_framework.send_message(peer_id, "handshake", welcome_data)

func _on_peer_disconnected(peer_id: int):
	print("Peer disconnected: ", peer_id)

func _on_message_received(message_data: Dictionary):
	print("Received message: ", message_data)
	
	# Handle message based on type
	match message_data.type:
		"chat":
			handle_chat_message(message_data)
		"game_data":
			handle_game_data_message(message_data)
		"handshake":
			handle_handshake_message(message_data)

func _on_error_occurred(error_code: int, error_message: String):
	printerr("An error occurred: ", error_code, " - ", error_message)
	
	# Attempt automatic recovery
	if p2p_framework.error_handler.attempt_error_recovery(error_code):
		print("Automatic recovery attempt completed")

# Message handlers
func handle_chat_message(message_data: Dictionary):
	var chat_data = message_data.data
	print("[CHAT] ", chat_data.sender, ": ", chat_data.text)

func handle_game_data_message(message_data: Dictionary):
	var game_data = message_data.data
	print("Received game data: ", game_data)
	
	# Here would be logic to handle game data
	# For example, updating character position, game state, etc.

func handle_handshake_message(message_data: Dictionary):
	var handshake_data = message_data.data
	print("Received handshake message: ", handshake_data.message)
	
	# Handle session information
	if handshake_data.has("session_info"):
		for session in handshake_data.session_info:
			print("  Session: ", session.name, " (", session.id, ")")

# List available sessions
func list_available_sessions():
	var sessions = p2p_framework.get_available_sessions()
	print("Available sessions:")
	
	if sessions.size() == 0:
		print("  No available sessions")
		return
	
	for session in sessions:
		print("  - ", session.name, " (ID: ", session.id, ", Players: ", session.player_count, "/", session.max_players, ")")

# Send test message to all peers
func send_test_message_to_all():
	# In a real implementation, this would get the list of connected peers
	# and send a message to each of them
	print("Sending test message to all peers")

# Cleanup
func cleanup():
	if p2p_framework != null:
		p2p_framework.stop()
		print("P2P framework stopped")