extends Node
class_name InputHandler

## Универсальный обработчик ввода для всех платформ
## Абстрагирует ввод от клавиатуры, мыши, геймпадов и сенсорных экранов

signal input_action_pressed(action: String, value: float)
signal input_action_released(action: String)
signal input_axis_changed(axis: String, value: float)

# Маппинг действий
var action_map: Dictionary = {
"move_forward": ["w", "up", "gamepad_l2"],
"move_backward": ["s", "down", "gamepad_r2"],
"move_left": ["a", "left"],
"move_right": ["d", "right"],
"jump": ["space", "gamepad_a", "gamepad_cross"],
"interact": ["e", "gamepad_x", "gamepad_square"],
"menu": ["escape", "gamepad_start"],
"visual_toggle": ["f1"],
"network_toggle": ["f2"]
}

# Состояние ввода
var active_actions: Dictionary = {}
var axis_values: Dictionary = {}

func _ready():
setup_input_map()
print("[InputHandler] Обработчик ввода готов")

func setup_input_map():
"""Настраивает карту ввода динамически"""
for action in action_map.keys():
if not InputMap.has_action(action):
InputMap.add_action(action)

for key in action_map[action]:
var event = create_input_event(key)
if event:
InputMap.action_add_event(action, event)

func create_input_event(key: String) -> InputEvent:
"""Создает событие ввода по строковому идентификатору"""
key = key.to_lower()

# Клавиатура
if key.length() == 1:
var event = InputEventKey.new()
event.keycode = key.to_upper().unicode_at(0)
return event

# Специальные клавиши
match key:
"space":
var event = InputEventKey.new()
event.keycode = KEY_SPACE
return event
"up":
var event = InputEventKey.new()
event.keycode = KEY_UP
return event
"down":
var event = InputEventKey.new()
event.keycode = KEY_DOWN
return event
"left":
var event = InputEventKey.new()
event.keycode = KEY_LEFT
return event
"right":
var event = InputEventKey.new()
event.keycode = KEY_RIGHT
return event
"escape":
var event = InputEventKey.new()
event.keycode = KEY_ESCAPE
return event

# Геймпад
if key.begins_with("gamepad_"):
var event = InputEventJoypadButton.new()
var button_name = key.replace("gamepad_", "")
# Маппинг кнопок геймпада (упрощенный)
match button_name:
"a", "cross":
event.button_index = JOY_BUTTON_A
return event
"b", "circle":
event.button_index = JOY_BUTTON_B
return event
"x", "square":
event.button_index = JOY_BUTTON_X
return event
"y", "triangle":
event.button_index = JOY_BUTTON_Y
return event
"start":
event.button_index = JOY_BUTTON_START
return event
"l2":
event.button_index = JOY_BUTTON_LEFT_SHOULDER
return event
"r2":
event.button_index = JOY_BUTTON_RIGHT_SHOULDER
return event

return null

func _input(event):
"""Обрабатывает входящие события ввода"""
if event is InputEventKey or event is InputEventJoypadButton:
for action in action_map.keys():
if Input.is_action_pressed(action):
if not active_actions.get(action, false):
active_actions[action] = true
input_action_pressed.emit(action, 1.0)
else:
if active_actions.get(action, false):
active_actions[action] = false
input_action_released.emit(action)

elif event is InputEventJoypadMotion:
# Обработка осей геймпада
pass

func get_action_strength(action: String) -> float:
"""Возвращает силу нажатия действия"""
return Input.get_action_strength(action) if InputMap.has_action(action) else 0.0

func get_axis_value(axis: String) -> float:
"""Возвращает значение оси"""
return axis_values.get(axis, 0.0)

func is_action_pressed(action: String) -> bool:
"""Проверяет, нажато ли действие"""
return Input.is_action_pressed(action) if InputMap.has_action(action) else false

func vibrate_gamepad(device: int = 0, duration: float = 0.5, weak_magnitude: float = 1.0, strong_magnitude: float = 1.0):
"""Вибрирует геймпад"""
Input.start_joy_vibration(device, weak_magnitude, strong_magnitude, duration)
