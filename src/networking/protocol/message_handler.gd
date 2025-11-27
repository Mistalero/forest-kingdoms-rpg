# Обработчики игровых сообщений для P2P протокола Forest Kingdoms RPG
# Этот файл содержит обработчики для различных типов сообщений

extends Node

# Импорт типов сообщений
const MessageTypes = preload("res://src/networking/protocol/message_types.gd")
# Импорт структуры сообщений
const MessageStructure = preload("res://src/networking/protocol/message_structure.gd")
# Импорт сериализатора
const MessageSerializer = preload("res://src/networking/protocol/message_serializer.gd")

# Сигналы для уведомления о событиях
signal player_joined(player_id, player_data)
signal player_left(player_id)
signal player_moved(player_id, position, velocity)
signal chat_message_received(sender_name, message_text, channel)
signal game_state_updated(state_data)
signal error_occurred(error_code, error_message)

# Ссылки на компоненты
var node_os_adapter = null
var message_handler = null

# Инициализация обработчиков
func initialize(adapter, handler):
	node_os_adapter = adapter
	message_handler = handler
	
	# Подключение к сигналам, если они есть
	if message_handler != null:
		message_handler.connect("message_received", Callable(self, "_on_message_received"))

# Обработчик входящих сообщений
func _on_message_received(message_data: Dictionary):
	# Проверяем тип сообщения и вызываем соответствующий обработчик
	var message_type = message_data.get("type", "")
	
	match message_type:
		MessageTypes.MSG_TYPE_PLAYER_JOIN:
			_handle_player_join(message_data)
		MessageTypes.MSG_TYPE_PLAYER_LEAVE:
			_handle_player_leave(message_data)
		MessageTypes.MSG_TYPE_MOVEMENT_UPDATE:
			_handle_movement_update(message_data)
		MessageTypes.MSG_TYPE_CHAT_MESSAGE:
			_handle_chat_message(message_data)
		MessageTypes.MSG_TYPE_GAME_STATE:
			_handle_game_state_update(message_data)
		MessageTypes.MSG_TYPE_PING:
			_handle_ping(message_data)
		MessageTypes.MSG_TYPE_PONG:
			_handle_pong(message_data)
		MessageTypes.MSG_TYPE_ERROR:
			_handle_error(message_data)
		_:
			_handle_unknown_message(message_data)

# Обработчик сообщения о подключении игрока
func _handle_player_join(message_data: Dictionary):
	var data = message_data.get("data", {})
	var player_id = data.get("player_id", "")
	var player_name = data.get("player_name", "")
	var player_data = data.get("player_data", {})
	
	if player_id != "":
		# Уведомляем о подключении игрока
		emit_signal("player_joined", player_id, player_data)
		
		# Если есть адаптер NodeOS, добавляем игрока
		if node_os_adapter != null:
			node_os_adapter.add_player(player_id, player_data)
		
		print("Игрок подключен: ", player_name, " (", player_id, ")")

# Обработчик сообщения об отключении игрока
func _handle_player_leave(message_data: Dictionary):
	var data = message_data.get("data", {})
	var player_id = data.get("player_id", "")
	
	if player_id != "":
		# Уведомляем об отключении игрока
		emit_signal("player_left", player_id)
		
		# Если есть адаптер NodeOS, удаляем игрока
		if node_os_adapter != null:
			node_os_adapter.remove_player(player_id)
		
		print("Игрок отключен: ", player_id)

# Обработчик сообщения о перемещении игрока
func _handle_movement_update(message_data: Dictionary):
	var data = message_data.get("data", {})
	var player_id = data.get("player_id", "")
	
	if player_id != "":
		var position_data = data.get("position", {})
		var velocity_data = data.get("velocity", {})
		
		var position = Vector3(
			position_data.get("x", 0.0),
			position_data.get("y", 0.0),
			position_data.get("z", 0.0)
		)
		
		var velocity = Vector3(
			velocity_data.get("x", 0.0),
			velocity_data.get("y", 0.0),
			velocity_data.get("z", 0.0)
		)
		
		# Уведомляем о перемещении игрока
		emit_signal("player_moved", player_id, position, velocity)
		
		print("Игрок ", player_id, " перемещен в позицию ", position)

# Обработчик сообщения чата
func _handle_chat_message(message_data: Dictionary):
	var data = message_data.get("data", {})
	var sender_name = data.get("sender_name", "Неизвестный")
	var message_text = data.get("message_text", "")
	var channel = data.get("channel", "global")
	
	# Уведомляем о получении сообщения чата
	emit_signal("chat_message_received", sender_name, message_text, channel)
	
	print("[", channel, "] ", sender_name, ": ", message_text)

# Обработчик обновления игрового состояния
func _handle_game_state_update(message_data: Dictionary):
	var data = message_data.get("data", {})
	
	# Уведомляем об обновлении игрового состояния
	emit_signal("game_state_updated", data)
	
	print("Получено обновление игрового состояния")

# Обработчик ping сообщения
func _handle_ping(message_data: Dictionary):
	var sender_id = message_data.get("sender_id", "")
	
	# Отправляем pong ответ
	if message_handler != null and sender_id != "":
		var pong_message = MessageStructure.create_pong_message(message_data.get("id", ""), "")
		# Здесь должна быть логика отправки сообщения через message_handler
		# message_handler.send_message(sender_id, MessageTypes.MSG_TYPE_PONG, pong_message.to_dict())
	
	print("Получен ping от ", sender_id)

# Обработчик pong сообщения
func _handle_pong(message_data: Dictionary):
	var data = message_data.get("data", {})
	var ping_id = data.get("ping_id", "")
	
	print("Получен pong ответ на ping ", ping_id)

# Обработчик сообщения об ошибке
func _handle_error(message_data: Dictionary):
	var data = message_data.get("data", {})
	var error_code = data.get("error_code", -1)
	var error_message = data.get("error_message", "Неизвестная ошибка")
	
	# Уведомляем об ошибке
	emit_signal("error_occurred", error_code, error_message)
	
	print("Ошибка: ", error_message, " (код: ", error_code, ")")

# Обработчик неизвестного сообщения
func _handle_unknown_message(message_data: Dictionary):
	var message_type = message_data.get("type", "unknown")
	
	print("Получено неизвестное сообщение типа: ", message_type)
	
	# Здесь можно добавить логику обработки неизвестных сообщений
	# Например, логирование или отправку уведомления об ошибке

# Отправка сообщения через существующий message_handler
func send_message(peer_id: int, message_type: String, data: Dictionary) -> bool:
	if message_handler != null:
		message_handler.send_message(peer_id, message_type, data)
		return true
	else:
		push_error("MessageHandler не доступен")
		return false

# Создание и отправка сообщения о подключении игрока
func send_player_join_message(peer_id: int, player_id: String, player_name: String, player_data: Dictionary = {}) -> bool:
	var message = MessageStructure.PlayerJoinMessage.create(player_id, player_name, player_data)
	return send_message(peer_id, message.type, message.to_dict())

# Создание и отправка сообщения о перемещении игрока
func send_movement_update_message(peer_id: int, player_id: String, position: Vector3, velocity: Vector3 = Vector3.ZERO) -> bool:
	var message = MessageStructure.MovementUpdateMessage.create(player_id, position, velocity)
	return send_message(peer_id, message.type, message.to_dict())

# Создание и отправка сообщения чата
func send_chat_message(peer_id: int, sender_name: String, message_text: String, channel: String = "global") -> bool:
	var message = MessageStructure.ChatMessage.create(sender_name, message_text, channel)
	return send_message(peer_id, message.type, message.to_dict())