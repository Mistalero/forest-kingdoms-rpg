extends Node2D
class_name Renderer2D

## 2D рендерер для плоского отображения мира
## Поддерживает вид сверху, сбоку или изометрию

@export var tile_size: int = 32
@export var camera_speed: float = 10.0

var tile_cache: Dictionary = {}
var entities: Array = []

func _ready():
print("[Renderer2D] Инициализация 2D рендерера")
setup_camera()

func setup_camera():
var camera = Camera2D.new()
add_child(camera)

func render_tile(x: int, y: int, tile_type: int):
"""Рендеринг тайла"""
var key = "%d,%d" % [x, y]

if not tile_cache.has(key):
create_tile(x, y, tile_type)
else:
update_tile(key, tile_type)

func create_tile(x: int, y: int, tile_type: int):
"""Создание тайла"""
var sprite = Sprite2D.new()
sprite.position = Vector2(x * tile_size, y * tile_size)
# Установка текстуры в зависимости от tile_type
tile_cache["%d,%d" % [x, y]] = sprite
add_child(sprite)

func update_tile(key: String, tile_type: int):
"""Обновление тайла"""
if tile_cache.has(key):
pass # Обновление текстуры

func spawn_entity(position: Vector2, entity_data: Dictionary):
"""Спавн сущности"""
var entity = Sprite2D.new()
entity.position = position
entities.append(entity)
add_child(entity)
return entity

func set_quality(level: int):
"""Настройка качества"""
match level:
0: # Low
tile_size = 16
1: # Medium
tile_size = 32
2: # High
tile_size = 64
3: # Ultra
tile_size = 128

func clear_all():
"""Очистка"""
for key in tile_cache.keys():
if is_instance_valid(tile_cache[key]):
tile_cache[key].queue_free()
tile_cache.clear()

for entity in entities:
if is_instance_valid(entity):
entity.queue_free()
entities.clear()
