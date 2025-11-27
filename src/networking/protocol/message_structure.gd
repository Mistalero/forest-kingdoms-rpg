# Структура игровых сообщений для P2P протокола Forest Kingdoms RPG
# Этот файл определяет базовую структуру сообщений и вспомогательные функции

extends Node

# Импорт типов сообщений
const MessageTypes = preload("res://src/networking/protocol/message_types.gd")

# Базовая структура сообщения
class Message:
	var type: String          # Тип сообщения
	var id: String            # Уникальный идентификатор сообщения
	var timestamp: int       # Временная метка создания сообщения
	var sender_id: String    # Идентификатор отправителя
	var recipient_id: String # Идентификатор получателя (если применимо)
	var data: Dictionary      # Данные сообщения
	var priority: int        # Приоритет сообщения
	var ttl: int             # Время жизни сообщения
	
	func _init():
		id = generate_message_id()
		timestamp = Time.get_unix_time_from_system()
		priority = 0
		ttl = 300  # 5 минут по умолчанию
	
	# Генерация уникального идентификатора сообщения
	func generate_message_id() -> String:
		# Комбинация времени и случайного числа для уникальности
		var time_part = str(Time.get_ticks_msec() % 1000000)
		var random_part = str(randi() % 10000)
		return time_part + "-" + random_part
	
	# Проверка валидности сообщения
	func is_valid() -> bool:
		return type != null and type != "" and MessageTypes.is_valid_message_type(type)
	
	# Преобразование сообщения в словарь
	func to_dict() -> Dictionary:
		return {
			"type": type,
			"id": id,
			"timestamp": timestamp,
			"sender_id": sender_id,
			"recipient_id": recipient_id,
			"data": data,
			"priority": priority,
			"ttl": ttl
		}
	
	# Создание сообщения из словаря
	static func from_dict(dict: Dictionary):
		var msg = Message.new()
		if dict.has("type"):
			msg.type = dict["type"]
		if dict.has("id"):
			msg.id = dict["id"]
		if dict.has("timestamp"):
			msg.timestamp = dict["timestamp"]
		if dict.has("sender_id"):
			msg.sender_id = dict["sender_id"]
		if dict.has("recipient_id"):
			msg.recipient_id = dict["recipient_id"]
		if dict.has("data"):
			msg.data = dict["data"]
		if dict.has("priority"):
			msg.priority = dict["priority"]
		if dict.has("ttl"):
			msg.ttl = dict["ttl"]
		return msg

# Структура сообщения о подключении игрока
class PlayerJoinMessage:
	extends Message
	
	var player_id: String
	var player_name: String
	var player_data: Dictionary
	
	func _init():
		super._init()
		type = MessageTypes.MSG_TYPE_PLAYER_JOIN
	
	static func create(player_id: String, player_name: String, player_data: Dictionary = {}):
		var msg = PlayerJoinMessage.new()
		msg.player_id = player_id
		msg.player_name = player_name
		msg.player_data = player_data
		msg.data = {
			"player_id": player_id,
			"player_name": player_name,
			"player_data": player_data
		}
		return msg

# Структура сообщения о перемещении игрока
class MovementUpdateMessage:
	extends Message
	
	var player_id: String
	var position: Vector3
	var velocity: Vector3
	var rotation: Vector3
	
	func _init():
		super._init()
		type = MessageTypes.MSG_TYPE_MOVEMENT_UPDATE
	
	static func create(player_id: String, position: Vector3, velocity: Vector3 = Vector3.ZERO, rotation: Vector3 = Vector3.ZERO):
		var msg = MovementUpdateMessage.new()
		msg.player_id = player_id
		msg.position = position
		msg.velocity = velocity
		msg.rotation = rotation
		msg.data = {
			"player_id": player_id,
			"position": {"x": position.x, "y": position.y, "z": position.z},
			"velocity": {"x": velocity.x, "y": velocity.y, "z": velocity.z},
			"rotation": {"x": rotation.x, "y": rotation.y, "z": rotation.z}
		}
		return msg

# Структура сообщения чата
class ChatMessage:
	extends Message
	
	var sender_name: String
	var message_text: String
	var channel: String
	
	func _init():
		super._init()
		type = MessageTypes.MSG_TYPE_CHAT_MESSAGE
	
	static func create(sender_name: String, message_text: String, channel: String = "global"):
		var msg = ChatMessage.new()
		msg.sender_name = sender_name
		msg.message_text = message_text
		msg.channel = channel
		msg.data = {
			"sender_name": sender_name,
			"message_text": message_text,
			"channel": channel
		}
		return msg

# Вспомогательные функции для работы с сообщениями

# Создание сообщения об ошибке
func create_error_message(error_code: int, error_message: String, sender_id: String = ""):
	var msg = Message.new()
	msg.type = MessageTypes.MSG_TYPE_ERROR
	msg.sender_id = sender_id
	msg.data = {
		"error_code": error_code,
		"error_message": error_message
	}
	return msg

# Создание ping сообщения
func create_ping_message(sender_id: String = ""):
	var msg = Message.new()
	msg.type = MessageTypes.MSG_TYPE_PING
	msg.sender_id = sender_id
	return msg

# Создание pong сообщения
func create_pong_message(ping_id: String, sender_id: String = ""):
	var msg = Message.new()
	msg.type = MessageTypes.MSG_TYPE_PONG
	msg.sender_id = sender_id
	msg.data = {
		"ping_id": ping_id
	}
	return msg

# Проверка, истекло ли время жизни сообщения
func is_message_expired(message: Message) -> bool:
	var current_time = Time.get_unix_time_from_system()
	return (current_time - message.timestamp) > message.ttl