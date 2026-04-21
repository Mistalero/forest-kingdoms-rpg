extends Control
class_name ASCIIRenderer

## ASCII рендерер для ретро-отображения
## Использует символы ASCII для представления графики

@export var ascii_chars: String = " .:-=+*#%@"
@export var char_width: int = 8
@export var char_height: int = 16

var ascii_grid: Array[String] = []
var grid_width: int = 80
var grid_height: int = 50

func _ready():
print("[ASCIIRenderer] Инициализация ASCII рендерера")
setup_ascii_display()
init_grid()

func setup_ascii_display():
var label = RichTextLabel.new()
label.bbcode_enabled = false
label.scroll_active = true
label.name = "ASCIIDisplay"
add_child(label)

func init_grid():
for i in range(grid_height):
ascii_grid.append("".lpad(grid_width, ' '))

func render_ascii_point(x: int, y: int, brightness: float):
"""Рендеринг точки ASCII на основе яркости"""
var char_index = int(brightness * (ascii_chars.length() - 1))
char_index = clamp(char_index, 0, ascii_chars.length() - 1)
var char = ascii_chars[char_index]

if y >= 0 and y < grid_height and x >= 0 and x < grid_width:
var row = ascii_grid[y]
if x < row.length():
ascii_grid[y] = row.substr(0, x) + char + row.substr(x + 1)
else:
ascii_grid[y] = row.lpad(x, ' ') + char

update_display()

func render_ascii_frame(frame_data: Array[String]):
"""Рендеринг кадра ASCII"""
for y in range(min(frame_data.size(), grid_height)):
ascii_grid[y] = frame_data[y].substr(0, min(frame_data[y].length(), grid_width))
update_display()

func update_display():
"""Обновление отображения"""
var label = get_node_or_null("ASCIIDisplay") as RichTextLabel
if label:
label.text = ""
for line in ascii_grid:
label.text += line + "\n"

func clear_screen():
"""Очистка экрана"""
init_grid()
update_display()

func set_quality(level: int):
"""Настройка качества (разрешение сетки)"""
match level:
0: # Low
grid_width = 40
grid_height = 25
1: # Medium
grid_width = 80
grid_height = 50
2: # High
grid_width = 160
grid_height = 100
3: # Ultra
grid_width = 320
grid_height = 200

init_grid()

func render_3d_to_ascii(world_data: Dictionary):
"""Конвертация 3D данных в ASCII"""
# Простая проекция 3D -> ASCII
clear_screen()

for key in world_data:
var pos = key.split(",")
if pos.size() >= 3:
var x = int(pos[0]) % grid_width
var y = int(pos[1]) % grid_height
var brightness = float(world_data[key]) if world_data[key] is float else 0.5
render_ascii_point(x, y, brightness)
