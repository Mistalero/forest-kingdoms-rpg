extends Control
class_name TextRenderer

## Текстовый рендерер для терминального/ASCII отображения
## Поддерживает текстовые интерфейсы и ASCII-графику

@export var font_size: int = 14
@export var monospace_font: Font

var text_buffer: Array[String] = []
var max_lines: int = 50

func _ready():
print("[TextRenderer] Инициализация текстового рендерера")
setup_text_display()

func setup_text_display():
var label = RichTextLabel.new()
label.bbcode_enabled = true
label.scroll_active = true
label.name = "TextDisplay"
add_child(label)

func render_text(x: int, y: int, char: String, color: Color = Colors.WHITE):
"""Рендеринг символа в позиции"""
while text_buffer.size() <= y:
text_buffer.append("")

if x < text_buffer[y].length():
text_buffer[y] = text_buffer[y].substr(0, x) + char + text_buffer[y].substr(x + 1)
else:
while text_buffer[y].length() < x:
text_buffer[y] += " "
text_buffer[y] += char

update_display()

func render_line(y: int, line: String):
"""Рендеринг строки текста"""
while text_buffer.size() <= y:
text_buffer.append("")
text_buffer[y] = line
update_display()

func render_ascii_art(art_data: Array[String], offset_x: int = 0, offset_y: int = 0):
"""Рендеринг ASCII-арта"""
for i in range(art_data.size()):
render_line(offset_y + i, art_data[i])

func clear_screen():
"""Очистка экрана"""
text_buffer.clear()
update_display()

func update_display():
"""Обновление отображения"""
var label = get_node_or_null("TextDisplay") as RichTextLabel
if label:
label.text = ""
for line in text_buffer:
label.text += line + "\n"

func set_quality(level: int):
"""Настройка качества (размер шрифта)"""
match level:
0: # Low
font_size = 8
1: # Medium
font_size = 12
2: # High
font_size = 16
3: # Ultra
font_size = 20

func print_message(message: String):
"""Вывод сообщения"""
text_buffer.append(message)
if text_buffer.size() > max_lines:
text_buffer.remove_at(0)
update_display()
