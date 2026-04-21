class_name VoxelBuilding
extends Node3D

## Dunia3D-style Building System
## Allows placing pre-fabricated structures in the voxel world
## Integrates with SkeleRealms factions and building skills

@export var building_schematics: Dictionary = {}

signal building_placed(building_type: String, position: Vector3)
signal building_removed(building_type: String, position: Vector3)

func _ready() -> void:
	load_default_schematics()
	print("[VoxelBuilding] Initialized with %d schematics" % building_schematics.size())

func load_default_schematics() -> void:
	# Small House (5x5x4)
	building_schematics["small_house"] = {
		"size": Vector3i(5, 4, 5),
		"blocks": [
			# Floor
			{"pos": Vector3i(0, 0, 0), "type": "wood"},
			{"pos": Vector3i(1, 0, 0), "type": "wood"},
			{"pos": Vector3i(2, 0, 0), "type": "wood"},
			{"pos": Vector3i(3, 0, 0), "type": "wood"},
			{"pos": Vector3i(4, 0, 0), "type": "wood"},
			{"pos": Vector3i(0, 0, 1), "type": "wood"},
			{"pos": Vector3i(1, 0, 1), "type": "wood"},
			{"pos": Vector3i(2, 0, 1), "type": "wood"},
			{"pos": Vector3i(3, 0, 1), "type": "wood"},
			{"pos": Vector3i(4, 0, 1), "type": "wood"},
			{"pos": Vector3i(0, 0, 2), "type": "wood"},
			{"pos": Vector3i(1, 0, 2), "type": "wood"},
			{"pos": Vector3i(2, 0, 2), "type": "wood"},
			{"pos": Vector3i(3, 0, 2), "type": "wood"},
			{"pos": Vector3i(4, 0, 2), "type": "wood"},
			{"pos": Vector3i(0, 0, 3), "type": "wood"},
			{"pos": Vector3i(1, 0, 3), "type": "wood"},
			{"pos": Vector3i(2, 0, 3), "type": "wood"},
			{"pos": Vector3i(3, 0, 3), "type": "wood"},
			{"pos": Vector3i(4, 0, 3), "type": "wood"},
			{"pos": Vector3i(0, 0, 4), "type": "wood"},
			{"pos": Vector3i(1, 0, 4), "type": "wood"},
			{"pos": Vector3i(2, 0, 4), "type": "wood"},
			{"pos": Vector3i(3, 0, 4), "type": "wood"},
			{"pos": Vector3i(4, 0, 4), "type": "wood"},
			
			# Walls
			{"pos": Vector3i(0, 1, 0), "type": "stone"},
			{"pos": Vector3i(0, 1, 1), "type": "stone"},
			{"pos": Vector3i(0, 1, 2), "type": "stone"},
			{"pos": Vector3i(0, 1, 3), "type": "stone"},
			{"pos": Vector3i(0, 1, 4), "type": "stone"},
			{"pos": Vector3i(4, 1, 0), "type": "stone"},
			{"pos": Vector3i(4, 1, 1), "type": "stone"},
			{"pos": Vector3i(4, 1, 2), "type": "stone"},
			{"pos": Vector3i(4, 1, 3), "type": "stone"},
			{"pos": Vector3i(4, 1, 4), "type": "stone"},
			{"pos": Vector3i(0, 1, 0), "type": "stone"},
			{"pos": Vector3i(1, 1, 0), "type": "stone"},
			{"pos": Vector3i(2, 1, 0), "type": "stone"},
			{"pos": Vector3i(3, 1, 0), "type": "stone"},
			{"pos": Vector3i(4, 1, 0), "type": "stone"},
			{"pos": Vector3i(0, 1, 4), "type": "stone"},
			{"pos": Vector3i(1, 1, 4), "type": "stone"},
			{"pos": Vector3i(2, 1, 4), "type": "stone"},
			{"pos": Vector3i(3, 1, 4), "type": "stone"},
			{"pos": Vector3i(4, 1, 4), "type": "stone"},
			
			# Door opening (skip some blocks)
			# Roof would go here at y=2,3
		]
	}
	
	# Tower (3x8x3)
	building_schematics["tower"] = {
		"size": Vector3i(3, 8, 3),
		"blocks": []
	}
	for y in range(8):
		for x in range(3):
			for z in range(3):
				if x == 0 or x == 2 or z == 0 or z == 2:
					building_schematics["tower"]["blocks"].append({
						"pos": Vector3i(x, y, z),
						"type": "stone_brick" if y > 0 else "stone"
					})
	
	# Bridge (10x1x3)
	building_schematics["bridge"] = {
		"size": Vector3i(10, 1, 3),
		"blocks": []
	}
	for x in range(10):
		for z in range(3):
			building_schematics["bridge"]["blocks"].append({
				"pos": Vector3i(x, 0, z),
				"type": "wood_plank"
			})
	
	print("[VoxelBuilding] Loaded default schematics: small_house, tower, bridge")

func place_building(building_type: String, origin_pos: Vector3i, voxel_world: Node) -> bool:
	if not building_schematics.has(building_type):
		push_error("[VoxelBuilding] Unknown building type: %s" % building_type)
		return false
	
	var schematic = building_schematics[building_type]
	var placed_blocks = 0
	
	for block_data in schematic.blocks:
		var world_pos = Vector3(
			origin_pos.x + block_data.pos.x,
			origin_pos.y + block_data.pos.y,
			origin_pos.z + block_data.pos.z
		)
		
		if voxel_world.has_method("set_block"):
			voxel_world.set_block(world_pos, block_data.type)
			placed_blocks += 1
	
	if placed_blocks > 0:
		emit_signal("building_placed", building_type, Vector3(origin_pos))
		
		# Add building XP via SkeleRealms
		if Engine.has_singleton("SkeleRealmsIntegration"):
			var integration = Engine.get_singleton("SkeleRealmsIntegration")
			if integration.has_method("add_skill_xp"):
				integration.add_skill_xp("building", placed_blocks * 5)
		
		print("[VoxelBuilding] Placed %s at %s (%d blocks)" % [building_type, str(origin_pos), placed_blocks])
		return true
	
	return false

func remove_building(building_type: String, origin_pos: Vector3i, voxel_world: Node) -> bool:
	if not building_schematics.has(building_type):
		push_error("[VoxelBuilding] Unknown building type: %s" % building_type)
		return false
	
	var schematic = building_schematics[building_type]
	var removed_blocks = 0
	
	for block_data in schematic.blocks:
		var world_pos = Vector3(
			origin_pos.x + block_data.pos.x,
			origin_pos.y + block_data.pos.y,
			origin_pos.z + block_data.pos.z
		)
		
		if voxel_world.has_method("set_block"):
			voxel_world.set_block(world_pos, "")
			removed_blocks += 1
	
	if removed_blocks > 0:
		emit_signal("building_removed", building_type, Vector3(origin_pos))
		print("[VoxelBuilding] Removed %s at %s (%d blocks)" % [building_type, str(origin_pos), removed_blocks])
		return true
	
	return false

func get_building_requirements(building_type: String) -> Dictionary:
	# Return required materials for building
	var requirements = {}
	
	if not building_schematics.has(building_type):
		return requirements
	
	var schematic = building_schematics[building_type]
	for block_data in schematic.blocks:
		var block_type = block_data.type
		requirements[block_type] = requirements.get(block_type, 0) + 1
	
	return requirements

func can_build_here(building_type: String, origin_pos: Vector3i, voxel_world: Node) -> bool:
	if not building_schematics.has(building_type):
		return false
	
	var schematic = building_schematics[building_type]
	
	for block_data in schematic.blocks:
		var world_pos = Vector3(
			origin_pos.x + block_data.pos.x,
			origin_pos.y + block_data.pos.y,
			origin_pos.z + block_data.pos.z
		)
		
		if voxel_world.has_method("get_block"):
			var existing_block = voxel_world.get_block(world_pos)
			if existing_block != "":
				return false  # Space already occupied
	
	return true

func get_available_buildings() -> Array:
	return building_schematics.keys()

func save_buildings(save_path: String) -> void:
	# Save placed buildings to file
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		var data = {"schematics": building_schematics}
		file.store_string(JSON.stringify(data))
		file.close()
		print("[VoxelBuilding] Buildings saved to %s" % save_path)

func load_buildings(save_path: String) -> void:
	if not FileAccess.file_exists(save_path):
		return
	
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		var json_str = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_str)
		if error == OK:
			var data = json.data
			if data.has("schematics"):
				building_schematics.merge(data.schematics, true)
				print("[VoxelBuilding] Buildings loaded from %s" % save_path)
