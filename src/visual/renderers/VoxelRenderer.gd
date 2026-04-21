extends Node

## Basic Voxel Renderer.
## Renders world data as voxels (Minecraft-style).

var voxel_size: float = 1.0
var render_distance: int = 8

func _ready():
	print("[VoxelRenderer] Initialized.")
	# Setup voxel mesh generation logic here

func render_chunk(data: Dictionary):
	# Generate mesh from voxel data
	pass

func set_quality(level: int):
	match level:
		0: # Low
			render_distance = 4
			voxel_size = 1.0
		1: # Medium
			render_distance = 8
		2: # High
			render_distance = 16
		3: # Ultra
			render_distance = 32
