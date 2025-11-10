extends Node

# Основной класс P2P фреймворка
# Предоставляет универсальный интерфейс для работы с P2P сетью

# Синглтон для доступа к фреймворку
static var instance: P2PFramework

# Компоненты фреймворка
var discovery_manager
var connection_manager
var message_handler
var session_manager
var error_handler

# Состояние фреймворка
var is_initialized = false
var is_running = false

# Сигналы
signal peer_connected(peer_id)
signal peer_disconnected(peer_id)
signal message_received(message_data)
signal error_occurred(error_code, error_message)

func _ready():
	# Реализация синглтона
	if instance == null:
		instance = self
		# Делаем ноду автозагружаемой
		process_mode = PROCESS_MODE_ALWAYS
	
	# Инициализация фреймворка
	initialize()

# Инициализация фреймворка
func initialize():
	if is_initialized:
		return
	
	# Инициализация компонентов
	initialize_components()
	
	is_initialized = true
	print("P2P Framework инициализирован")

# Инициализация компонентов фреймворка
func initialize_components():
	# Загрузка и инициализация компонентов
	discovery_manager = preload("res://src/networking/discovery/DiscoveryManager.gd").new()
	connection_manager = preload("res://src/networking/core/ConnectionManager.gd").new()
	message_handler = preload("res://src/networking/messaging/MessageHandler.gd").new()
	session_manager = preload("res://src/networking/session/SessionManager.gd").new()
	error_handler = preload("res://src/networking/error/ErrorHandler.gd").new()
	
	# Подключение сигналов
	connection_manager.connect("peer_connected", Callable(self, "_on_peer_connected"))
	connection_manager.connect("peer_disconnected", Callable(self, "_on_peer_disconnected"))
	message_handler.connect("message_received", Callable(self, "_on_message_received"))
	error_handler.connect("error_occurred", Callable(self, "_on_error_occurred"))

# Запуск фреймворка
func start():
	if not is_initialized:
		push_error("Фреймворк не инициализирован")
		return
	
	if is_running:
		return
	
	# Запуск компонентов
	discovery_manager.start()
	connection_manager.start()
	message_handler.start()
	session_manager.start()
	
	is_running = true
	print("P2P Framework запущен")

# Остановка фреймворка
func stop():
	if not is_running:
		return
	
	# Остановка компонентов
	discovery_manager.stop()
	connection_manager.stop()
	message_handler.stop()
	session_manager.stop()
	
	is_running = false
	print("P2P Framework остановлен")

# Отправка сообщения другому узлу
func send_message(peer_id: int, message_type: String, data: Dictionary):
	if not is_running:
		push_error("Фреймворк не запущен")
		return
	
	message_handler.send_message(peer_id, message_type, data)

# Создание новой сессии
func create_session(session_name: String, max_players: int) -> int:
	if not is_running:
		push_error("Фреймворк не запущен")
		return -1
	
	return session_manager.create_session(session_name, max_players)

# Подключение к существующей сессии
func join_session(session_id: int):
	if not is_running:
		push_error("Фреймворк не запущен")
		return
	
	session_manager.join_session(session_id)

# Получение списка доступных сессий
func get_available_sessions() -> Array:
	if not is_running:
		push_error("Фреймворк не запущен")
		return []
	
	return discovery_manager.get_available_sessions()

# Обработчики сигналов
func _on_peer_connected(peer_id: int):
	emit_signal("peer_connected", peer_id)

func _on_peer_disconnected(peer_id: int):
	emit_signal("peer_disconnected", peer_id)

func _on_message_received(message_data: Dictionary):
	emit_signal("message_received", message_data)

func _on_error_occurred(error_code: int, error_message: String):
	emit_signal("error_occurred", error_code, error_message)

# Получение экземпляра фреймворка (для синглтона)
static func get_instance() -> P2PFramework:
	return instance