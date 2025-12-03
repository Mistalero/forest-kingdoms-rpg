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

# Протоколы MUDlet
var msdp_protocol: Node
var gmcp_protocol: Node

# P2P адаптер
var p2p_adapter: Node

# Состояние игры
var game_state: GameState
var player: Player

# Инициализация MUD режима
func _ready():
	# Сохраняем ссылку на синглтон
	instance = self
	
	# Инициализация компонентов
	_initialize_components()
	
	# Инициализация протоколов
	_initialize_protocols()
	
	# Инициализация P2P адаптера
	_initialize_p2p_adapter()
	
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

# Инициализация протоколов MUDlet
func _initialize_protocols():
	# Инициализация MSDP протокола
	msdp_protocol = preload("res://src/mud/interface/MSDPProtocol.gd").new()
	
	# Инициализация GMCP протокола
	gmcp_protocol = preload("res://src/mud/interface/GMCPProtocol.gd").new()
	
	# Отправка приветственной информации через GMCP
	if gmcp_protocol:
		gmcp_protocol.send_gmcp_data("Core.Hello", {
			"client": "Forest Kingdoms RPG MUD Server",
			"version": "1.0.0"
		})
		
		# Отправка поддерживаемых модулей
		gmcp_protocol.send_supported_modules()

# Инициализация P2P адаптера
func _initialize_p2p_adapter():
	# Загрузка и инициализация P2P адаптера
	p2p_adapter = preload("res://src/mud/P2PMUDAdapter.gd").new()
	
	if p2p_adapter.initialize(self):
		print("P2P MUD Adapter initialized successfully")
		
		# Отправка игрового состояния через GMCP
		p2p_adapter.send_game_state_via_gmcp()
	else:
		push_error("Failed to initialize P2P MUD Adapter")
		p2p_adapter = null

# Запуск основного цикла MUD режима
func _start_mud_loop():
	# Показать приветствие
	text_interface.display_welcome_message()
	
	# Отправка информации о сервере через MSDP
	if msdp_protocol:
		msdp_protocol.set_variable("SERVER_ID", "Forest Kingdoms RPG")
		msdp_protocol.set_variable("GAME_STATE", "MENU")
	
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
			# Отправка информации о комнате через GMCP
			if gmcp_protocol:
				gmcp_protocol.send_room_info({
					"id": 1,
					"name": "Главное меню",
					"area": "Forest Kingdoms RPG",
					"environment": "indoor",
					"players": [],
					"mobs": [],
					"items": []
				})
		"inventory", "i":
			inventory_system.display_inventory()
		"quests":
			quest_system.display_quests()
		"say":
			social_system.send_message(args)
			# Отправка сообщения через P2P
			if p2p_adapter:
				var message_data = {
					"sender": "Player",
					"text": args[0] if args.size() > 0 else "",
					"timestamp": Time.get_ticks_msec()
				}
				p2p_adapter.send_message_to_player(0, "chat", message_data)
		"quit":
			_quit_game()
		_:
			text_interface.display_unknown_command(command)

# Завершение игры
func _quit_game():
	text_interface.display_goodbye_message()
	# Отправка прощальной информации через GMCP
	if gmcp_protocol:
		gmcp_protocol.send_gmcp_data("Core.Goodbye", {
			"message": "Спасибо за игру в Forest Kingdoms RPG!"
		})
	
	# Здесь должна быть логика сохранения игры и корректного завершения
	get_tree().quit()

# Получение экземпляра MUD режима (синглтон)
static func get_instance() -> MUDMode:
	return instance