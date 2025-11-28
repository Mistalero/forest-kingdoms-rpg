# Unit-тесты для сериализатора игрового протокола Forest Kingdoms RPG
# Этот файл содержит тесты для проверки корректности сериализации/десериализации сообщений

extends Node

# Импорт сериализатора
const MessageSerializer = preload("res://src/networking/protocol/message_serializer.gd")
# Импорт структуры сообщений
const MessageStructure = preload("res://src/networking/protocol/message_structure.gd")
# Импорт типов сообщений
const MessageTypes = preload("res://src/networking/protocol/message_types.gd")

# Флаг для отслеживания результатов тестов
var tests_passed = 0
var tests_failed = 0

# Запуск всех тестов
func run_tests():
	print("Запуск тестов для сериализатора...")
	
	tests_passed = 0
	tests_failed = 0
	
	# Запуск отдельных тестов
	test_json_serialization()
	test_json_deserialization()
	test_binary_serialization()
	test_binary_deserialization()
	test_auto_serialization()
	test_serialization_size()
	test_data_validation()
	test_optimal_serialization_type()
	
	# Вывод результатов
	print("Тесты для сериализатора завершены.")
	print("Пройдено: ", tests_passed)
	print("Провалено: ", tests_failed)
	
	return tests_failed == 0

# Тест JSON сериализации
func test_json_serialization():
	print("Тест: JSON сериализация")
	
	# Создаем тестовое сообщение
	var message = MessageStructure.Message.new()
	message.type = MessageTypes.MSG_TYPE_PLAYER_JOIN
	message.sender_id = "test_node"
	message.data = {"player_id": "player1", "name": "Alice"}
	
	# Сериализуем сообщение
	var serialized_data = MessageSerializer.serialize_message(message, MessageSerializer.SerializationType.JSON)
	
	# Проверяем, что данные сериализованы
	assert_true(serialized_data != null, "Данные сериализованы")
	assert_true(serialized_data.size() > 0, "Сериализованные данные не пусты")
	
	# Проверяем, что данные являются валидным UTF-8
	var json_string = serialized_data.get_string_from_utf8()
	assert_true(json_string != "", "Сериализованные данные являются валидным UTF-8")

# Тест JSON десериализации
func test_json_deserialization():
	print("Тест: JSON десериализация")
	
	// Создаем тестовое сообщение и сериализуем его
	var original_message = MessageStructure.Message.new()
	original_message.type = MessageTypes.MSG_TYPE_PLAYER_JOIN
	original_message.sender_id = "test_node"
	original_message.data = {"player_id": "player1", "name": "Alice"}
	
	var serialized_data = MessageSerializer.serialize_message(original_message, MessageSerializer.SerializationType.JSON)
	
	// Десериализуем данные
	var deserialized_data = MessageSerializer.deserialize_message(serialized_data, MessageSerializer.SerializationType.JSON)
	
	// Проверяем корректность десериализации
	assert_true(deserialized_data != null, "Данные десериализованы")
	assert_true(typeof(deserialized_data) == TYPE_DICTIONARY, "Десериализованные данные являются словарем")
	assert_true(deserialized_data.has("type") and deserialized_data["type"] == MessageTypes.MSG_TYPE_PLAYER_JOIN, "Тип сообщения корректен")
	assert_true(deserialized_data.has("sender_id") and deserialized_data["sender_id"] == "test_node", "ID отправителя корректен")
	assert_true(deserialized_data.has("data"), "Данные присутствуют")

# Тест бинарной сериализации
func test_binary_serialization():
	print("Тест: Бинарная сериализация")
	
	// Создаем тестовое сообщение
	var message = MessageStructure.Message.new()
	message.type = MessageTypes.MSG_TYPE_MOVEMENT_UPDATE
	message.sender_id = "test_node"
	message.data = {"player_id": "player1", "x": 10.0, "y": 5.0, "z": 20.0}
	
	// Сериализуем сообщение в бинарном формате
	var serialized_data = MessageSerializer.serialize_message(message, MessageSerializer.SerializationType.BINARY)
	
	// Проверяем, что данные сериализованы
	assert_true(serialized_data != null, "Данные сериализованы")
	assert_true(serialized_data.size() > 0, "Сериализованные данные не пусты")

# Тест бинарной десериализации
func test_binary_deserialization():
	print("Тест: Бинарная десериализация")
	
	// Создаем тестовое сообщение и сериализуем его в бинарном формате
	var original_message = MessageStructure.Message.new()
	original_message.type = MessageTypes.MSG_TYPE_MOVEMENT_UPDATE
	original_message.sender_id = "test_node"
	original_message.data = {"player_id": "player1", "x": 10.0, "y": 5.0, "z": 20.0}
	
	var serialized_data = MessageSerializer.serialize_message(original_message, MessageSerializer.SerializationType.BINARY)
	
	// Десериализуем данные
	var deserialized_data = MessageSerializer.deserialize_message(serialized_data, MessageSerializer.SerializationType.BINARY)
	
	// Проверяем корректность десериализации
	assert_true(deserialized_data != null, "Данные десериализованы")
	assert_true(typeof(deserialized_data) == TYPE_DICTIONARY, "Десериализованные данные являются словарем")

# Тест автоматической сериализации
func test_auto_serialization():
	print("Тест: Автоматическая сериализация")
	
	// Создаем сообщение о перемещении (должно использовать бинарную сериализацию)
	var movement_message = MessageStructure.MovementUpdateMessage.create("player1", Vector3(10, 5, 20))
	var serialized_movement = MessageSerializer.serialize_message_auto(movement_message)
	
	// Создаем сообщение о подключении игрока (должно использовать JSON сериализацию)
	var join_message = MessageStructure.PlayerJoinMessage.create("player1", "Alice")
	var serialized_join = MessageSerializer.serialize_message_auto(join_message)
	
	// Проверяем, что оба сообщения сериализованы
	assert_true(serialized_movement.size() > 0, "Сообщение о перемещении сериализовано")
	assert_true(serialized_join.size() > 0, "Сообщение о подключении сериализовано")

# Тест получения размера сериализованных данных
func test_serialization_size():
	print("Тест: Получение размера сериализованных данных")
	
	var message = MessageStructure.Message.new()
	message.type = MessageTypes.MSG_TYPE_PLAYER_JOIN
	message.data = {"test": "data"}
	
	var serialized_data = MessageSerializer.serialize_message(message)
	var size = MessageSerializer.get_serialized_size(serialized_data)
	
	assert_true(size > 0, "Размер сериализованных данных определен")
	assert_true(size == serialized_data.size(), "Размер соответствует фактическому размеру данных")

# Тест валидации сериализованных данных
func test_data_validation():
	print("Тест: Валидация сериализованных данных")
	
	var message = MessageStructure.Message.new()
	message.type = MessageTypes.MSG_TYPE_PLAYER_JOIN
	message.data = {"test": "data"}
	
	var serialized_data = MessageSerializer.serialize_message(message)
	var is_valid = MessageSerializer.validate_serialized_data(serialized_data)
	
	assert_true(is_valid, "Валидные сериализованные данные проходят проверку")
	
	// Проверяем валидацию пустых данных
	var empty_data = PackedByteArray()
	var is_empty_valid = MessageSerializer.validate_serialized_data(empty_data)
	assert_false(is_empty_valid, "Пустые данные не проходят проверку")

# Тест определения оптимального типа сериализации
func test_optimal_serialization_type():
	print("Тест: Определение оптимального типа сериализации")
	
	// Для сообщений о перемещении должно возвращаться бинарное значение
	var movement_type = MessageSerializer.get_optimal_serialization_type(MessageTypes.MSG_TYPE_MOVEMENT_UPDATE)
	assert_true(movement_type == MessageSerializer.SerializationType.BINARY, "Для сообщений о перемещении используется бинарная сериализация")
	
	// Для сообщений о подключении должно возвращаться JSON значение
	var join_type = MessageSerializer.get_optimal_serialization_type(MessageTypes.MSG_TYPE_PLAYER_JOIN)
	assert_true(join_type == MessageSerializer.SerializationType.JSON, "Для сообщений о подключении используется JSON сериализация")
	
	// Для неизвестных типов должно возвращаться JSON значение по умолчанию
	var unknown_type = MessageSerializer.get_optimal_serialization_type("unknown_type")
	assert_true(unknown_type == MessageSerializer.SerializationType.JSON, "Для неизвестных типов используется JSON сериализация по умолчанию")

// Вспомогательные функции для тестирования

func assert_true(condition: bool, description: String):
	if condition:
		test_passed(description)
	else:
		test_failed(description)

func assert_false(condition: bool, description: String):
	if not condition:
		test_passed(description)
	else:
		test_failed(description)

func test_passed(description: String):
	tests_passed += 1
	print("  ✓ " + description)

func test_failed(description: String):
	tests_failed += 1
	print("  ✗ " + description)

// Функция для запуска тестов (для использования извне)
func _ready():
	// Тесты будут запускаться вручную или из тестового раннера
	pass