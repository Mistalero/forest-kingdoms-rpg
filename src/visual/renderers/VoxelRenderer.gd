extends Node
class_name VoxelRenderer

## Воксельный рендерер (Minecraft-стиль)
## Отображает мир в виде блоков

signal chunks_loaded(count: int)

@export var chunk_size: int = 16
@export var render_distance: int = 8
@export var material: Material

var _world: Node3D
var _chunks: Dictionary = {} # chunk_key -> MeshInstance3D

func _ready():
	_world = Node3D.new()
	_world.name = "VoxelWorld"
	add_child(_world)

func enable():
	_world.visible = true
	print("[VoxelRenderer] Enabled")

func disable():
	_world.visible = false
	print("[VoxelRenderer] Disabled")

func render_chunk(chunk_x: int, chunk_y: int, chunk_z: int, data: Array):
	"""Рендеринг конкретного чанка"""
	var key = "%d_%d_%d" % [chunk_x, chunk_y, chunk_z]
	
	if _chunks.has(key):
		_update_chunk_mesh(key, data)
	else:
		_create_chunk_mesh(key, chunk_x, chunk_y, chunk_z, data)

func clear():
	"""Очистка всех чанков"""
	for child in _world.get_children():
		child.queue_free()
	_chunks.clear()
	print("[VoxelRenderer] Cleared all chunks")

func apply_quality(settings):
	"""Применение настроек качества"""
	if settings.has("render_distance"):
		render_distance = settings["render_distance"]
	print("[VoxelRenderer] Quality applied: ", settings)

func _create_chunk_mesh(key: String, cx: int, cy: int, cz: int, data: Array):
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "Chunk_" + key
	
	var array_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	
	# Генерация геометрии чанка (упрощенно)
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	
	for i in range(0, min(data.size(), 100)): # Пример обработки
		var vx = (i % chunk_size) + cx * chunk_size
		var vy = ((i / chunk_size) % chunk_size) + cy * chunk_size
		var vz = ((i / chunk_size / chunk_size) % chunk_size) + cz * chunk_size
		
		if data[i] > 0: # Если блок не воздух
			_add_cube_vertices(vertices, normals, uvs, Vector3(vx, vy, vz))
	
	if vertices.size() > 0:
		arrays[ArrayMesh.ARRAY_VERTEX] = vertices
		arrays[ArrayMesh.ARRAY_NORMAL] = normals
		arrays[ArrayMesh.ARRAY_TEX_UV] = uvs
		
		array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		mesh_instance.mesh = array_mesh
		
		if material:
			mesh_instance.set_surface_override_material(0, material)
		
		_world.add_child(mesh_instance)
		_chunks[key] = mesh_instance

func _update_chunk_mesh(key: String, data: Array):
	# Пересоздание меша при изменении данных
	if _chunks.has(key):
		var old_mesh = _chunks[key]
		old_mesh.queue_free()
		_chunks.erase(key)
	
	var parts = key.split("_")
	if parts.size() == 3:
		_create_chunk_mesh(key, parts[0].to_int(), parts[1].to_int(), parts[2].to_int(), data)

func _add_cube_vertices(verts: PackedVector3Array, norms: PackedVector3Array, uvs: PackedVector2Array, pos: Vector3):
	"""Добавление вершин куба"""
	var size = 1.0
	var half = size / 2.0
	
	# Простая генерация куба (6 граней)
	# Верх
	verts.push_back(pos + Vector3(-half, half, -half))
	verts.push_back(pos + Vector3(half, half, -half))
	verts.push_back(pos + Vector3(half, half, half))
	verts.push_back(pos + Vector3(-half, half, -half))
	verts.push_back(pos + Vector3(half, half, half))
	verts.push_back(pos + Vector3(-half, half, half))
	
	for i in range(6):
		norms.push_back(Vector3.UP)
		uvs.push_back(Vector2(i % 2, i / 2))
