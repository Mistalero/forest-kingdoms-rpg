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
- `src/NodeOSAdapter.gd` - Adapter for integration with existing networking components
- `src/` - Source code directory (for Godot adaptation)
- `tests/` - Test files (to be created)

## Game-Specific Features

- Player management (add/remove players)
- Game state synchronization
- Game event handling
- Network interface management for P2P communication

## Integration with Existing Components

The NodeOS implementation is integrated with the existing networking components through the NodeOSAdapter:

- `NodeOSAdapter.gd` - Adapter that connects NodeOS with existing networking components
- Works with `P2PFramework.gd` - Main P2P framework
- Integrates with `ConnectionManager.gd` - Connection management
- Uses `MessageHandler.gd` - Message handling between nodes
- Connects with `DiscoveryManager.gd` - Node and session discovery

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

To use the NodeOSAdapter for integration with existing components:

```gdscript
extends Node

# Import the NodeOSAdapter
const NodeOSAdapter = preload("res://src/networking/node-os/src/NodeOSAdapter.gd")

func _ready():
    # Create adapter instance
    var node_adapter = NodeOSAdapter.new()
    
    # Connect to signals
    node_adapter.connect("node_initialized", Callable(self, "_on_node_initialized"))
    node_adapter.connect("player_joined", Callable(self, "_on_player_joined"))
    
    # Initialize and start adapter
    node_adapter.initialize()
    node_adapter.start()
    
    # Use adapter functionality
    node_adapter.add_player("player1", {"name": "Alice", "level": 1})

func _on_node_initialized(node_info):
    print("Node initialized: " + node_info["node_id"])

func _on_player_joined(player_id, player_data):
    print("Player joined: " + player_id)
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

### NodeOSAdapter Class (GDScript)

#### Core Methods

- `initialize()` - Initialize the adapter and connect to existing components
- `start()` - Start the adapter
- `stop()` - Stop the adapter
- `send_message(peer_id: int, message_type: String, data: Dictionary)` - Send message through existing messaging system
- `get_node_info()` - Get node information through NodeOS

#### Integration Methods

- `get_node_info()` - Get node information
- `create_process()` - Create process (delegated to NodeOS)
- `terminate_process()` - Terminate process (delegated to NodeOS)
- `create_file()` - Create file (delegated to NodeOS)
- `read_file()` - Read file (delegated to NodeOS)
- `add_network_interface()` - Add network interface (delegated to NodeOS)
- `get_system_hash()` - Get system hash (delegated to NodeOS)

#### Game Integration Methods

- `add_player()` - Add player (delegated to NodeOS with signal emission)
- `remove_player()` - Remove player (delegated to NodeOS with signal emission)
- `update_game_state()` - Update game state (delegated to NodeOS with signal emission)
- `get_game_state()` - Get game state (delegated to NodeOS)
- `add_game_event()` - Add game event (delegated to NodeOS)

#### Signals

- `node_initialized(node_info)` - Emitted when node is initialized
- `node_ready()` - Emitted when node is ready
- `game_state_updated(state)` - Emitted when game state is updated
- `player_joined(player_id, player_data)` - Emitted when player joins
- `player_left(player_id)` - Emitted when player leaves
- `message_from_node(message_data)` - Emitted when message is received from node

## Integration with Forest Kingdoms RPG

The node implementation will be integrated with the existing networking components in `src/networking/`:

- `src/networking/core/` - Core networking components
- `src/networking/discovery/` - Node discovery mechanisms
- `src/networking/messaging/` - Message passing between nodes
- `src/networking/P2PAdapter.js` - Existing P2P adapter
- `src/networking/P2PFramework.gd` - Existing P2P framework

## Next Steps

1. ~~Convert the Python implementation to GDScript~~ (Completed)
2. ~~Integrate with existing networking components~~ (Completed)
3. Implement P2P communication protocols
4. Create test scenarios for multiplayer gameplay
5. Optimize for real-time game performance