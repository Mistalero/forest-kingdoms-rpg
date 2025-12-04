# MMORPG Core Component

## Component Purpose

The MMORPG Core component provides foundational infrastructure for running a massively multiplayer online role-playing game in a decentralized P2P environment. This component handles player management, world state synchronization, entity management, and inter-player interactions.

## Features

- Player management and authentication
- World state synchronization across P2P nodes
- Entity management (players, NPCs, items, etc.)
- Real-time communication between players
- Event-based interaction system
- Conflict resolution for decentralized state updates
- Support for different game zones and areas
- Integration with faction system

## Component API

### Methods

- `initialize(config)` - Initialize the MMORPG core with configuration
- `registerPlayer(playerData)` - Register a new player in the system
- `getPlayerState(playerId)` - Get current state of a player
- `updatePlayerState(playerId, stateData)` - Update player state
- `getWorldState()` - Get current world state
- `updateWorldState(stateData)` - Update world state
- `sendMessage(messageData)` - Send message between players
- `processGameEvent(eventData)` - Process game events
- `getZoneInfo(zoneId)` - Get information about a game zone
- `movePlayerToZone(playerId, zoneId)` - Move player to a different zone

### Events

- `player.joined` - Fired when a player joins the game
- `player.left` - Fired when a player leaves the game
- `player.stateChanged` - Fired when player state changes
- `world.stateChanged` - Fired when world state changes
- `message.received` - Fired when a message is received
- `zone.entered` - Fired when a player enters a zone
- `zone.exited` - Fired when a player exits a zone
- `entity.created` - Fired when a new entity is created
- `entity.destroyed` - Fired when an entity is destroyed

## Configuration

The component can be configured using the default configuration file in `config/default.json`.

## Dependencies

- P2P Node Core Components
- Event System
- Cryptographic Identity Management