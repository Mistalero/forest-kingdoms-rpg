extends Node3D
class_name IsometricRenderer

## Изометрический рендерер
## Отображает мир в изометрической проекции

@export var tile_width: float = 64.0
@export var tile_height: float = 32.0

var iso_tiles: Dictionary = {}

func _ready():
print("[IsometricRenderer] Инициализация изометрического рендерера")
setup_camera()

func setup_camera():
var camera = Camera3D.new()
camera.position = Vector3(0, 50, 0)
camera.rotation_degrees = Vector3(60, 0, 0)
add_child(camera)

func cartesian_to_isometric(x: float, y: float) -> Vector2:
"""Преобразование декартовых координат в изометрические"""
var iso_x = (x - y) * tile_width / 2
var iso_y = (x + y) * tile_height / 2
return Vector2(iso_x, iso_y)

func render_tile(grid_x: int, grid_y: int, tile_type: int):
"""Рендеринг изометрического тайла"""
var key = "%d,%d" % [grid_x, grid_y]

if not iso_tiles.has(key):
create_iso_tile(grid_x, grid_y, tile_type)
else:
update_iso_tile(key, tile_type)

func create_iso_tile(grid_x: int, grid_y: int, tile_type: int):
"""Создание изометрического тайла"""
var pos = cartesian_to_isometric(grid_x, grid_y)

var mesh_instance = MeshInstance3D.new()
var plane = PlaneMesh.new()
plane.size = Vector2(tile_width, tile_height)
mesh_instance.mesh = plane
mesh_instance.position = Vector3(pos.x, 0, pos.y)
mesh_instance.rotation_degrees = Vector3(90, 0, 0)

iso_tiles["%d,%d" % [grid_x, grid_y]] = mesh_instance
add_child(mesh_instance)

func update_iso_tile(key: String, tile_type: int):
"""Обновление тайла"""
pass

func set_quality(level: int):
"""Настройка качества"""
match level:
0: # Low
tile_width = 32.0
tile_height = 16.0
1: # Medium
tile_width = 64.0
tile_height = 32.0
2: # High
tile_width = 128.0
tile_height = 64.0
3: # Ultra
tile_width = 256.0
tile_height = 128.0

func clear_all():
"""Очистка"""
for key in iso_tiles.keys():
if is_instance_valid(iso_tiles[key]):
iso_tiles[key].queue_free()
iso_tiles.clear()
