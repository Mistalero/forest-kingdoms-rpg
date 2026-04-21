# Omni-Layer Decentralized Game Ecosystem

A fully decentralized, peer-to-peer gaming platform where every client is a node. Supports infinite recursive sessions (shards), polymorphic rendering (Voxel, Anime, 2D, Text, etc.), and runs anywhere from BIOS to browsers via Libretro.

## Architecture Overview

- **Core**: Unified game logic running in any environment (OS, Container, Bare Metal).
- **Network**: Serverless P2P mesh with dynamic sharding. Every player hosts/validates.
- **Visuals**: Client-side rendering only. Switch between Minecraft, Anime, 2D, Isometric, Text modes instantly without affecting game logic or other players.
- **Data**: Distributed state synchronization. No central database.
- **Platform**: Runs as a standalone executable, desktop shell, Libretro core, or embedded component.

## Features

- **Decentralized**: No central servers. Players form the network.
- **Polymorphic Rendering**: Each user chooses their own visual style independently.
- **Recursive Sessions**: Worlds inside worlds (shards within shards).
- **Cross-Platform**: Compiles for Windows, Linux, macOS, Android, iOS, WebAssembly, and RetroArch (Libretro).
- **Ephemeral**: No background daemons. The network exists only while the app is running.
- **Legacy Support**: Compatible with old hardware via adaptive rendering and Libretro integration.

## Project Structure

```text
/workspace
├── src/
│   ├── core/               # Main entry point and game logic
│   │   ├── Main.gd
│   │   └── InputHandler.gd
│   ├── network/            # P2P networking and shard management
│   │   └── NetworkManager.gd
│   ├── visual/             # Polymorphic rendering system
│   │   ├── VisualController.gd
│   │   └── renderers/      # Specific renderer implementations
│   │       ├── VoxelRenderer.gd
│   │       ├── AnimeRenderer.gd
│   │       ├── Sprite2DRenderer.gd
│   │       ├── IsometricRenderer.gd
│   │       ├── TextRenderer.gd
│   │       └── AsciiRenderer.gd
│   ├── data/               # Distributed state management
│   │   └── DataManager.gd
│   └── platform/           # Platform-specific adapters
│       └── libretro/       # Libretro core implementation
│           └── libretro_core.c
├── docs/                   # Documentation
└── README.md               # This file
```

## Usage

### Standalone Mode
Run the executable directly. It acts as a full node and game client.

```bash
./OmniLayerGame
```

### Libretro Mode
Compile `src/platform/libretro/libretro_core.c` as a shared library and load it in RetroArch.

```bash
gcc -shared -fPIC -o omnilayer_libretro.so src/platform/libretro/libretro_core.c
# Load omnilayer_libretro.so in RetroArch
```

### Configuration
Set environment variables to control behavior:
- `OMNI_ENV`: `bios`, `libretro`, `container`, or `standalone` (default).
- `OMNI_DAEMON`: `true` to keep running after closing the window (not recommended for privacy).

## Development

This project uses Godot Engine (GDScript) for the core logic but is designed to be engine-agnostic. The Libretro implementation is in C for maximum compatibility.

### Building
1. **Godot**: Open `project.godot` in Godot 4.x.
2. **Libretro**: Use a standard C compiler (gcc/clang) to build the core.

## License
MIT License.
