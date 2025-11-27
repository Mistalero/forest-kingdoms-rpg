#!/usr/bin/env python3
"""
Node as OS Image Implementation for Forest Kingdoms RPG
=====================================================

This module implements a node as an image of an operating system
in a decentralized P2P network, adapted for use in the Forest Kingdoms RPG game.

IMPORTANT: This is a Python implementation that needs to be adapted for Godot.
The current implementation is provided as a reference for the Godot adaptation.

The node contains:
- Core OS components simulation
- Process management
- Memory management simulation
- File system simulation
- Network communication

For the Forest Kingdoms RPG game, this node will be adapted to:
- Handle game state synchronization
- Manage player connections
- Process game events
- Handle game messaging
"""

import uuid
import time
import hashlib
from typing import Dict, List, Any


class NodeOS:
    """Node implementation as an OS image adapted for Forest Kingdoms RPG"""
    
    def __init__(self, node_id: str = None):
        self.node_id = node_id or str(uuid.uuid4())
        self.boot_time = time.time()
        self.processes: Dict[str, Dict[str, Any]] = {}
        self.filesystem: Dict[str, Dict[str, Any]] = {}
        self.network_interfaces: List[Dict[str, Any]] = []
        self.memory: Dict[str, Any] = {
            'total': 1024 * 1024 * 1024,  # 1GB
            'used': 0,
            'available': 1024 * 1024 * 1024
        }
        self.status = 'running'
        
        # Game-specific attributes
        self.game_state = {}
        self.players = {}
        self.game_events = []
        
    def get_node_info(self) -> Dict[str, Any]:
        """Get node information"""
        return {
            'node_id': self.node_id,
            'boot_time': self.boot_time,
            'uptime': time.time() - self.boot_time,
            'status': self.status,
            'process_count': len(self.processes),
            'memory': self.memory,
            'network_interfaces': len(self.network_interfaces),
            'player_count': len(self.players),
            'event_count': len(self.game_events)
        }
        
    def create_process(self, name: str, command: str) -> str:
        """Create a new process"""
        process_id = str(uuid.uuid4())
        self.processes[process_id] = {
            'name': name,
            'command': command,
            'start_time': time.time(),
            'status': 'running'
        }
        return process_id
        
    def terminate_process(self, process_id: str) -> bool:
        """Terminate a process"""
        if process_id in self.processes:
            self.processes[process_id]['status'] = 'terminated'
            self.processes[process_id]['end_time'] = time.time()
            return True
        return False
        
    def create_file(self, path: str, content: str = '') -> bool:
        """Create a file in the simulated filesystem"""
        self.filesystem[path] = {
            'content': content,
            'size': len(content),
            'created': time.time(),
            'modified': time.time()
        }
        return True
        
    def read_file(self, path: str) -> str:
        """Read a file from the simulated filesystem"""
        if path in self.filesystem:
            return self.filesystem[path]['content']
        return None
        
    def add_network_interface(self, interface_name: str, address: str) -> bool:
        """Add a network interface"""
        self.network_interfaces.append({
            'name': interface_name,
            'address': address,
            'status': 'up'
        })
        return True
        
    def get_system_hash(self) -> str:
        """Get a hash representing the current system state"""
        system_data = f"{self.node_id}{self.boot_time}{len(self.processes)}{len(self.filesystem)}{len(self.players)}{len(self.game_events)}"
        return hashlib.sha256(system_data.encode()).hexdigest()
        
    # Game-specific methods
    
    def add_player(self, player_id: str, player_data: Dict[str, Any]) -> bool:
        """Add a player to the game"""
        self.players[player_id] = {
            'data': player_data,
            'join_time': time.time(),
            'status': 'active'
        }
        return True
        
    def remove_player(self, player_id: str) -> bool:
        """Remove a player from the game"""
        if player_id in self.players:
            self.players[player_id]['status'] = 'disconnected'
            self.players[player_id]['leave_time'] = time.time()
            return True
        return False
        
    def update_game_state(self, state_data: Dict[str, Any]) -> bool:
        """Update the game state"""
        self.game_state.update(state_data)
        return True
        
    def get_game_state(self) -> Dict[str, Any]:
        """Get the current game state"""
        return self.game_state.copy()
        
    def add_game_event(self, event_type: str, event_data: Dict[str, Any]) -> str:
        """Add a game event"""
        event_id = str(uuid.uuid4())
        self.game_events.append({
            'id': event_id,
            'type': event_type,
            'data': event_data,
            'timestamp': time.time()
        })
        return event_id


def main():
    """Main function to demonstrate node functionality"""
    print("Starting Node OS Image for Forest Kingdoms RPG...")
    node = NodeOS()
    
    # Add some basic components
    node.add_network_interface('eth0', '192.168.1.100')
    node.create_file('/etc/hostname', f'node-{node.node_id[:8]}')
    node.create_process('init', '/sbin/init')
    
    # Add game-specific components
    node.add_player('player1', {'name': 'Alice', 'level': 1})
    node.update_game_state({'world_seed': 'forest123', 'time_of_day': 'day'})
    node.add_game_event('player_join', {'player_id': 'player1'})
    
    # Display node information
    info = node.get_node_info()
    print(f"Node ID: {info['node_id']}")
    print(f"Uptime: {info['uptime']:.2f} seconds")
    print(f"Processes: {info['process_count']}")
    print(f"Network interfaces: {info['network_interfaces']}")
    print(f"Players: {info['player_count']}")
    print(f"Events: {info['event_count']}")
    
    # Display system hash
    print(f"System Hash: {node.get_system_hash()[:16]}...")


if __name__ == '__main__':
    main()