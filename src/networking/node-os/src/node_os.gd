# Node as OS Image Implementation for Forest Kingdoms RPG
# GDScript implementation for Godot Engine
#
# This module implements a node as an image of an operating system
# in a decentralized P2P network, adapted for use in the Forest Kingdoms RPG game.
#
# Author: Generated from Python reference implementation
# Date: 2025-11-27

extends Node

# Node identification
var node_id: String
var boot_time: float

# Core OS components
var processes: Dictionary
var filesystem: Dictionary
var network_interfaces: Array
var memory: Dictionary

# Game-specific attributes
var game_state: Dictionary
var players: Dictionary
var game_events: Array

# Node status
var status: String

func _init(custom_node_id: String = ""):
	# Initialize node with ID or generate new one
	if custom_node_id != "":
		node_id = custom_node_id
	else:
		node_id = _generate_uuid()
	
	# Set boot time
	boot_time = Time.get_unix_time_from_system()
	
	# Initialize core OS components
	processes = {}
	filesystem = {}
	network_interfaces = []
	memory = {
		"total": 1024 * 1024 * 1024,  # 1GB
		"used": 0,
		"available": 1024 * 1024 * 1024
	}
	
	# Initialize game-specific attributes
	game_state = {}
	players = {}
	game_events = []
	
	# Set initial status
	status = "running"

# Helper function to generate UUID-like string
func _generate_uuid() -> String:
	# Simple UUID-like generator for demonstration
	# In production, use a proper UUID library
	var chars = "0123456789abcdef"
	var uuid = ""
	for i in range(32):
		if i == 8 or i == 12 or i == 16 or i == 20:
			uuid += "-"
		else:
			uuid += chars[randi() % chars.length()]
	return uuid

# Get node information
func get_node_info() -> Dictionary:
	return {
		"node_id": node_id,
		"boot_time": boot_time,
		"uptime": Time.get_unix_time_from_system() - boot_time,
		"status": status,
		"process_count": processes.size(),
		"memory": memory,
		"network_interfaces": network_interfaces.size(),
		"player_count": players.size(),
		"event_count": game_events.size()
	}

# Process management
func create_process(name: String, command: String) -> String:
	var process_id = _generate_uuid()
	processes[process_id] = {
		"name": name,
		"command": command,
		"start_time": Time.get_unix_time_from_system(),
		"status": "running"
	}
	return process_id

func terminate_process(process_id: String) -> bool:
	if processes.has(process_id):
		processes[process_id]["status"] = "terminated"
		processes[process_id]["end_time"] = Time.get_unix_time_from_system()
		return true
	return false

# File system simulation
func create_file(path: String, content: String = "") -> bool:
	filesystem[path] = {
		"content": content,
		"size": content.length(),
		"created": Time.get_unix_time_from_system(),
		"modified": Time.get_unix_time_from_system()
	}
	return true

func read_file(path: String) -> String:
	if filesystem.has(path):
		return filesystem[path]["content"]
	return ""

# Network interface management
func add_network_interface(interface_name: String, address: String) -> bool:
	network_interfaces.append({
		"name": interface_name,
		"address": address,
		"status": "up"
	})
	return true

# System state hashing
func get_system_hash() -> String:
	var system_data = node_id + str(boot_time) + str(processes.size()) + str(filesystem.size()) + str(players.size()) + str(game_events.size())
	return system_data.sha256_text()

# Game-specific methods

# Add a player to the game
func add_player(player_id: String, player_data: Dictionary) -> bool:
	players[player_id] = {
		"data": player_data,
		"join_time": Time.get_unix_time_from_system(),
		"status": "active"
	}
	return true

# Remove a player from the game
func remove_player(player_id: String) -> bool:
	if players.has(player_id):
		players[player_id]["status"] = "disconnected"
		players[player_id]["leave_time"] = Time.get_unix_time_from_system()
		return true
	return false

# Update the game state
func update_game_state(state_data: Dictionary) -> bool:
	for key in state_data.keys():
		game_state[key] = state_data[key]
	return true

# Get the current game state
func get_game_state() -> Dictionary:
	return game_state duplicate()

# Add a game event
func add_game_event(event_type: String, event_data: Dictionary) -> String:
	var event_id = _generate_uuid()
	game_events.append({
		"id": event_id,
		"type": event_type,
		"data": event_data,
		"timestamp": Time.get_unix_time_from_system()
	})
	return event_id

# Demo function to show node functionality
func demo() -> void:
	print("Starting Node OS Image for Forest Kingdoms RPG...")
	
	# Add some basic components
	add_network_interface("eth0", "192.168.1.100")
	create_file("/etc/hostname", "node-" + node_id.substr(0, 8))
	create_process("init", "/sbin/init")
	
	# Add game-specific components
	add_player("player1", {"name": "Alice", "level": 1})
	update_game_state({"world_seed": "forest123", "time_of_day": "day"})
	add_game_event("player_join", {"player_id": "player1"})
	
	# Display node information
	var info = get_node_info()
	print("Node ID: " + info["node_id"])
	print("Uptime: " + str(info["uptime"]) + " seconds")
	print("Processes: " + str(info["process_count"]))
	print("Network interfaces: " + str(info["network_interfaces"]))
	print("Players: " + str(info["player_count"]))
	print("Events: " + str(info["event_count"]))
	
	# Display system hash
	print("System Hash: " + get_system_hash().substr(0, 16) + "...")