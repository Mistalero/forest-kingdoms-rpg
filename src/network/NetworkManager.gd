extends Node

## Decentralized P2P Network Manager.
## Handles session shards, peer discovery, and state synchronization.

signal peer_connected(peer_id: String)
signal peer_disconnected(peer_id: String)
signal shard_updated(shard_data: Dictionary)

var multiplayer_api: MultiplayerAPI
var session_id: String = ""
var peers: Dictionary = {} # peer_id -> PeerData
var shard_data: Dictionary = {} # Current world state for this shard

# Configuration
var max_peers: int = 50
var enable_relay: bool = true # For NAT traversal / Darknet tunnels

func _ready():
	# Default to Godot's high-level multiplayer, can be swapped for custom UDP/TCP
	multiplayer_api = MultiplayerAPI.new()
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func join_or_create_session(id: String):
	session_id = id
	print("[Network] Joining/Creating session: ", session_id)
	
	# In a real implementation, this would use a DHT or signaling server
	# For now, we simulate hosting if no peers are found quickly
	_host_session()

func _host_session():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(12345, max_peers) # Port 12345
	
	if error != OK:
		push_error("[Network] Failed to create server on port 12345")
		return
		
	multiplayer.multiplayer_peer = peer
	print("[Network] Hosting session as host.")

func leave_session():
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	
	peers.clear()
	shard_data.clear()
	print("[Network] Left session.")

func sync_state(data: Dictionary):
	# Broadcast state update to all peers in the shard
	if multiplayer.has_multiplayer_peer():
		_receive_state.rpc(data)

@rpc("any_peer", "reliable")
func _receive_state(data: Dictionary):
	shard_data = data
	shard_updated.emit(data)

func _on_peer_connected(id: int):
	print("[Network] Peer connected: ", id)
	peers[str(id)] = {"id": id, "role": "peer"}
	peer_connected.emit(str(id))

func _on_peer_disconnected(id: int):
	print("[Network] Peer disconnected: ", id)
	peers.erase(str(id))
	peer_disconnected.emit(str(id))

func _on_connected_to_server():
	print("[Network] Connected to host.")

func _on_connection_failed():
	print("[Network] Connection failed.")

func _on_server_disconnected():
	print("[Network] Server disconnected.")
