class_name VoxelWorld
extends Node3D

## Dunia3D-style Voxel World Implementation
## Based on https://github.com/MidooCherni/dunia3d architecture
## Integrates with Forest Kingdoms RPG + SkeleRealms

@export var chunk_size: int = 16
@export var render_distance: int = 4
@export var noise_seed: int = 12345
@export var height_scale: float = 10.0

var chunks: Dictionary = {}
var noise: FastNoiseLite
var mesh_cache: Dictionary = {}

signal chunk_loaded(chunk_pos: Vector3i)
signal chunk_unloaded(chunk_pos: Vector3i)

func _ready() -> void:
	noise = FastNoiseLite.new()
	noise.seed = noise_seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.05
	
	print("[VoxelWorld] Initialized with Dunia3D architecture")
	print("[VoxelWorld] Chunk size: %d, Render distance: %d" % [chunk_size, render_distance])

func _process(_delta: float) -> void:
	var player_pos = get_player_position()
	if player_pos == Vector3.ZERO:
		return
	
	update_chunks(player_pos)

func get_player_position() -> Vector3:
	var player = get_tree().get_first_node_in_group("player")
	if player and player is Node3D:
		return player.global_position
	return Vector3.ZERO

func update_chunks(player_pos: Vector3) -> void:
	var current_chunk = world_to_chunk(player_pos)
	
	# Load new chunks
	for x in range(-render_distance, render_distance + 1):
		for z in range(-render_distance, render_distance + 1):
			var chunk_pos = Vector3i(current_chunk.x + x, 0, current_chunk.z + z)
			if not chunks.has(chunk_pos):
				load_chunk(chunk_pos)
	
	# Unload distant chunks
	var chunks_to_remove = []
	for chunk_pos in chunks.keys():
		var dist = abs(chunk_pos.x - current_chunk.x) + abs(chunk_pos.z - current_chunk.z)
		if dist > render_distance + 1:
			chunks_to_remove.append(chunk_pos)
	
	for chunk_pos in chunks_to_remove:
		unload_chunk(chunk_pos)

func world_to_chunk(world_pos: Vector3) -> Vector3i:
	return Vector3i(
		floor(world_pos.x / chunk_size),
		0,
		floor(world_pos.z / chunk_size)
	)

func chunk_to_world(chunk_pos: Vector3i) -> Vector3:
	return Vector3(
		chunk_pos.x * chunk_size,
		0,
		chunk_pos.z * chunk_size
	)

func load_chunk(chunk_pos: Vector3i) -> void:
	if chunks.has(chunk_pos):
		return
	
	var chunk_data = generate_chunk(chunk_pos)
	chunks[chunk_pos] = chunk_data
	
	var mesh = build_chunk_mesh(chunk_data)
	var mesh_node = MeshInstance3D.new()
	mesh_node.mesh = mesh
	mesh_node.position = chunk_to_world(chunk_pos)
	mesh_node.name = "Chunk_%d_%d" % [chunk_pos.x, chunk_pos.z]
	add_child(mesh_node)
	
	chunk_data.mesh_node = mesh_node
	
	emit_signal("chunk_loaded", chunk_pos)
	print("[VoxelWorld] Loaded chunk at %s" % str(chunk_pos))

func unload_chunk(chunk_pos: Vector3i) -> void:
	if not chunks.has(chunk_pos):
		return
	
	var chunk_data = chunks[chunk_pos]
	if chunk_data.has("mesh_node") and chunk_data.mesh_node:
		chunk_data.mesh_node.queue_free()
	
	chunks.erase(chunk_pos)
	emit_signal("chunk_unloaded", chunk_pos)
	print("[VoxelWorld] Unloaded chunk at %s" % str(chunk_pos))

func generate_chunk(chunk_pos: Vector3i) -> Dictionary:
	var chunk_data = {
		"blocks": {},
		"mesh_node": null,
		"modified": false
	}
	
	for x in range(chunk_size):
		for z in range(chunk_size):
			var world_x = chunk_pos.x * chunk_size + x
			var world_z = chunk_pos.z * chunk_size + z
			
			var height = noise.get_noise_2d(world_x, world_z) * height_scale
			var surface_y = floor(height)
			
			for y in range(surface_y, -3):
				var block_type = get_block_type(y, surface_y)
				chunk_data.blocks[Vector3i(x, y, z)] = block_type
	
	return chunk_data

func get_block_type(y: int, surface_y: int) -> String:
	if y == surface_y:
		return "grass"
	elif y > surface_y - 3:
		return "dirt"
	else:
		return "stone"

func build_chunk_mesh(chunk_data: Dictionary) -> ArrayMesh:
	var surfaces = {}
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	var indices = PackedInt32Array()
	
	for block_pos in chunk_data.blocks.keys():
		var block_type = chunk_data.blocks[block_pos]
		
		# Check if block is visible (has at least one face exposed)
		if not is_block_visible(chunk_data, block_pos):
			continue
		
		add_block_mesh(vertices, normals, uvs, indices, block_pos, block_type, surfaces)
	
	var mesh = ArrayMesh.new()
	if vertices.size() > 0:
		var arrays = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_NORMAL] = normals
		arrays[Mesh.ARRAY_TEX_UV] = uvs
		arrays[Mesh.ARRAY_INDEX] = indices
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	return mesh

func is_block_visible(chunk_data: Dictionary, pos: Vector3i) -> bool:
	var neighbors = [
		Vector3i(1, 0, 0), Vector3i(-1, 0, 0),
		Vector3i(0, 1, 0), Vector3i(0, -1, 0),
		Vector3i(0, 0, 1), Vector3i(0, 0, -1)
	]
	
	for neighbor in neighbors:
		var check_pos = pos + neighbor
		if not chunk_data.blocks.has(check_pos):
			return true
	return false

func add_block_mesh(vertices: PackedVector3Array, normals: PackedVector3Array, 
					uvs: PackedVector2Array, indices: PackedInt32Array,
					pos: Vector3i, block_type: String, surfaces: Dictionary) -> void:
	# Simple cube mesh generation
	var base_index = vertices.size()
	
	# Cube vertices (relative to block position)
	var cube_verts = [
		Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(1, 1, 0), Vector3(0, 1, 0),
		Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 1, 1), Vector3(0, 1, 1)
	]
	
	for vert in cube_verts:
		vertices.append(Vector3(pos.x + vert.x, pos.y + vert.y, pos.z + vert.z))
		normals.append(Vector3(0, 1, 0))  # Simplified normals
		uvs.append(Vector2(vert.x, vert.y))
	
	# Cube indices (12 triangles for 6 faces)
	var cube_indices = [
		0, 2, 1, 0, 3, 2,  # Front
		1, 6, 5, 1, 2, 6,  # Right
		2, 7, 6, 2, 3, 7,  # Back
		3, 4, 7, 3, 0, 4,  # Left
		5, 4, 6, 4, 7, 6,  # Top
		0, 1, 5, 0, 5, 4   # Bottom
	]
	
	for idx in cube_indices:
		indices.append(base_index + idx)

func set_block(world_pos: Vector3, block_type: String) -> void:
	var chunk_pos = world_to_chunk(world_pos)
	if not chunks.has(chunk_pos):
		return
	
	var local_pos = Vector3i(
		world_pos.x - chunk_pos.x * chunk_size,
		world_pos.y,
		world_pos.z - chunk_pos.z * chunk_size
	)
	
	var chunk_data = chunks[chunk_pos]
	chunk_data.blocks[local_pos] = block_type
	chunk_data.modified = true
	
	# Rebuild mesh
	if chunk_data.has("mesh_node"):
		chunk_data.mesh_node.queue_free()
	var new_mesh = build_chunk_mesh(chunk_data)
	var new_mesh_node = MeshInstance3D.new()
	new_mesh_node.mesh = new_mesh
	new_mesh_node.position = chunk_to_world(chunk_pos)
	new_mesh_node.name = "Chunk_%d_%d" % [chunk_pos.x, chunk_pos.z]
	add_child(new_mesh_node)
	chunk_data.mesh_node = new_mesh_node
	
	print("[VoxelWorld] Set block at %s to %s" % [str(world_pos), block_type])

func get_block(world_pos: Vector3) -> String:
	var chunk_pos = world_to_chunk(world_pos)
	if not chunks.has(chunk_pos):
		return ""
	
	var local_pos = Vector3i(
		world_pos.x - chunk_pos.x * chunk_size,
		world_pos.y,
		world_pos.z - chunk_pos.z * chunk_size
	)
	
	var chunk_data = chunks[chunk_pos]
	return chunk_data.blocks.get(local_pos, "")

func save_world(save_path: String) -> void:
	var save_data = {
		"chunks": {},
		"seed": noise_seed
	}
	
	for chunk_pos in chunks.keys():
		var chunk_data = chunks[chunk_pos]
		if chunk_data.modified:
			save_data.chunks[str(chunk_pos)] = chunk_data.blocks
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("[VoxelWorld] World saved to %s" % save_path)

func load_world(save_path: String) -> void:
	if not FileAccess.file_exists(save_path):
		return
	
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		var json_str = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_str)
		if error == OK:
			var save_data = json.data
			noise_seed = save_data.get("seed", noise_seed)
			
			for chunk_key in save_data.chunks.keys():
				var chunk_pos = str_to_var(chunk_key)
				if chunk_pos is Vector3i:
					var chunk_data = {
						"blocks": save_data.chunks[chunk_key],
						"mesh_node": null,
						"modified": false
					}
					chunks[chunk_pos] = chunk_data
					load_chunk(chunk_pos)
			
			print("[VoxelWorld] World loaded from %s" % save_path)
