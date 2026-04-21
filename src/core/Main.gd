extends Node

# Main Entry Point for the Universal Game Core
# Supports: BIOS Boot, OS Shell, Libretro Core, Container, Standard App

class_name MainCore

# Configuration
var config: Dictionary = {}
var environment: String = "STANDARD" # STANDARD, LIBRETRO, BARE_METAL, CONTAINER, SHELL
var is_headless: bool = false

# Subsystems
var network_manager: Node = null
var visual_controller: Node = null
var input_handler: Node = null
var data_manager: Node = null
var shard_session: Node = null

func _ready():
detect_environment()
initialize_subsystems()
start_game_loop()

func detect_environment():
# Detect runtime environment automatically
if OS.has_feature("libretro"):
environment = "LIBRETRO"
elif OS.get_name() == "UWP" or OS.get_name() == "Web":
environment = "CONTAINER"
elif ProjectSettings.get_setting("application/run/boot_splash_screen") == "":
environment = "BARE_METAL" # Heuristic for direct boot
else:
environment = "STANDARD"

print("Environment detected: ", environment)

func initialize_subsystems():
# Initialize Network (P2P, No Daemons)
network_manager = load("res://src/network/NetworkManager.gd").new()
add_child(network_manager)

# Initialize Visuals (Polymorphic Renderer)
visual_controller = load("res://src/visual/VisualController.gd").new()
add_child(visual_controller)

# Initialize Input
input_handler = load("res://src/core/InputHandler.gd").new()
add_child(input_handler)

# Initialize Data (Local Cache + Sync Queue)
data_manager = load("res://src/data/DataManager.gd").new()
add_child(data_manager)

# Initialize Shard Session (Recursive Session Management)
shard_session = load("res://src/network/ShardSession.gd").new()
add_child(shard_session)

func start_game_loop():
# Connect to existing session or create new one
var session_id = config.get("session_id", "default_global_shard")
shard_session.join_or_create(session_id)

# Start rendering based on user preference or auto-detect
var render_mode = config.get("render_mode", "AUTO")
visual_controller.set_render_mode(render_mode)

print("Game loop started in session: ", session_id)

func _process(delta):
if network_manager:
network_manager.process_network(delta)
if visual_controller:
visual_controller.render_frame(delta)
if shard_session:
shard_session.update_state(delta)

func _exit_tree():
# Graceful shutdown: Save state, disconnect from P2P, no daemons left
if shard_session:
shard_session.save_and_disconnect()
print("Node shutdown complete. No background processes remaining.")
