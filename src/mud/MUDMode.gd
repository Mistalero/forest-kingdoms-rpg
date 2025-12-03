# MUDMode.gd
# Основной класс для текстового MUD режима Forest Kingdoms RPG

extends Node

# Синглтон для доступа к MUD режиму
static var instance: MUDMode

# Компоненты MUD режима
var text_interface: TextInterface
var command_processor: TextCommandProcessor
var world_renderer: TextWorldRenderer
var combat_system: TextCombatSystem
var inventory_system: TextInventorySystem
var quest_system: TextQuestSystem
var social_system: TextSocialSystem

# Состояние игры
var game_state: GameState
var player: Player

# Инициализация MUD режима
func _ready():
	# Сохраняем ссылку на синглтон
	instance = self
	
	# Инициализация компонентов
	_initialize_components()
	
	# Запуск основного цикла MUD режима
	_start_mud_loop()

# Инициализация компонентов MUD режима
func _initialize_components():
	text_interface = TextInterface.new()
	command_processor = TextCommandProcessor.new()
	world_renderer = TextWorldRenderer.new()
	combat_system = TextCombatSystem.new()
	inventory_system = TextInventorySystem.new()
	quest_system = TextQuestSystem.new()
	social_system = TextSocialSystem.new()
	
	# Подключение сигналов
	command_processor.connect("command_processed", self, "_on_command_processed")

# Запуск основного цикла MUD режима
func _start_mud_loop():
	# Показать приветствие
	text_interface.display_welcome_message()
	
	# Показать главное меню
	text_interface.display_main_menu()
	
	# Основной цикл обработки команд
	while true:
		var command = text_interface.get_user_input()
		if command != "":
			command_processor.process_command(command)

# Обработка команды от пользователя
func _on_command_processed(command: String, args: Array):
	match command:
		"help":
			text_interface.display_help()
		"look":
			world_renderer.render_current_location()
		"inventory", "i":
			inventory_system.display_inventory()
		"quests":
			quest_system.display_quests()
		"say":
			social_system.send_message(args)
		"quit":
			_quit_game()
		_:
			text_interface.display_unknown_command(command)

# Завершение игры
func _quit_game():
	text_interface.display_goodbye_message()
	# Здесь должна быть логика сохранения игры и корректного завершения
	get_tree().quit()

# Получение экземпляра MUD режима (синглтон)
static func get_instance() -> MUDMode:
	return instance