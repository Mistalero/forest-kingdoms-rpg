extends Node

## Main entry point for the Omni-Layer Game Core.
## Manages lifecycle, session state, and subsystem initialization.

signal session_started
signal session_ended
signal shutdown_complete

# Subsystems
var network_manager: Node
var visual_controller: Node
var data_manager: Node
var input_handler: Node

# State
var is_running: bool = false
var session_id: String = ""
var node_role: String = "full" # full, light, container

func _ready():
	print("[Core] Initializing Omni-Layer Game Core...")
	_initialize_subsystems()
	_detect_environment()
	start_session()

func _initialize_subsystems():
	# Initialize Network (P2P, Shard Management)
	network_manager = load("res://src/network/NetworkManager.gd").new()
	add_child(network_manager)
	
	# Initialize Visuals (Polymorphic Rendering)
	visual_controller = load("res://src/visual/VisualController.gd").new()
	add_child(visual_controller)
	
	# Initialize Data (Distributed State)
	data_manager = load("res://src/data/DataManager.gd").new()
	add_child(data_manager)
	
	# Initialize Input
	input_handler = InputHandler.new()
	add_child(input_handler)
	
	print("[Core] Subsystems initialized.")

func _detect_environment():
	# Detect if running as BIOS boot, OS Shell, Libretro Core, or Container
	var env = OS.get_environment("OMNI_ENV")
	if env.is_empty():
		env = "standalone"
	
	match env:
		"bios":
			node_role = "full"
			print("[Core] Running in Bare Metal / BIOS mode.")
		"libretro":
			node_role = "container"
			print("[Core] Running as Libretro Core.")
		"container":
			node_role = "light"
			print("[Core] Running in Container mode.")
		_:
			node_role = "full"
			print("[Core] Running in Standalone OS/Desktop mode.")

func start_session():
	if is_running:
		return
	
	is_running = true
	session_id = str(Time.get_unix_time_from_system()) + "_" + str(randi())
	
	print("[Core] Starting Session: ", session_id)
	network_manager.join_or_create_session(session_id)
	visual_controller.apply_user_preferences()
	
	session_started.emit()

func stop_session():
	if not is_running:
		return
	
	print("[Core] Stopping Session: ", session_id)
	is_running = false
	
	network_manager.leave_session()
	data_manager.flush_cache()
	
	session_ended.emit()
	
	# If no daemon mode, exit process
	if OS.get_environment("OMNI_DAEMON") != "true":
		print("[Core] No daemon mode. Shutting down.")
		get_tree().quit()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		stop_session()
