class_name ConsoleInterface
extends Node

## Прямая работа с консолью через stdin/stdout
## Минималистичный интерфейс для Bare Metal режима

signal input_received(text: String)

# Буфер ввода
var input_buffer: String = ""
var is_prompt_visible: bool = false

# История команд для навигации
var history: Array[String] = []
var history_pos: int = -1

func _ready() -> void:
    # Инициализация консоли
    _setup_console()

func _setup_console() -> void:
    """Настройка консоли"""
    # Для headless режима Godot уже использует stdout
    # Дополнительная настройка не требуется
    
    # Включение raw mode для POSIX систем (опционально)
    if OS.get_name() == "Linux" or OS.get_name() == "macOS":
        # Можно использовать external commands для настройки терминала
        pass

func _input(event: InputEvent) -> void:
    """Обработка ввода с клавиатуры"""
    if event is InputEventKey and event.pressed:
        _handle_key_input(event)

func _handle_key_input(event: InputEventKey) -> void:
    """Обработка нажатий клавиш"""
    var keycode = event.keycode
    
    match keycode:
        KEY_ENTER, KEY_KP_ENTER:
            _submit_input()
        
        KEY_BACKSPACE:
            if input_buffer.length() > 0:
                input_buffer = input_buffer.substr(0, input_buffer.length() - 1)
                _update_prompt()
        
        KEY_ESCAPE:
            input_buffer = ""
            _update_prompt()
        
        KEY_UP:
            _navigate_history(-1)
        
        KEY_DOWN:
            _navigate_history(1)
        
        KEY_TAB:
            _autocomplete()
        
        _:
            # Обработка printable символов
            var unicode = event.get_unicode()
            if unicode > 32 and unicode < 127:
                input_buffer += char(unicode)
                _update_prompt()

func _submit_input() -> void:
    """Отправка введённой команды"""
    var command = input_buffer.strip_edges()
    
    if command != "":
        # Добавление в историю
        if history.is_empty() or history[-1] != command:
            history.append(command)
            if history.size() > 100:
                history.pop_front()
        history_pos = -1
        
        # Вывод команды с prompt
        print_line("> " + command)
        
        # Сигнал о получении ввода
        input_received.emit(command)
    
    # Очистка буфера
    input_buffer = ""

func _update_prompt() -> void:
    """Обновление строки подсказки"""
    if is_prompt_visible:
        # Очистка текущей строки и вывод нового prompt
        var stdout = StreamPeerStdout.new()
        stdout.put_data("\r\x1b[K".to_utf8_buffer())
        show_prompt("> " + input_buffer)

func show_prompt(prompt: String) -> void:
    """Показать prompt с текстом"""
    is_prompt_visible = true
    var stdout = StreamPeerStdout.new()
    stdout.put_data((prompt).to_utf8_buffer())

func print_line(text: String) -> void:
    """Вывод строки текста"""
    # Переход на новую строку перед выводом если нужно
    if is_prompt_visible:
        var stdout = StreamPeerStdout.new()
        stdout.put_data("\n".to_utf8_buffer())
        is_prompt_visible = false
    
    print(text)

func clear_screen() -> void:
    """Очистка экрана консоли"""
    var stdout = StreamPeerStdout.new()
    # ANSI escape code для очистки экрана
    stdout.put_data("\x1b[2J\x1b[H".to_utf8_buffer())

func _navigate_history(direction: int) -> void:
    """Навигация по истории команд"""
    if history.is_empty():
        return
    
    if direction < 0:  # Вверх
        if history_pos < history.size() - 1:
            history_pos += 1
            input_buffer = history[history.size() - 1 - history_pos]
    else:  # Вниз
        if history_pos > 0:
            history_pos -= 1
            input_buffer = history[history.size() - 1 - history_pos]
        elif history_pos == 0:
            history_pos = -1
            input_buffer = ""
    
    _update_prompt()

func _autocomplete() -> void:
    """Автодополнение команды"""
    if input_buffer.is_empty():
        return
    
    # Простое автодополнение (можно расширить)
    var commands = ["help", "look", "status", "quit", "entity", "component", 
                    "attack", "damage", "limb", "amputate", "prosthetic",
                    "inventory", "equip", "unequip", "network", "debug"]
    
    for cmd in commands:
        if cmd.begins_with(input_buffer):
            input_buffer = cmd
            _update_prompt()
            break

func set_raw_mode(enabled: bool) -> void:
    """Установка raw режима терминала"""
    if OS.get_name() == "Linux" or OS.get_name() == "macOS":
        if enabled:
            # stty raw -echo
            OS.execute("stty", ["raw", "-echo"], false)
        else:
            # stty -raw echo
            OS.execute("stty", ["-raw", "echo"], false)

func get_cursor_position() -> Vector2i:
    """Получение позиции курсора (если поддерживается)"""
    # Заглушка - в базовой реализации недоступно
    return Vector2i.ZERO

func set_cursor_position(x: int, y: int) -> void:
    """Установка позиции курсора"""
    var stdout = StreamPeerStdout.new()
    # ANSI escape code для перемещения курсора
    stdout.put_data(("\x1b[%d;%dH" % [y + 1, x + 1]).to_utf8_buffer())

func hide_cursor() -> void:
    """Скрыть курсор"""
    var stdout = StreamPeerStdout.new()
    stdout.put_data("\x1b[?25l".to_utf8_buffer())

func show_cursor() -> void:
    """Показать курсор"""
    var stdout = StreamPeerStdout.new()
    stdout.put_data("\x1b[?25h".to_utf8_buffer())

func set_color(foreground: Color, background: Color = Color.BLACK) -> void:
    """Установка цветов текста (ANSI)"""
    var stdout = StreamPeerStdout.new()
    # Упрощённая реализация - можно расширить для 256 цветов
    var fg_code = _color_to_ansi(foreground, false)
    var bg_code = _color_to_ansi(background, true)
    stdout.put_data(("\x1b[%d;%dm" % [fg_code, bg_code]).to_utf8_buffer())

func reset_colors() -> void:
    """Сброс цветов к умолчанию"""
    var stdout = StreamPeerStdout.new()
    stdout.put_data("\x1b[0m".to_utf8_buffer())

func _color_to_ansi(color: Color, is_background: bool) -> int:
    """Конвертация цвета в ANSI код"""
    # Базовая реализация для 8 основных цветов
    if color.r > 0.5 and color.g > 0.5 and color.b > 0.5:
        return 37 if not is_background else 47  # Белый
    elif color.r > 0.5 and color.g > 0.5:
        return 33 if not is_background else 43  # Жёлтый
    elif color.r > 0.5 and color.b > 0.5:
        return 35 if not is_background else 45  # Пурпурный
    elif color.g > 0.5 and color.b > 0.5:
        return 36 if not is_background else 46  # Голубой
    elif color.r > 0.5:
        return 31 if not is_background else 41  # Красный
    elif color.g > 0.5:
        return 32 if not is_background else 42  # Зелёный
    elif color.b > 0.5:
        return 34 if not is_background else 44  # Синий
    else:
        return 30 if not is_background else 40  # Чёрный
