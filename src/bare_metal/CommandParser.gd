class_name CommandParser
extends Node

## Парсер команд для Bare Metal режима
## Разбирает ввод пользователя на команду и аргументы

signal command_parsed(command: String, args: Array)

# Конфигурация парсера
var config: Dictionary = {
    "delimiter": " ",
    "quote_chars": ["\"", "'"],
    "escape_char": "\\",
    "case_sensitive": false,
    "strip_whitespace": true
}

# Алиасы команд
var command_aliases: Dictionary = {
    "h": "help",
    "?": "help",
    "l": "look",
    "s": "status",
    "i": "inventory",
    "q": "quit",
    "e": "equip",
    "u": "unequip"
}

func _ready() -> void:
    pass

func parse(input: String) -> Dictionary:
    """
    Парсинг строки ввода на команду и аргументы
    
    Возвращает Dictionary:
    - command: String (название команды)
    - args: Array (массив аргументов)
    - raw: String (исходная строка)
    - valid: bool (валидность команды)
    """
    var result = {
        "command": "",
        "args": [],
        "raw": input,
        "valid": false
    }
    
    if input.is_empty():
        return result
    
    # Очистка whitespace
    var cleaned = input.strip_edges() if config.get("strip_whitespace", true) else input
    
    if cleaned.is_empty():
        return result
    
    # Токенизация
    var tokens = _tokenize(cleaned)
    
    if tokens.is_empty():
        return result
    
    # Извлечение команды
    var command = tokens[0]
    
    # Применение case sensitivity
    if not config.get("case_sensitive", false):
        command = command.to_lower()
    
    # Применение алиасов
    if command_aliases.has(command):
        command = command_aliases[command]
    
    # Извлечение аргументов
    var args = []
    for i in range(1, tokens.size()):
        args.append(tokens[i])
    
    # Заполнение результата
    result["command"] = command
    result["args"] = args
    result["valid"] = true
    
    return result

func parse_and_emit(input: String) -> void:
    """Парсинг и отправка сигнала с результатом"""
    var result = parse(input)
    
    if result["valid"]:
        command_parsed.emit(result["command"], result["args"])

func _tokenize(input: String) -> Array[String]:
    """
    Токенизация строки ввода с учётом кавычек и экранирования
    
    Примеры:
    - "attack target" -> ["attack", "target"]
    - 'say "Hello World"' -> ["say", "Hello World"]
    - "damage target 50 'fire damage'" -> ["damage", "target", "50", "fire damage"]
    """
    var tokens: Array[String] = []
    var current_token: String = ""
    var in_quotes: bool = false
    var quote_char: String = ""
    var escape_next: bool = false
    var delimiter = config.get("delimiter", " ")
    var quote_chars = config.get("quote_chars", ["\"", "'"])
    var escape_char = config.get("escape_char", "\\")
    
    for i in range(input.length()):
        var char = input[i]
        
        # Обработка экранирования
        if escape_next:
            current_token += char
            escape_next = false
            continue
        
        if char == escape_char:
            escape_next = true
            continue
        
        # Обработка кавычек
        if not in_quotes and char in quote_chars:
            in_quotes = true
            quote_char = char
            continue
        
        if in_quotes and char == quote_char:
            in_quotes = false
            quote_char = ""
            continue
        
        # Обработка разделителя
        if not in_quotes and char == delimiter:
            if not current_token.is_empty():
                tokens.append(current_token)
                current_token = ""
            continue
        
        # Добавление символа к текущему токену
        current_token += char
    
    # Добавление последнего токена
    if not current_token.is_empty():
        tokens.append(current_token)
    
    return tokens

func register_alias(alias: String, command: String) -> void:
    """Регистрация нового алиаса команды"""
    command_aliases[alias] = command

func unregister_alias(alias: String) -> void:
    """Удаление алиаса"""
    command_aliases.erase(alias)

func set_config(key: String, value: Variant) -> void:
    """Установка параметра конфигурации"""
    config[key] = value

func get_config(key: String) -> Variant:
    """Получение параметра конфигурации"""
    return config.get(key)

# Утилиты для работы с командами

static func split_arguments(args_string: String, delimiter: String = " ") -> Array[String]:
    """Статический метод для разделения аргументов"""
    if args_string.is_empty():
        return []
    
    var args: Array[String] = []
    var current: String = ""
    var in_quotes = false
    var quote_char = ""
    
    for char in args_string:
        if not in_quotes and char in ["\"", "'"]:
            in_quotes = true
            quote_char = char
            continue
        
        if in_quotes and char == quote_char:
            in_quotes = false
            continue
        
        if not in_quotes and char == delimiter:
            if not current.is_empty():
                args.append(current)
                current = ""
            continue
        
        current += char
    
    if not current.is_empty():
        args.append(current)
    
    return args

static func parse_key_value(args: Array[String]) -> Dictionary:
    """
    Парсинг аргументов в формате key=value
    
    Пример: ["name=John", "level=5"] -> {"name": "John", "level": "5"}
    """
    var result: Dictionary = {}
    
    for arg in args:
        var parts = arg.split("=", true, 1)
        if parts.size() == 2:
            result[parts[0]] = parts[1]
    
    return result

static func extract_numbers(args: Array[String]) -> Array[int]:
    """Извлечение всех числовых значений из аргументов"""
    var numbers: Array[int] = []
    
    for arg in args:
        if arg.is_valid_int():
            numbers.append(int(arg))
    
    return numbers

static func extract_flags(args: Array[String]) -> Dictionary:
    """
    Извлечение флагов из аргументов
    
    Пример: ["-v", "--verbose", "-f=output.txt"] 
    -> {"v": true, "verbose": true, "f": "output.txt"}
    """
    var flags: Dictionary = {}
    
    for arg in args:
        if arg.begins_with("--"):
            # Длинный флаг
            var flag_name = arg.substr(2)
            if "=" in flag_name:
                var parts = flag_name.split("=", true, 1)
                flags[parts[0]] = parts[1]
            else:
                flags[flag_name] = true
        elif arg.begins_with("-"):
            # Короткий флаг
            var flag_name = arg.substr(1)
            if "=" in flag_name:
                var parts = flag_name.split("=", true, 1)
                flags[parts[0]] = parts[1]
            else:
                flags[flag_name] = true
    
    return flags
