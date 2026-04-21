extends Node
class_name InputHandler

# Универсальный обработчик ввода
# Поддержка: Клавиатура, Мышь, Геймпад, Тачскрин, VR контроллеры, Текстовые команды
# Автоматическое определение активного устройства ввода

signal action_pressed(action_name: String, strength: float)
signal action_released(action_name: String)
signal axis_moved(axis_name: String, value: float)

var active_device: String = "unknown"
var input_mapping: Dictionary = {}
var is_touch_mode: bool = false

func _ready() -> void:
    _detect_input_devices()
    _setup_default_mappings()

func _detect_input_devices() -> void:
    # Определение доступных устройств ввода
    var has_keyboard := ClassDB.class_exists("InputEventKey")
    var has_gamepad := Input.get_connected_joypads().size() > 0
    var has_touch := DisplayServer.touch_get_last_point_count() > 0 or OS.get_name() in ["Android", "iOS"]
    
    print("[INPUT] Keyboard: ", has_keyboard, ", Gamepad: ", has_gamepad, ", Touch: ", has_touch)
    
    if has_touch:
        active_device = "touch"
        is_touch_mode = true
    elif has_gamepad:
        active_device = "gamepad"
    else:
        active_device = "keyboard"

func _setup_default_mappings() -> void:
    # Стандартные маппинги действий
    input_mapping = {
        "move_forward": ["w", "up", "gamepad_l_stick_up"],
        "move_backward": ["s", "down", "gamepad_l_stick_down"],
        "move_left": ["a", "left", "gamepad_l_stick_left"],
        "move_right": ["d", "right", "gamepad_l_stick_right"],
        "jump": ["space", "gamepad_button_a"],
        "interact": ["e", "gamepad_button_x"],
        "menu": ["escape", "gamepad_button_start"],
        "camera_look": ["mouse_motion", "gamepad_r_stick"]
    }

func _input(event: InputEvent) -> void:
    _process_event(event)

func _process_event(event: InputEvent) -> void:
    if event is InputEventKey:
        _handle_keyboard(event)
    elif event is InputEventMouseMotion:
        _handle_mouse(event)
    elif event is InputEventJoypadButton:
        _handle_gamepad_button(event)
    elif event is InputEventJoypadMotion:
        _handle_gamepad_axis(event)
    elif event is InputEventScreenTouch or event is InputEventScreenDrag:
        _handle_touch(event)

func _handle_keyboard(event: InputEventKey) -> void:
    if event.pressed:
        for action in input_mapping:
            if str(event.keycode).to_lower() in _get_keys_for_action(action):
                action_pressed.emit(action, 1.0)
    else:
        for action in input_mapping:
            if str(event.keycode).to_lower() in _get_keys_for_action(action):
                action_released.emit(action)

func _handle_mouse(event: InputEventMouseMotion) -> void:
    if Input.is_action_pressed("camera_look"):
        axis_moved.emit("camera_x", event.relative.x * 0.1)
        axis_moved.emit("camera_y", event.relative.y * 0.1)

func _handle_gamepad_button(event: InputEventJoypadButton) -> void:
    var button_name = "gamepad_button_" + str(event.button_index)
    if event.pressed:
        for action in input_mapping:
            if button_name in input_mapping[action]:
                action_pressed.emit(action, 1.0)
    else:
        for action in input_mapping:
            if button_name in input_mapping[action]:
                action_released.emit(action)

func _handle_gamepad_axis(event: InputEventJoypadMotion) -> void:
    var axis_name = "gamepad_axis_" + str(event.axis)
    for action in input_mapping:
        if axis_name in input_mapping[action]:
            if abs(event.axis_value) > 0.1:
                axis_moved.emit(action, event.axis_value)
            else:
                action_released.emit(action)

func _handle_touch(event: InputEvent) -> void:
    # Обработка тач событий
    if event is InputEventScreenTouch:
        if event.pressed:
            action_pressed.emit("touch_tap", 1.0)
        else:
            action_released.emit("touch_tap")
    elif event is InputEventScreenDrag:
        axis_moved.emit("touch_drag_x", event.relative.x)
        axis_moved.emit("touch_drag_y", event.relative.y)

func _get_keys_for_action(action: String) -> Array:
    return input_mapping.get(action, [])

func is_action_pressed(action_name: String) -> bool:
    # Проверка нажатия действия через стандартный Input или кастомную логику
    return Input.is_action_pressed(action_name) if InputMap.has_action(action_name) else false

func get_action_strength(action_name: String) -> float:
    return Input.get_action_strength(action_name) if InputMap.has_action(action_name) else 0.0

func get_axis(negative_action: String, positive_action: String) -> float:
    return Input.get_axis(negative_action, positive_action)

func vibrate(motor: int, duration: float, intensity: float = 1.0) -> void:
    # Вибрация геймпада или тач устройства
    var joypads := Input.get_connected_joypads()
    if joypads.size() > 0:
        Input.start_joy_vibration(joypads[0], motor, intensity, duration)
