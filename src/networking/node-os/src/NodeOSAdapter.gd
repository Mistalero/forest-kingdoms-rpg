# NodeOS Adapter for Forest Kingdoms RPG
# This module integrates the NodeOS implementation with the existing networking components

extends Node

# Импорт NodeOS класса
const NodeOS = preload("res://src/networking/node-os/src/node_os.gd")

# Существующие сетевые компоненты
var p2p_framework
var connection_manager
var message_handler
var discovery_manager

# NodeOS instance
var node_os: NodeOS

# Сигналы для взаимодействия с другими компонентами
signal node_initialized(node_info)
signal node_ready()
signal game_state_updated(state)
signal player_joined(player_id, player_data)
signal player_left(player_id)
signal message_from_node(message_data)

func _init():
	# Инициализация NodeOS
	node_os = NodeOS.new()
	
	# Подключение к сигналам NodeOS (если будут добавлены)
	# node_os.connect("some_signal", Callable(self, "_on_nodeos_signal"))

func _ready():
	# Инициализация адаптера
	initialize()

# Инициализация адаптера
func initialize():
	print("Инициализация NodeOS адаптера...")
	
	# Получение ссылок на существующие компоненты
	p2p_framework = get_node("/root/P2PFramework") if has_node("/root/P2PFramework") else null
	if p2p_framework != null:
		connection_manager = p2p_framework.connection_manager
		message_handler = p2p_framework.message_handler
		discovery_manager = p2p_framework.discovery_manager
	
	# Подключение к сигналам существующих компонентов
	if connection_manager != null:
		connection_manager.connect("peer_connected", Callable(self, "_on_peer_connected"))
		connection_manager.connect("peer_disconnected", Callable(self, "_on_peer_disconnected"))
		connection_manager.connect("data_received", Callable(self, "_on_data_received"))
	
	if message_handler != null:
		# Устанавливаем connection_manager для message_handler
		message_handler.set_connection_manager(connection_manager)
	
	# Эмитируем сигнал инициализации ноды
	emit_signal("node_initialized", node_os.get_node_info())
	
	print("NodeOS адаптер инициализирован")

# Запуск адаптера
func start():
	if node_os == null:
		push_error("NodeOS не инициализирован")
		return
	
	# Запуск NodeOS (если требуется дополнительная инициализация)
	print("NodeOS адаптер запущен")
	emit_signal("node_ready")

# Остановка адаптера
func stop():
	# Остановка NodeOS (если требуется)
	print("NodeOS адаптер остановлен")

# Отправка сообщения через NodeOS
func send_message(peer_id: int, message_type: String, data: Dictionary) -> bool:
	if message_handler != null:
		message_handler.send_message(peer_id, message_type, data)
		return true
	else:
		push_error("MessageHandler не доступен")
		return false

# Получение информации о ноде
func get_node_info() -> Dictionary:
	if node_os != null:
		return node_os.get_node_info()
	return {}

# Управление процессами
func create_process(name: String, command: String) -> String:
	if node_os != null:
		return node_os.create_process(name, command)
	return ""

func terminate_process(process_id: String) -> bool:
	if node_os != null:
		return node_os.terminate_process(process_id)
	return false

# Управление файловой системой
func create_file(path: String, content: String = "") -> bool:
	if node_os != null:
		return node_os.create_file(path, content)
	return false

func read_file(path: String) -> String:
	if node_os != null:
		return node_os.read_file(path)
	return ""

# Управление сетевыми интерфейсами
func add_network_interface(interface_name: String, address: String) -> bool:
	if node_os != null:
		return node_os.add_network_interface(interface_name, address)
	return false

# Получение хеша системы
func get_system_hash() -> String:
	if node_os != null:
		return node_os.get_system_hash()
	return ""

# Игровые методы

# Добавление игрока
func add_player(player_id: String, player_data: Dictionary) -> bool:
	if node_os != null:
		var result = node_os.add_player(player_id, player_data)
		if result:
			emit_signal("player_joined", player_id, player_data)
		return result
	return false

# Удаление игрока
func remove_player(player_id: String) -> bool:
	if node_os != null:
		var result = node_os.remove_player(player_id)
		if result:
			emit_signal("player_left", player_id)
		return result
	return false

# Обновление игрового состояния
func update_game_state(state_data: Dictionary) -> bool:
	if node_os != null:
		var result = node_os.update_game_state(state_data)
		if result:
			emit_signal("game_state_updated", node_os.get_game_state())
		return result
	return false

# Получение игрового состояния
func get_game_state() -> Dictionary:
	if node_os != null:
		return node_os.get_game_state()
	return {}

# Добавление игрового события
func add_game_event(event_type: String, event_data: Dictionary) -> String:
	if node_os != null:
		return node_os.add_game_event(event_type, event_data)
	return ""

# Обработчики событий от существующих компонентов

func _on_peer_connected(peer_id: int):
	print("NodeOS адаптер: Подключен узел ", peer_id)
	# Здесь можно добавить логику обработки подключения узла
	# Например, добавить узел в список известных узлов NodeOS

func _on_peer_disconnected(peer_id: int):
	print("NodeOS адаптер: Отключен узел ", peer_id)
	# Здесь можно добавить логику обработки отключения узла
	# Например, удалить узел из списка известных узлов NodeOS

func _on_data_received(peer_id: int, data: PackedByteArray):
	print("NodeOS адаптер: Получены данные от узла ", peer_id, " размер: ", data.size())
	# Здесь можно добавить логику обработки полученных данных
	# Например, передать данные в NodeOS для обработки

# Демонстрационный метод
func demo():
	if node_os != null:
		node_os.demo()