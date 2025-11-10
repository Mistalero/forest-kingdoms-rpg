extends Node

# Пример использования P2P фреймворка

# Ссылка на P2P фреймворк
var p2p_framework

func _ready():
	# Получаем экземпляр P2P фреймворка
	p2p_framework = P2PFramework.get_instance()
	
	if p2p_framework == null:
		push_error("P2P фреймворк не инициализирован")
		return
	
	# Подключаемся к сигналам фреймворка
	connect_to_framework_signals()
	
	# Инициализируем локальный узел
	initialize_local_peer()
	
	# Запускаем фреймворк
	p2p_framework.start()
	
	print("P2P пример инициализирован")

# Подключение к сигналам фреймворка
func connect_to_framework_signals():
	p2p_framework.connect("peer_connected", Callable(self, "_on_peer_connected"))
	p2p_framework.connect("peer_disconnected", Callable(self, "_on_peer_disconnected"))
	p2p_framework.connect("message_received", Callable(self, "_on_message_received"))
	p2p_framework.connect("error_occurred", Callable(self, "_on_error_occurred"))

# Инициализация локального узла
func initialize_local_peer():
	# Устанавливаем информацию о локальном узле
	var peer_name = "Player_" + str(randi() % 1000)
	p2p_framework.session_manager.set_local_peer_info(peer_name)
	
	print("Локальный узел инициализирован как: ", peer_name)

# Создание сессии
func create_game_session(session_name: String, max_players: int):
	var session_id = p2p_framework.create_session(session_name, max_players)
	if session_id != -1:
		print("Создана игровая сессия: ", session_name, " (ID: ", session_id, ")")
		return session_id
	else:
		push_error("Не удалось создать сессию")
		return -1

# Подключение к сессии
func join_game_session(session_id: int):
	p2p_framework.join_session(session_id)
	print("Попытка подключения к сессии: ", session_id)

# Отправка чат-сообщения
func send_chat_message(peer_id: int, text: String):
	var chat_data = {
		"text": text,
		"sender": p2p_framework.session_manager.get_local_peer_info().name,
		"timestamp": Time.get_ticks_msec()
	}
	
	p2p_framework.send_message(peer_id, "chat", chat_data)

# Отправка игровых данных
func send_game_data(peer_id: int, game_data: Dictionary):
	p2p_framework.send_message(peer_id, "game_data", game_data)

# Обработчики сигналов
func _on_peer_connected(peer_id: int):
	print("Новый узел подключен: ", peer_id)
	
	// Отправляем приветственное сообщение
	var welcome_data = {
		"message": "Добро пожаловать в игру!",
		"session_info": p2p_framework.session_manager.get_active_sessions()
	}
	
	p2p_framework.send_message(peer_id, "handshake", welcome_data)

func _on_peer_disconnected(peer_id: int):
	print("Узел отключен: ", peer_id)

func _on_message_received(message_data: Dictionary):
	print("Получено сообщение: ", message_data)
	
	// Обрабатываем сообщение в зависимости от типа
	match message_data.type:
		"chat":
			handle_chat_message(message_data)
		"game_data":
			handle_game_data_message(message_data)
		"handshake":
			handle_handshake_message(message_data)

func _on_error_occurred(error_code: int, error_message: String):
	printerr("Произошла ошибка: ", error_code, " - ", error_message)
	
	// Пытаемся автоматически восстановиться
	if p2p_framework.error_handler.attempt_error_recovery(error_code):
		print("Попытка автоматического восстановления выполнена")

# Обработчики конкретных типов сообщений
func handle_chat_message(message_data: Dictionary):
	var chat_data = message_data.data
	print("[ЧАТ] ", chat_data.sender, ": ", chat_data.text)

func handle_game_data_message(message_data: Dictionary):
	var game_data = message_data.data
	print("Получены игровые данные: ", game_data)
	
	// Здесь будет логика обработки игровых данных
	// Например, обновление позиции персонажа, состояние игры и т.д.

func handle_handshake_message(message_data: Dictionary):
	var handshake_data = message_data.data
	print("Получено handshake сообщение: ", handshake_data.message)
	
	// Обрабатываем информацию о сессии
	if handshake_data.has("session_info"):
		for session in handshake_data.session_info:
			print("  Сессия: ", session.name, " (", session.id, ")")

# Получение списка доступных сессий
func list_available_sessions():
	var sessions = p2p_framework.get_available_sessions()
	print("Доступные сессии:")
	
	if sessions.size() == 0:
		print("  Нет доступных сессий")
		return
	
	for session in sessions:
		print("  - ", session.name, " (ID: ", session.id, ", Игроки: ", session.player_count, "/", session.max_players, ")")

# Отправка тестового сообщения всем подключенным узлам
func send_test_message_to_all():
	// В реальной реализации здесь нужно получить список подключенных узлов
	// и отправить сообщение каждому из них
	print("Отправка тестового сообщения всем узлам")

# Закрытие всех сессий и остановка фреймворка
func cleanup():
	if p2p_framework != null:
		p2p_framework.stop()
		print("P2P фреймворк остановлен")