class_name BareMetalMode
extends Node

## Bare Metal MUD Mode - минималистичный текстовый режим без GUI
## Прямая работа с консолью через stdin/stdout для максимальной производительности

# Синглтон для глобального доступа
static var instance: BareMetalMode

# Сигналы
signal command_executed(command: String, args: Array)
signal output_sent(text: String)
signal entity_rendered(entity: SKEntity)

# Компоненты системы
var console_interface: Node
var command_parser: Node
var entity_renderer: Node
var combat_renderer: Node
var inventory_renderer: Node
var network_console: Node

# Интеграция со SkeleRealms
var sk_integration: Node
var sk_core: Node
var sk_combat: Node
var sk_prosthesis: Node

# Состояние
var is_running: bool = false
var command_history: Array[String] = []
var history_index: int = -1
var registered_commands: Dictionary = {}

# Конфигурация
var config: Dictionary = {
    "console/enabled": true,
    "async_io/enabled": true,
    "network/enabled": true,
    "debug/verbose": false,
    "max_history": 100,
    "prompt": "> "
}

func _ready() -> void:
    # Сохраняем синглтон
    instance = self
    
    # Инициализация компонентов
    _initialize_components()
    
    # Интеграция со SkeleRealms
    _initialize_skelerealms()
    
    # Регистрация команд
    _register_default_commands()
    
    # Запуск режима
    start()

func _initialize_components() -> void:
    #ConsoleInterface
    console_interface = ConsoleInterface.new()
    add_child(console_interface)
    
    # CommandParser
    command_parser = CommandParser.new()
    add_child(command_parser)
    command_parser.command_parsed.connect(_on_command_parsed)
    
    # EntityRenderer
    entity_renderer = EntityRenderer.new()
    add_child(entity_renderer)
    
    # CombatRenderer
    combat_renderer = CombatRenderer.new()
    add_child(combat_renderer)
    
    # InventoryRenderer
    inventory_renderer = InventoryRenderer.new()
    add_child(inventory_renderer)
    
    # NetworkConsole
    if config.get("network/enabled", true):
        network_console = NetworkConsole.new()
        add_child(network_console)

func _initialize_skelerealms() -> void:
    # Получение ссылок на autoloadы SkeleRealms
    sk_integration = get_node_or_null("/root/SkeleRealmsIntegration")
    sk_core = get_node_or_null("/root/SkeleRealmsCore")
    sk_combat = get_node_or_null("/root/SkeleRealmsCombat")
    sk_prosthesis = get_node_or_null("/root/SkeleRealmsProsthesis")
    
    if not sk_integration:
        push_warning("[BareMetal] SkeleRealmsIntegration не найден")
    if not sk_core:
        push_warning("[BareMetal] SkeleRealmsCore не найден")
    if not sk_combat:
        push_warning("[BareMetal] SkeleRealmsCombat не найден")

func _register_default_commands() -> void:
    # Базовые команды
    register_command("help", self, "_cmd_help")
    register_command("look", self, "_cmd_look")
    register_command("status", self, "_cmd_status")
    register_command("quit", self, "_cmd_quit")
    register_command("clear", self, "_cmd_clear")
    
    # SkeleRealms команды
    register_command("entity", self, "_cmd_entity")
    register_command("component", self, "_cmd_component")
    
    # Боевые команды
    register_command("attack", self, "_cmd_attack")
    register_command("damage", self, "_cmd_damage")
    register_command("limb", self, "_cmd_limb")
    register_command("amputate", self, "_cmd_amputate")
    register_command("prosthetic", self, "_cmd_prosthetic")
    
    # Инвентарь
    register_command("inventory", self, "_cmd_inventory")
    register_command("equip", self, "_cmd_equip")
    register_command("unequip", self, "_cmd_unequip")
    
    # Сеть
    if network_console:
        register_command("network", self, "_cmd_network")
    
    # Отладка
    register_command("debug", self, "_cmd_debug")

func start() -> void:
    """Запуск Bare Metal режима"""
    is_running = true
    
    # Приветственное сообщение
    output("")
    output("Forest Kingdoms RPG - Bare Metal Mode")
    output("======================================")
    output("")
    output("Введите 'help' для списка команд.")
    output("")
    
    # Запуск цикла ввода
    _start_input_loop()

func stop() -> void:
    """Остановка режима"""
    is_running = false
    output("Bare Metal Mode остановлен.")

func output(text: String) -> void:
    """Вывод текста в консоль"""
    if console_interface:
        console_interface.print_line(text)
    output_sent.emit(text)

func register_command(name: String, target: Object, method: String) -> void:
    """Регистрация команды"""
    registered_commands[name] = {"target": target, "method": method}

func unregister_command(name: String) -> void:
    """Удаление команды"""
    registered_commands.erase(name)

func _start_input_loop() -> void:
    """Запуск цикла обработки ввода"""
    if console_interface:
        console_interface.show_prompt(config.get("prompt", "> "))

func _on_command_parsed(command: String, args: Array) -> void:
    """Обработка распарсенной команды"""
    command_history.append(command)
    if command_history.size() > config.get("max_history", 100):
        command_history.pop_front()
    history_index = -1
    
    if registered_commands.has(command):
        var cmd_data = registered_commands[command]
        cmd_data.target.call(cmd_data.method, args)
        command_executed.emit(command, args)
    else:
        output("Неизвестная команда: %s. Введите 'help' для справки." % command)
    
    # Продолжение цикла ввода
    if is_running and console_interface:
        console_interface.show_prompt(config.get("prompt", "> "))

# === ОБРАБОТЧИКИ КОМАНД ===

func _cmd_help(args: Array) -> void:
    """Показать справку"""
    output("")
    output("=== Доступные команды ===")
    output("")
    output("Базовые:")
    output("  help              - Показать эту справку")
    output("  look              - Осмотреться")
    output("  status            - Статус персонажа")
    output("  clear             - Очистить экран")
    output("  quit              - Выход")
    output("")
    output("SkeleRealms:")
    output("  entity list       - Список entity")
    output("  entity info <id>  - Информация об entity")
    output("  component list <id> - Компоненты entity")
    output("")
    output("Бой:")
    output("  attack <target>   - Атаковать")
    output("  damage <target> <amount> <type> - Нанести урон")
    output("  limb status       - Статус конечностей")
    output("  amputate <limb>   - Ампутировать")
    output("  prosthetic equip <type> - Протез")
    output("")
    output("Инвентарь:")
    output("  inventory         - Инвентарь")
    output("  equip <slot> <item> - Экипировать")
    output("  unequip <slot>    - Снять")
    output("")
    if network_console:
        output("Сеть:")
        output("  network peers   - Список пиров")
        output("  network sync    - Синхронизация")
        output("")
    output("Отладка:")
    output("  debug verbose on/off - Режим отладки")

func _cmd_look(args: Array) -> void:
    """Осмотр местности"""
    output("")
    output("Вы находитесь в неизвестной локации.")
    output("")
    
    if sk_integration:
        output("Видимые entity:")
        # Здесь должна быть логика получения видимых entity
        output("  [Нет данных]")
    else:
        output("SkeleRealms не инициализирован.")

func _cmd_status(args: Array) -> void:
    """Статус персонажа"""
    output("")
    output("=== Статус персонажа ===")
    output("")
    
    if sk_core:
        # Получить данные игрока
        output("HP: 100/100")
        output("Stamina: 50/50")
        output("Magicka: 30/30")
        output("")
        
        if sk_combat:
            output("Конечности:")
            output("  - Голова: OK")
            output("  - Торс: OK")
            output("  - Левая рука: OK")
            output("  - Правая рука: OK")
            output("  - Левая нога: OK")
            output("  - Правая нога: OK")
    else:
        output("SkeleRealmsCore не доступен.")

func _cmd_quit(args: Array) -> void:
    """Выход из игры"""
    output("")
    output("Сохранение прогресса...")
    
    # Сохранение через SkeleRealms
    var save_system = get_node_or_null("/root/SaveSystem")
    if save_system and save_system.has_method("save_game"):
        save_system.save_game()
    
    output("До свидания!")
    is_running = false
    
    # Выход из Godot
    get_tree().quit()

func _cmd_clear(args: Array) -> void:
    """Очистка экрана"""
    if console_interface:
        console_interface.clear_screen()

func _cmd_entity(args: Array) -> void:
    """Команды entity"""
    if args.is_empty():
        output("Использование: entity <list|info> [id]")
        return
    
    match args[0]:
        "list":
            _entity_list()
        "info":
            if args.size() > 1:
                _entity_info(args[1])
            else:
                output("Использование: entity info <id>")
        _:
            output("Неизвестная подкоманда: %s" % args[0])

func _entity_list() -> void:
    """Список всех entity"""
    output("")
    output("=== Entity ===")
    output("")
    
    if sk_integration:
        # Получить список entity из EntityManager
        output("  [Список entity будет здесь]")
    else:
        output("SkeleRealms не доступен.")

func _entity_info(id_str: String) -> void:
    """Информация об entity"""
    output("")
    output("=== Entity %s ===" % id_str)
    output("")
    
    if entity_renderer and sk_integration:
        # Рендер информации об entity
        output("  [Данные entity будут здесь]")
    else:
        output("Не удалось получить информацию.")

func _cmd_component(args: Array) -> void:
    """Команды компонентов"""
    if args.is_empty():
        output("Использование: component <list|add|remove> ...")
        return
    
    match args[0]:
        "list":
            if args.size() > 1:
                _component_list(args[1])
            else:
                output("Использование: component list <entity_id>")
        "add":
            output("Добавление компонента (требует реализации)")
        "remove":
            output("Удаление компонента (требует реализации)")
        _:
            output("Неизвестная подкоманда: %s" % args[0])

func _component_list(entity_id: String) -> void:
    """Список компонентов entity"""
    output("")
    output("=== Компоненты entity %s ===" % entity_id)
    output("")
    
    if sk_integration:
        output("  [Список компонентов будет здесь]")
    else:
        output("SkeleRealms не доступен.")

func _cmd_attack(args: Array) -> void:
    """Атака цели"""
    if args.is_empty():
        output("Использование: attack <target_id>")
        return
    
    var target_id = args[0]
    output("")
    output("Атака по цели %s!" % target_id)
    
    if sk_combat:
        # Логика атаки через SkeleRealmsCombat
        output("  [Боевая система обработает атаку]")
    else:
        output("SkeleRealmsCombat не доступен.")

func _cmd_damage(args: Array) -> void:
    """Нанесение урона"""
    if args.size() < 3:
        output("Использование: damage <target> <amount> <type>")
        return
    
    var target = args[0]
    var amount = int(args[1]) if args[1].is_valid_int() else 0
    var damage_type = args[2]
    
    output("")
    output("Нанесено %d урона (%s) по %s" % [amount, damage_type, target])
    
    if sk_combat:
        # Нанесение урона через SkeleRealms
        output("  [Урон обработан]")

func _cmd_limb(args: Array) -> void:
    """Команды конечностей"""
    if args.is_empty():
        output("Использование: limb <status>")
        return
    
    match args[0]:
        "status":
            _limb_status()
        _:
            output("Неизвестная подкоманда: %s" % args[0])

func _limb_status() -> void:
    """Статус конечностей"""
    output("")
    output("=== Статус конечностей ===")
    output("")
    
    if sk_combat:
        output("  - Голова: OK")
        output("  - Торс: OK")
        output("  - Левая рука: OK")
        output("  - Правая рука: OK")
        output("  - Левая нога: OK")
        output("  - Правая нога: OK")
    else:
        output("SkeleRealmsCombat не доступен.")

func _cmd_amputate(args: Array) -> void:
    """Ампутация конечности"""
    if args.is_empty():
        output("Использование: amputate <limb_name>")
        return
    
    var limb = args[0]
    output("")
    output("Ампутация конечности: %s" % limb)
    
    if sk_combat:
        output("  [Ампутация выполнена]")

func _cmd_prosthetic(args: Array) -> void:
    """Команды протезов"""
    if args.is_empty():
        output("Использование: prosthetic <equip|list> ...")
        return
    
    match args[0]:
        "equip":
            if args.size() > 1:
                _prosthetic_equip(args[1])
            else:
                output("Использование: prosthetic equip <type>")
        "list":
            _prosthetic_list()
        _:
            output("Неизвестная подкоманда: %s" % args[0])

func _prosthetic_equip(prosthetic_type: String) -> void:
    """Экипировка протеза"""
    output("")
    output("Экипировка протеза: %s" % prosthetic_type)
    
    if sk_prosthesis:
        output("  [Протез установлен]")

func _prosthetic_list() -> void:
    """Список доступных протезов"""
    output("")
    output("=== Доступные протезы ===")
    output("")
    output("  - Деревянная нога")
    output("  - Железный крюк")
    output("  - Механическая рука")
    output("  - Эльфийский протез")

func _cmd_inventory(args: Array) -> void:
    """Показать инвентарь"""
    output("")
    output("=== Инвентарь ===")
    output("")
    
    if inventory_renderer:
        output("  [Список предметов будет здесь]")
    else:
        output("Инвентарь не доступен.")

func _cmd_equip(args: Array) -> void:
    """Экипировка предмета"""
    if args.size() < 2:
        output("Использование: equip <slot> <item>")
        return
    
    var slot = args[0]
    var item = args[1]
    output("")
    output("Экипировка %s в слот %s" % [item, slot])

func _cmd_unequip(args: Array) -> void:
    """Снятие предмета"""
    if args.is_empty():
        output("Использование: unequip <slot>")
        return
    
    var slot = args[0]
    output("")
    output("Снятие предмета из слота %s" % slot)

func _cmd_network(args: Array) -> void:
    """Сетевые команды"""
    if not network_console:
        output("Сеть отключена.")
        return
    
    if args.is_empty():
        output("Использование: network <peers|sync|send> ...")
        return
    
    match args[0]:
        "peers":
            network_console.list_peers()
        "sync":
            network_console.sync_state()
        "send":
            if args.size() > 2:
                network_console.send_to_peer(args[1], args[2])
            else:
                output("Использование: network send <peer_id> <data>")
        _:
            output("Неизвестная подкоманда: %s" % args[0])

func _cmd_debug(args: Array) -> void:
    """Отладочные команды"""
    if args.is_empty():
        output("Использование: debug <verbose|log|profile> ...")
        return
    
    match args[0]:
        "verbose":
            if args.size() > 1:
                config["debug/verbose"] = (args[1] == "on")
                output("Verbose режим: %s" % ("вкл" if config["debug/verbose"] else "выкл"))
            else:
                output("Использование: debug verbose <on|off>")
        "log":
            output("Логирование включено")
        "profile":
            output("Профилирование запущено...")
        _:
            output("Неизвестная подкоманда: %s" % args[0])

# Получение экземпляра (синглтон)
static func get_instance() -> BareMetalMode:
    return instance
