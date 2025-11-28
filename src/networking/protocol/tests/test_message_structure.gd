# Unit-тесты для структуры сообщений игрового протокола Forest Kingdoms RPG
# Этот файл содержит тесты для проверки корректности структуры сообщений

extends Node

# Импорт структуры сообщений
const MessageStructure = preload("res://src/networking/protocol/message_structure.gd")
# Импорт типов сообщений
const MessageTypes = preload("res://src/networking/protocol/message_types.gd")

# Флаг для отслеживания результатов тестов
var tests_passed = 0
var tests_failed = 0

# Запуск всех тестов
func run_tests():
	print("Запуск тестов для структуры сообщений...")
	
	tests_passed = 0
	tests_failed = 0
	
	# Запуск отдельных тестов
	test_base_message_structure()
	test_player_join_message()
	test_movement_update_message()
	test_chat_message()
	test_message_conversion()
	test_message_validation()
	test_message_expired_check()
	
	# Вывод результатов
	print("Тесты для структуры сообщений завершены.")
	print("Пройдено: ", tests_passed)
	print("Провалено: ", tests_failed)
	
	return tests_failed == 0

# Тест базовой структуры сообщения
func test_base_message_structure():
	print("Тест: Базовая структура сообщения")
	
	var message = MessageStructure.Message.new()
	
	# Проверка инициализации полей
	assert_true(message.id != null and message.id != "", "ID сообщения инициализирован")
	assert_true(message.timestamp > 0, "Временная метка инициализирована")
	assert_true(message.priority == 0, "Приоритет по умолчанию равен 0")
	assert_true(message.ttl == 300, "Время жизни по умолчанию равно 300 секунд")
	
	# Проверка валидности пустого сообщения
	assert_false(message.is_valid(), "Пустое сообщение не валидно")
	
	# Установка типа и проверка валидности
	message.type = MessageTypes.MSG_TYPE_PLAYER_JOIN
	assert_true(message.is_valid(), "Сообщение с валидным типом валидно")
	
	# Проверка преобразования в словарь
	var dict = message.to_dict()
	assert_true(dict.has("type") and dict["type"] == MessageTypes.MSG_TYPE_PLAYER_JOIN, "Преобразование в словарь корректно")
	assert_true(dict.has("id") and dict["id"] == message.id, "ID в словаре корректен")
	assert_true(dict.has("timestamp") and dict["timestamp"] == message.timestamp, "Временная метка в словаре корректна")

# Тест сообщения о подключении игрока
func test_player_join_message():
	print("Тест: Сообщение о подключении игрока")
	
	var player_id = "player1"
	var player_name = "Alice"
	var player_data = {"level": 1, "class": "warrior"}
	
	var message = MessageStructure.PlayerJoinMessage.create(player_id, player_name, player_data)
	
	# Проверка типа сообщения
	assert_true(message.type == MessageTypes.MSG_TYPE_PLAYER_JOIN, "Тип сообщения PLAYER_JOIN")
	
	# Проверка полей сообщения
	assert_true(message.player_id == player_id, "ID игрока корректен")
	assert_true(message.player_name == player_name, "Имя игрока корректно")
	assert_true(message.player_data == player_data, "Данные игрока корректны")
	
	# Проверка данных в словаре
	var dict = message.to_dict()
	assert_true(dict.data.has("player_id") and dict.data["player_id"] == player_id, "ID игрока в данных корректен")
	assert_true(dict.data.has("player_name") and dict.data["player_name"] == player_name, "Имя игрока в данных корректно")

# Тест сообщения о перемещении игрока
func test_movement_update_message():
	print("Тест: Сообщение о перемещении игрока")
	
	var player_id = "player1"
	var position = Vector3(10, 5, 20)
	var velocity = Vector3(1, 0, 1)
	var rotation = Vector3(0, 90, 0)
	
	var message = MessageStructure.MovementUpdateMessage.create(player_id, position, velocity, rotation)
	
	# Проверка типа сообщения
	assert_true(message.type == MessageTypes.MSG_TYPE_MOVEMENT_UPDATE, "Тип сообщения MOVEMENT_UPDATE")
	
	# Проверка полей сообщения
	assert_true(message.player_id == player_id, "ID игрока корректен")
	assert_true(message.position == position, "Позиция корректна")
	assert_true(message.velocity == velocity, "Скорость корректна")
	assert_true(message.rotation == rotation, "Поворот корректен")
	
	# Проверка данных в словаре
	var dict = message.to_dict()
	assert_true(dict.data.has("player_id") and dict.data["player_id"] == player_id, "ID игрока в данных корректен")
	assert_true(dict.data.has("position"), "Позиция присутствует в данных")
	assert_true(dict.data.has("velocity"), "Скорость присутствует в данных")
	assert_true(dict.data.has("rotation"), "Поворот присутствует в данных")

# Тест сообщения чата
func test_chat_message():
	print("Тест: Сообщение чата")
	
	var sender_name = "Alice"
	var message_text = "Привет, мир!"
	var channel = "global"
	
	var message = MessageStructure.ChatMessage.create(sender_name, message_text, channel)
	
	# Проверка типа сообщения
	assert_true(message.type == MessageTypes.MSG_TYPE_CHAT_MESSAGE, "Тип сообщения CHAT_MESSAGE")
	
	# Проверка полей сообщения
	assert_true(message.sender_name == sender_name, "Имя отправителя корректно")
	assert_true(message.message_text == message_text, "Текст сообщения корректен")
	assert_true(message.channel == channel, "Канал корректен")
	
	# Проверка данных в словаре
	var dict = message.to_dict()
	assert_true(dict.data.has("sender_name") and dict.data["sender_name"] == sender_name, "Имя отправителя в данных корректно")
	assert_true(dict.data.has("message_text") and dict.data["message_text"] == message_text, "Текст сообщения в данных корректен")
	assert_true(dict.data.has("channel") and dict.data["channel"] == channel, "Канал в данных корректен")

# Тест преобразования сообщения в словарь и обратно
func test_message_conversion():
	print("Тест: Преобразование сообщения в словарь и обратно")
	
	var original_message = MessageStructure.Message.new()
	original_message.type = MessageTypes.MSG_TYPE_PLAYER_JOIN
	original_message.sender_id = "node1"
	original_message.data = {"test": "data"}
	
	# Преобразование в словарь
	var dict = original_message.to_dict()
	assert_true(dict != null, "Преобразование в словарь успешно")
	
	# Создание сообщения из словаря
	var restored_message = MessageStructure.Message.from_dict(dict)
	assert_true(restored_message != null, "Создание сообщения из словаря успешно")
	assert_true(restored_message.type == original_message.type, "Тип сообщения сохранен")
	assert_true(restored_message.sender_id == original_message.sender_id, "ID отправителя сохранен")
	assert_true(restored_message.data == original_message.data, "Данные сохранены")

# Тест валидации сообщения
func test_message_validation():
	print("Тест: Валидация сообщения")
	
	var valid_message = MessageStructure.Message.new()
	valid_message.type = MessageTypes.MSG_TYPE_PLAYER_JOIN
	assert_true(valid_message.is_valid(), "Валидное сообщение проходит проверку")
	
	var invalid_message = MessageStructure.Message.new()
	invalid_message.type = ""
	assert_false(invalid_message.is_valid(), "Невалидное сообщение не проходит проверку")
	
	var invalid_type_message = MessageStructure.Message.new()
	invalid_type_message.type = "invalid_type"
	assert_false(invalid_type_message.is_valid(), "Сообщение с невалидным типом не проходит проверку")

# Тест проверки истечения времени жизни сообщения
func test_message_expired_check():
	print("Тест: Проверка истечения времени жизни сообщения")
	
	var message = MessageStructure.Message.new()
	message.type = MessageTypes.MSG_TYPE_PLAYER_JOIN
	message.timestamp = Time.get_unix_time_from_system() - 3600  # Создано час назад
	message.ttl = 1800  # Время жизни 30 минут
	
	# Сообщение должно быть просрочено
	assert_true(MessageStructure.is_message_expired(message), "Просроченное сообщение определяется корректно")
	
	# Создаем новое сообщение с большим временем жизни
	var fresh_message = MessageStructure.Message.new()
	fresh_message.type = MessageTypes.MSG_TYPE_PLAYER_JOIN
	fresh_message.ttl = 3600  # Время жизни 1 час
	
	# Сообщение не должно быть просрочено
	assert_false(MessageStructure.is_message_expired(fresh_message), "Свежее сообщение не определяется как просроченное")

# Вспомогательные функции для тестирования

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

# Функция для запуска тестов (для использования извне)
func _ready():
	# Тесты будут запускаться вручную или из тестового раннера
	pass