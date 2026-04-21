extends Node

## Data Manager for Distributed State.
## Handles local caching and synchronization with the P2P network.

var local_cache: Dictionary = {}
var sync_queue: Array = []

func _ready():
	print("[DataManager] Initialized.")

func save_state(key: String, value):
	local_cache[key] = value
	# Queue for network sync
	sync_queue.append({"key": key, "value": value})

func get_state(key: String):
	return local_cache.get(key, null)

func flush_cache():
	# Save to disk or persistent storage
	print("[DataManager] Flushing cache to persistent storage.")
	local_cache.clear()
	sync_queue.clear()

func process_sync_queue():
	# Send queued updates to network manager
	if sync_queue.size() > 0:
		var update = sync_queue.pop_front()
		# Emit signal or call network manager
		print("[DataManager] Syncing state: ", update.key)
