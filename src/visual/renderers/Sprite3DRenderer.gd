extends Node3D
class_name Sprite3DRenderer

## Спрайтовое 3D (Billboard) рендерер
## Отображает 3D мир с помощью 2D спрайтов, всегда повернутых к камере

@export var default_sprite_size: float = 1.0

var sprite_cache: Dictionary = {}

func _ready():
print("[Sprite3DRenderer] Инициализация спрайтового 3D рендерера")

func create_billboard(position: Vector3, texture: Texture2D, size: float = default_sprite_size):
"""Создание billboard спрайта"""
var sprite = Sprite3D.new()
sprite.position = position
sprite.texture = texture
sprite.pixel_size = size
sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED

add_child(sprite)
return sprite

func render_sprite(x: int, y: int, z: int, sprite_type: int):
"""Рендеринг спрайта в позиции"""
var key = "%d,%d,%d" % [x, y, z]

if not sprite_cache.has(key):
create_sprite(x, y, z, sprite_type)
else:
update_sprite(key, sprite_type)

func create_sprite(x: int, y: int, z: int, sprite_type: int):
"""Создание спрайта"""
var sprite = Sprite3D.new()
sprite.position = Vector3(x, y, z)
sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
sprite.pixel_size = default_sprite_size

sprite_cache["%d,%d,%d" % [x, y, z]] = sprite
add_child(sprite)

func update_sprite(key: String, sprite_type: int):
"""Обновление спрайта"""
pass

func set_quality(level: int):
"""Настройка качества"""
match level:
0: # Low
default_sprite_size = 0.5
1: # Medium
default_sprite_size = 1.0
2: # High
default_sprite_size = 2.0
3: # Ultra
default_sprite_size = 4.0

func clear_all():
"""Очистка"""
for key in sprite_cache.keys():
if is_instance_valid(sprite_cache[key]):
sprite_cache[key].queue_free()
sprite_cache.clear()
