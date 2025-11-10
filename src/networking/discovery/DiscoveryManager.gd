extends Node

# Менеджер обнаружения узлов в P2P сети

# Сигналы
signal session_discovered(session_info)
signal discovery_error(error_message)

# Параметры обнаружения
var discovery_interval = 5.0  # Интервал обнаружения в секундах
var discovery_timeout = 30.0   # Таймаут обнаружения в секундах
var is_discovering = false

# Таймер для периодического обнаружения
var discovery_timer: Timer

# Список обнаруженных сессий
var discovered_sessions = []

# Список известных узлов
var known_peers = []

func _ready():
	# Инициализация таймера
	discovery_timer = Timer.new()
	discovery_timer.wait_time = discovery_interval
	discovery_timer.connect("timeout", Callable(self, "_on_discovery_timeout"))
	add_child(discovery_timer)

# Запуск обнаружения
func start():
	if is_discovering:
		return
	
	is_discovering = true
	discovery_timer.start()
	
	# Начальное обнаружение
	perform_discovery()
	
	print("DiscoveryManager запущен")

# Остановка обнаружения
func stop():
	if not is_discovering:
		return
	
	is_discovering = false
	discovery_timer.stop()
	
	print("DiscoveryManager остановлен")

# Выполнение обнаружения узлов
func perform_discovery():
	print("Выполнение обнаружения узлов...")
	
	# В реальной реализации здесь будет код для:
	# 1. Отправки широковещательных сообщений в локальной сети
	# 2. Использования сервисов обнаружения (например, mDNS)
	# 3. Подключения к серверу координации для получения списка узлов
	# 4. Использования DHT для поиска узлов в децентрализованной сети
	
	# Для демонстрации добавим несколько тестовых сессий
	var test_sessions = [
		{
			"id": 1001,
			"name": "Тестовая сессия 1",
			"host": "192.168.1.100",
			"port": 12345,
			"player_count": 2,
			"max_players": 4,
			"game_type": "forest_kingdoms"
		},
		{
			"id": 1002,
			"name": "Тестовая сессия 2",
			"host": "192.168.1.101",
			"port": 12346,
			"player_count": 1,
			"max_players": 6,
			"game_type": "forest_kingdoms"
		}
	]
	
	for session in test_sessions:
		if not session_exists(session.id):
			discovered_sessions.append(session)
			emit_signal("session_discovered", session)
	
	print("Обнаружено сессий: ", test_sessions.size())

# Проверка, существует ли сессия с указанным ID
func session_exists(session_id: int) -> bool:
	for session in discovered_sessions:
		if session.id == session_id:
			return true
	return false

# Обработчик таймера обнаружения
func _on_discovery_timeout():
	if is_discovering:
		perform_discovery()

# Получение списка доступных сессий
func get_available_sessions() -> Array:
	return discovered_sessions.duplicate()

# Добавление известного узла
func add_known_peer(peer_info: Dictionary):
	if not peer_exists(peer_info.id):
		known_peers.append(peer_info)
		print("Добавлен известный узел: ", peer_info.id)

# Проверка, существует ли узел с указанным ID
func peer_exists(peer_id: int) -> bool:
	for peer in known_peers:
		if peer.id == peer_id:
			return true
	return false

# Получение информации об узле по ID
func get_peer_info(peer_id: int) -> Dictionary:
	for peer in known_peers:
		if peer.id == peer_id:
			return peer.duplicate()
	return {}

# Удаление узла из списка известных
func remove_known_peer(peer_id: int):
	for i in range(known_peers.size()):
		if known_peers[i].id == peer_id:
			known_peers.remove_at(i)
			print("Удален известный узел: ", peer_id)
			break

# Очистка устаревших записей
func cleanup_stale_entries():
	var current_time = Time.get_ticks_msec()
	var stale_threshold = discovery_timeout * 1000  # Преобразуем в миллисекунды
	
	# Удаление устаревших сессий
	for i in range(discovered_sessions.size() - 1, -1, -1):
		var session = discovered_sessions[i]
		if current_time - session.last_seen > stale_threshold:
			discovered_sessions.remove_at(i)
			print("Удалена устаревшая сессия: ", session.id)
	
	# Удаление устаревших узлов
	for i in range(known_peers.size() - 1, -1, -1):
		var peer = known_peers[i]
		if current_time - peer.last_seen > stale_threshold:
			known_peers.remove_at(i)
			print("Удален устаревший узел: ", peer.id)