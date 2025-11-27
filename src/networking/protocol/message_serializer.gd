# Сериализатор игровых сообщений для P2P протокола Forest Kingdoms RPG
# Этот файл содержит функции для сериализации и десериализации сообщений

extends Node

# Импорт структуры сообщений
const MessageStructure = preload("res://src/networking/protocol/message_structure.gd")

# Типы сериализации
enum SerializationType {
	JSON,      # JSON формат (человекочитаемый, гибкий)
	BINARY     # Бинарный формат (компактный, быстрый)
}

# Сериализация сообщения в байтовый массив
func serialize_message(message, serialization_type: int = SerializationType.JSON) -> PackedByteArray:
	match serialization_type:
		SerializationType.JSON:
			return serialize_json(message)
		SerializationType.BINARY:
			return serialize_binary(message)
		_:
			# По умолчанию используем JSON
			return serialize_json(message)

# Десериализация сообщения из байтового массива
func deserialize_message(data: PackedByteArray, serialization_type: int = SerializationType.JSON):
	match serialization_type:
		SerializationType.JSON:
			return deserialize_json(data)
		SerializationType.BINARY:
			return deserialize_binary(data)
		_:
			# По умолчанию используем JSON
			return deserialize_json(data)

# Сериализация в JSON формат
func serialize_json(message) -> PackedByteArray:
	var dict: Dictionary
	
	# Если это объект сообщения, преобразуем в словарь
	if message.has_method("to_dict"):
		dict = message.to_dict()
	elif typeof(message) == TYPE_DICTIONARY:
		dict = message
	else:
		# Если это другой тип объекта, создаем базовый словарь
		dict = {
			"type": "unknown",
			"data": message
		}
	
	# Преобразуем словарь в JSON строку
	var json = JSON.new()
	var json_string = json.stringify(dict)
	
	if json_string == null:
		push_error("Не удалось сериализовать сообщение в JSON")
		return PackedByteArray()
	
	# Преобразуем строку в байтовый массив
	return json_string.to_utf8_buffer()

# Десериализация из JSON формата
func deserialize_json(data: PackedByteArray):
	# Преобразуем байтовый массив в строку
	var json_string = data.get_string_from_utf8()
	
	# Парсим JSON
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Не удалось десериализовать JSON: ", json.get_error_message())
		return null
	
	# Возвращаем распаршенные данные
	return json.data

# Сериализация в бинарный формат
func serialize_binary(message) -> PackedByteArray:
	# Для демонстрации используем JSON, но в реальной реализации
	# здесь будет бинарная сериализация для лучшей производительности
	
	# TODO: Реализовать настоящую бинарную сериализацию
	# Это может включать:
	# - Упаковку чисел в бинарный формат
	# - Оптимизированное представление векторов
	# - Компрессию данных
	
	return serialize_json(message)

# Десериализация из бинарного формата
func deserialize_binary(data: PackedByteArray):
	# Для демонстрации используем JSON, но в реальной реализации
	# здесь будет бинарная десериализация
	
	# TODO: Реализовать настоящую бинарную десериализацию
	
	return deserialize_json(data)

# Определение оптимального типа сериализации для сообщения
func get_optimal_serialization_type(message_type: String) -> int:
	# Для некоторых типов сообщений используем бинарную сериализацию
	# для лучшей производительности
	match message_type:
		"movement_update", "sync_update", "world_update":
			return SerializationType.BINARY
		_:
			return SerializationType.JSON

# Сериализация с автоматическим выбором типа
func serialize_message_auto(message) -> PackedByteArray:
	var message_type: String
	
	# Определяем тип сообщения
	if message.has("type"):
		message_type = message.type if typeof(message.type) == TYPE_STRING else str(message.type)
	elif message.has_method("to_dict"):
		var dict = message.to_dict()
		if dict.has("type"):
			message_type = dict.type
	else:
		message_type = "unknown"
	
	# Выбираем оптимальный тип сериализации
	var serialization_type = get_optimal_serialization_type(message_type)
	
	# Сериализуем сообщение
	return serialize_message(message, serialization_type)

# Получение размера сериализованного сообщения
func get_serialized_size(data: PackedByteArray) -> int:
	return data.size()

# Проверка целостности сериализованных данных
func validate_serialized_data(data: PackedByteArray) -> bool:
	if data.size() == 0:
		return false
	
	# Попробуем десериализовать для проверки
	var result = deserialize_json(data)
	return result != null