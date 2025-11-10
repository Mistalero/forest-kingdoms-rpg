extends Node

# Обработчик сообщений в P2P сети

# Сигналы
signal message_received(message_data)
signal message_sent(message_data)
signal message_error(error_code, error_message)

# Типы сообщений
const MSG_TYPE_HANDSHAKE = "handshake"
const MSG_TYPE_CHAT = "chat"
const MSG_TYPE_GAME_DATA = "game_data"
const MSG_TYPE_SESSION_INFO = "session_info"
const MSG_TYPE_PEER_INFO = "peer_info"
const MSG_TYPE_DISCONNECT = "disconnect"

# Состояние обработчика
var is_active = false

# Словарь обработчиков сообщений по типам
var message_handlers = {}

# Очередь исходящих сообщений
var outgoing_queue = []

# Максимальный размер очереди
var max_queue_size = 1000

# ConnectionManager для отправки данных
var connection_manager

func _ready():
	# Регистрация обработчиков сообщений
	register_message_handlers()

# Регистрация обработчиков сообщений
func register_message_handlers():
	message_handlers[MSG_TYPE_HANDSHAKE] = handle_handshake_message
	message_handlers[MSG_TYPE_CHAT] = handle_chat_message
	message_handlers[MSG_TYPE_GAME_DATA] = handle_game_data_message
	message_handlers[MSG_TYPE_SESSION_INFO] = handle_session_info_message
	message_handlers[MSG_TYPE_PEER_INFO] = handle_peer_info_message
	message_handlers[MSG_TYPE_DISCONNECT] = handle_disconnect_message

# Запуск обработчика сообщений
func start():
	if is_active:
		return
	
	is_active = true
	print("MessageHandler запущен")

# Остановка обработчика сообщений
func stop():
	if not is_active:
		return
	
	is_active = false
	# Очищаем очередь исходящих сообщений
	outgoing_queue.clear()
	print("MessageHandler остановлен")

# Отправка сообщения
func send_message(peer_id: int, message_type: String, data: Dictionary) -> bool:
	if not is_active:
		push_error("MessageHandler не активен")
		return false
	
	# Создаем сообщение
	var message = {
		"type": message_type,
		"data": data,
		"timestamp": Time.get_ticks_msec(),
		"id": generate_message_id()
	}
	
	# Сериализуем сообщение
	var serialized_message = serialize_message(message)
	if serialized_message == null:
		push_error("Не удалось сериализовать сообщение")
		return false
	
	# Отправляем через ConnectionManager
	if connection_manager != null:
		var success = connection_manager.send_data(peer_id, serialized_message)
		if success:
			emit_signal("message_sent", message)
		else:
			emit_signal("message_error", 1, "Не удалось отправить сообщение")
		return success
	else:
		push_error("ConnectionManager не установлен")
		return false

# Обработка входящего сообщения
func process_incoming_message(peer_id: int, data: PackedByteArray):
	if not is_active:
		return
	
	# Десериализуем сообщение
	var message = deserialize_message(data)
	if message == null:
		emit_signal("message_error", 2, "Не удалось десериализовать сообщение")
		return
	
	# Проверяем наличие обязательных полей
	if not message.has("type") or not message.has("data"):
		emit_signal("message_error", 3, "Некорректный формат сообщения")
		return
	
	# Добавляем информацию об отправителе
	message["sender_id"] = peer_id
	
	# Обрабатываем сообщение в зависимости от типа
	if message_handlers.has(message.type):
		var handler = message_handlers[message.type]
		handler.call(message)
	else:
		# Если нет специфического обработчика,_emit общее сообщение
		emit_signal("message_received", message)

# Обработчики конкретных типов сообщений
func handle_handshake_message(message: Dictionary):
	print("Получено handshake сообщение от узла: ", message.sender_id)
	# Здесь может быть логика проверки версии протокола, аутентификации и т.д.
	emit_signal("message_received", message)

func handle_chat_message(message: Dictionary):
	print("Получено chat сообщение: ", message.data.text)
	emit_signal("message_received", message)

func handle_game_data_message(message: Dictionary):
	print("Получены игровые данные от узла: ", message.sender_id)
	# Здесь может быть логика обработки игровых данных
	emit_signal("message_received", message)

func handle_session_info_message(message: Dictionary):
	print("Получена информация о сессии от узла: ", message.sender_id)
	emit_signal("message_received", message)

func handle_peer_info_message(message: Dictionary):
	print("Получена информация об узле от узла: ", message.sender_id)
	emit_signal("message_received", message)

func handle_disconnect_message(message: Dictionary):
	print("Получено сообщение о разрыве соединения от узла: ", message.sender_id)
	emit_signal("message_received", message)

# Сериализация сообщения
func serialize_message(message: Dictionary) -> PackedByteArray:
	# В реальной реализации здесь будет код сериализации
	# Например, с использованием JSON или бинарного формата
	var json = JSON.new()
	var json_string = json.stringify(message)
	
	if json_string == null:
		return null
	
	return json_string.to_utf8_buffer()

# Десериализация сообщения
func deserialize_message(data: PackedByteArray) -> Dictionary:
	# В реальной реализации здесь будет код десериализации
	var json_string = data.get_string_from_utf8()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		return null
	
	return json.data

# Генерация уникального ID для сообщения
func generate_message_id() -> int:
	# В реальной реализации это должен быть уникальный ID
	# Для демонстрации используем комбинацию времени и случайного числа
	return (Time.get_ticks_msec() % 1000000) * 1000 + (randi() % 1000)

# Добавление сообщения в очередь отправки
func queue_message(peer_id: int, message_type: String, data: Dictionary):
	if outgoing_queue.size() >= max_queue_size:
		push_warning("Очередь исходящих сообщений переполнена")
		return
	
	var queued_message = {
		"peer_id": peer_id,
		"type": message_type,
		"data": data,
		"timestamp": Time.get_ticks_msec()
	}
	
	outgoing_queue.append(queued_message)

# Обработка очереди отправки
func process_outgoing_queue():
	if not is_active:
		return
	
	# Обрабатываем все сообщения в очереди
	while outgoing_queue.size() > 0:
		var message = outgoing_queue.pop_front()
		send_message(message.peer_id, message.type, message.data)

# Установка ConnectionManager
func set_connection_manager(manager):
	connection_manager = manager

# Получение статистики обработчика сообщений
func get_statistics() -> Dictionary:
	return {
		"active": is_active,
		"queued_messages": outgoing_queue.size(),
		"max_queue_size": max_queue_size
	}