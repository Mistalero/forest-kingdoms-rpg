extends Node

# Менеджер управления соединениями в P2P сети

# Сигналы
signal peer_connected(peer_id)
signal peer_disconnected(peer_id)
signal connection_failed(peer_id, error_code)
signal data_received(peer_id, data)

# Состояние соединений
var active_connections = {}  # Словарь активных соединений
var pending_connections = {}  # Словарь ожидающих соединений
var is_listening = false

# Параметры соединения
var max_connections = 32
var connection_timeout = 30.0

# Сетевой интерфейс (в реальной реализации это будет ENet или другой сетевой API)
var network_interface

func _ready():
	# Инициализация сетевого интерфейса
	initialize_network_interface()

# Инициализация сетевого интерфейса
func initialize_network_interface():
	# В реальной реализации здесь будет код инициализации сетевого API
	# Например, для Godot это может быть ENetMultiplayerPeer
	print("Инициализация сетевого интерфейса...")
	
	# Для демонстрации создадим фиктивный интерфейс
	network_interface = DummyNetworkInterface.new()
	network_interface.connect("peer_connected", Callable(self, "_on_network_peer_connected"))
	network_interface.connect("peer_disconnected", Callable(self, "_on_network_peer_disconnected"))
	network_interface.connect("data_received", Callable(self, "_on_network_data_received"))

# Запуск менеджера соединений
func start():
	if is_listening:
		return
	
	# Начинаем прослушивание входящих соединений
	network_interface.start_server(0)  # 0 означает автоматический выбор порта
	is_listening = true
	
	print("ConnectionManager запущен")

# Остановка менеджера соединений
func stop():
	if not is_listening:
		return
	
	# Закрываем все активные соединения
	for peer_id in active_connections.keys():
		disconnect_peer(peer_id)
	
	# Останавливаем прослушивание
	network_interface.stop_server()
	is_listening = false
	
	print("ConnectionManager остановлен")

# Подключение к удаленному узлу
func connect_to_peer(peer_address: String, peer_port: int) -> int:
	if not is_listening:
		push_error("ConnectionManager не запущен")
		return -1
	
	if active_connections.size() >= max_connections:
		push_error("Достигнуто максимальное количество соединений")
		return -1
	
	# Создаем уникальный ID для соединения
	var connection_id = generate_connection_id()
	
	# Добавляем соединение в список ожидающих
	pending_connections[connection_id] = {
		"address": peer_address,
		"port": peer_port,
		"timestamp": Time.get_ticks_msec()
	}
	
	# Инициируем подключение через сетевой интерфейс
	network_interface.connect_to_peer(connection_id, peer_address, peer_port)
	
	print("Попытка подключения к узлу: ", peer_address, ":", peer_port)
	return connection_id

# Отключение от узла
func disconnect_peer(peer_id: int):
	if active_connections.has(peer_id):
		# Закрываем соединение через сетевой интерфейс
		network_interface.disconnect_peer(peer_id)
		
		# Удаляем из списка активных соединений
		active_connections.erase(peer_id)
		
		print("Отключен узел: ", peer_id)
		emit_signal("peer_disconnected", peer_id)
	elif pending_connections.has(peer_id):
		# Отменяем попытку подключения
		pending_connections.erase(peer_id)
		emit_signal("connection_failed", peer_id, -1)  # -1 означает отмену

# Отправка данных узлу
func send_data(peer_id: int, data: PackedByteArray) -> bool:
	if not active_connections.has(peer_id):
		push_error("Нет активного соединения с узлом: ", peer_id)
		return false
	
	# Отправляем данные через сетевой интерфейс
	return network_interface.send_data(peer_id, data)

# Получение информации о соединении
func get_connection_info(peer_id: int) -> Dictionary:
	if active_connections.has(peer_id):
		return active_connections[peer_id].duplicate()
	return {}

# Генерация уникального ID для соединения
func generate_connection_id() -> int:
	# В реальной реализации это должен быть уникальный ID
	# Для демонстрации используем случайное число
	return randi() % 1000000

# Обработчики событий от сетевого интерфейса
func _on_network_peer_connected(peer_id: int):
	# Проверяем, является ли это ожидающим соединением
	if pending_connections.has(peer_id):
		# Перемещаем из ожидающих в активные
		var connection_info = pending_connections[peer_id]
		connection_info["connected_time"] = Time.get_ticks_msec()
		active_connections[peer_id] = connection_info
		pending_connections.erase(peer_id)
		
		print("Установлено соединение с узлом: ", peer_id)
		emit_signal("peer_connected", peer_id)
	else:
		# Это входящее соединение
		var connection_info = {
			"address": "unknown",  # В реальной реализации будет реальный адрес
			"port": 0,
			"connected_time": Time.get_ticks_msec()
		}
		active_connections[peer_id] = connection_info
		
		print("Входящее соединение от узла: ", peer_id)
		emit_signal("peer_connected", peer_id)

func _on_network_peer_disconnected(peer_id: int):
	# Удаляем из активных соединений
	if active_connections.has(peer_id):
		active_connections.erase(peer_id)
		print("Узел отключен: ", peer_id)
		emit_signal("peer_disconnected", peer_id)
	
	# Удаляем из ожидающих соединений, если есть
	if pending_connections.has(peer_id):
		pending_connections.erase(peer_id)
		emit_signal("connection_failed", peer_id, -2)  # -2 означает разрыв соединения

func _on_network_data_received(peer_id: int, data: PackedByteArray):
	if active_connections.has(peer_id):
		print("Получены данные от узла: ", peer_id, " размер: ", data.size())
		emit_signal("data_received", peer_id, data)
	else:
		push_warning("Получены данные от неизвестного узла: ", peer_id)

# Фиктивный сетевой интерфейс для демонстрации
class DummyNetworkInterface:
	extends Node
	
	signal peer_connected(peer_id)
	signal peer_disconnected(peer_id)
	signal data_received(peer_id, data)
	
	func start_server(port: int):
		print("Фиктивный сервер запущен на порту: ", port)
	
	func stop_server():
		print("Фиктивный сервер остановлен")
	
	func connect_to_peer(peer_id: int, address: String, port: int):
		# Имитируем успешное подключение через небольшую задержку
		await get_tree().create_timer(0.1).timeout
		emit_signal("peer_connected", peer_id)
	
	func disconnect_peer(peer_id: int):
		# Имитируем отключение
		await get_tree().create_timer(0.05).timeout
		emit_signal("peer_disconnected", peer_id)
	
	func send_data(peer_id: int, data: PackedByteArray) -> bool:
		# Имитируем отправку данных
		print("Отправлены данные узлу: ", peer_id, " размер: ", data.size())
		return true