extends Node
class_name ShardSessionClass

# Recursive Shard Session Manager
# Each session is a shard, shards can host nested shards (Matryoshka)
# Distributed state, no central authority

var session_id: String = ""
var parent_session: String = ""
var child_sessions: Array = []
var state: Dictionary = {}
var peers: Array = []
var is_host: bool = false

func _ready():
pass

func join_or_create(id: String):
session_id = id
print("Joining/Creating shard session: ", id)
# Logic to find existing session or create new one
# Sync state from peers if joining

func update_state(delta: float):
# Process local state changes
# Broadcast deltas to peers
pass

func save_and_disconnect():
# Save local state snapshot
# Notify peers of departure
print("Saving state and disconnecting from session: ", session_id)
session_id = ""

func create_nested_session(child_id: String):
# Create a sub-shard within this session
child_sessions.append(child_id)
print("Created nested session: ", child_id, " inside ", session_id)
return load("res://src/network/ShardSession.gd").new()

func migrate_to_peer(peer_id: String):
# Transfer host responsibilities to another peer
is_host = false
print("Migrating session host to: ", peer_id)

func get_full_path() -> String:
if parent_session:
return parent_session + "/" + session_id
return session_id
