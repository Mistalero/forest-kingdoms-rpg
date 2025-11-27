# Node as OS Image Implementation for Forest Kingdoms RPG

This directory contains an implementation of a node as an image of an operating system in a decentralized P2P network, adapted for use in the Forest Kingdoms RPG game.

## Overview

The implementation simulates core OS components within a node and extends them for game-specific functionality:
- Process management
- Memory management
- File system simulation
- Network communication
- Game state management
- Player management
- Game event handling

## Important Note

The Python implementation is provided as a reference. The main implementation for Godot Engine is in GDScript.

## Structure

- `node.py` - Main implementation file (Python reference implementation)
- `src/node_os.gd` - Main implementation file (GDScript for Godot)
- `src/` - Source code directory (for Godot adaptation)
- `tests/` - Test files (to be created)

## Game-Specific Features

- Player management (add/remove players)
- Game state synchronization
- Game event handling
- Network interface management for P2P communication

## Usage (GDScript Implementation)

To use the GDScript implementation in Godot:

1. Copy the `src/node_os.gd` file to your Godot project
2. Instantiate the NodeOS class in your scene:

```gdscript
extends Node

# Import the NodeOS class
const NodeOS = preload("res://path/to/node_os.gd")

func _ready():
    # Create a node instance
    var node = NodeOS.new()
    
    # Use node functionality
    node.add_network_interface("eth0", "192.168.1.100")
    node.add_player("player1", {"name": "Alice", "level": 1})
    
    # Display node information
    var info = node.get_node_info()
    print("Node ID: " + info["node_id"])
```

## API Reference

### NodeOS Class (GDScript)

#### Core Methods

- `get_node_info()` - Get comprehensive node information
- `create_process(name: String, command: String)` - Create a new process
- `terminate_process(process_id: String)` - Terminate a process
- `create_file(path: String, content: String)` - Create a file in the simulated filesystem
- `read_file(path: String)` - Read a file from the simulated filesystem
- `add_network_interface(interface_name: String, address: String)` - Add a network interface
- `get_system_hash()` - Get a hash representing the current system state

#### Game-Specific Methods

- `add_player(player_id: String, player_data: Dictionary)` - Add a player to the game
- `remove_player(player_id: String)` - Remove a player from the game
- `update_game_state(state_data: Dictionary)` - Update the game state
- `get_game_state()` - Get the current game state
- `add_game_event(event_type: String, event_data: Dictionary)` - Add a game event

#### Demo Method

- `demo()` - Demonstrate node functionality

## Integration with Forest Kingdoms RPG

The node implementation will be integrated with the existing networking components in `src/networking/`:

- `src/networking/core/` - Core networking components
- `src/networking/discovery/` - Node discovery mechanisms
- `src/networking/messaging/` - Message passing between nodes
- `src/networking/P2PAdapter.js` - Existing P2P adapter
- `src/networking/P2PFramework.gd` - Existing P2P framework

## Next Steps

1. ~~Convert the Python implementation to GDScript~~ (Completed)
2. Integrate with existing networking components
3. Implement P2P communication protocols
4. Create test scenarios for multiplayer gameplay
5. Optimize for real-time game performance