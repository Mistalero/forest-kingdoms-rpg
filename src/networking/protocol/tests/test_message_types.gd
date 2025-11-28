# Unit-тесты для типов сообщений игрового протокола Forest Kingdoms RPG
# Этот файл содержит тесты для проверки корректности определения типов сообщений

extends Node

# Импорт типов сообщений
const MessageTypes = preload("res://src/networking/protocol/message_types.gd")

# Флаг для отслеживания результатов тестов
var tests_passed = 0
var tests_failed = 0

# Запуск всех тестов
func run_tests():
	print("Запуск тестов для типов сообщений...")
	
	tests_passed = 0
	tests_failed = 0
	
	# Запуск отдельных тестов
	test_basic_message_types()
	test_player_message_types()
	test_movement_message_types()
	test_game_state_message_types()
	test_world_message_types()
	test_chat_message_types()
	test_session_message_types()
	test_sync_message_types()
	test_error_message_types()
	test_validation_function()
	test_get_all_types()
	
	# Вывод результатов
	print("Тесты для типов сообщений завершены.")
	print("Пройдено: ", tests_passed)
	print("Провалено: ", tests_failed)
	
	return tests_failed == 0

# Тест базовых типов сообщений
func test_basic_message_types():
	print("Тест: Базовые типы сообщений")
	
	# Проверка наличия базовых типов
	assert_type_exists(MessageTypes.MSG_TYPE_CONNECTION, "MSG_TYPE_CONNECTION")
	assert_type_exists(MessageTypes.MSG_TYPE_DISCONNECT, "MSG_TYPE_DISCONNECT")
	assert_type_exists(MessageTypes.MSG_TYPE_PING, "MSG_TYPE_PING")
	assert_type_exists(MessageTypes.MSG_TYPE_PONG, "MSG_TYPE_PONG")
	
	# Проверка валидности базовых типов
	assert_type_valid(MessageTypes.MSG_TYPE_CONNECTION, "MSG_TYPE_CONNECTION")
	assert_type_valid(MessageTypes.MSG_TYPE_DISCONNECT, "MSG_TYPE_DISCONNECT")
	assert_type_valid(MessageTypes.MSG_TYPE_PING, "MSG_TYPE_PING")
	assert_type_valid(MessageTypes.MSG_TYPE_PONG, "MSG_TYPE_PONG")

# Тест типов сообщений о игроках
func test_player_message_types():
	print("Тест: Типы сообщений о игроках")
	
	# Проверка наличия типов сообщений о игроках
	assert_type_exists(MessageTypes.MSG_TYPE_PLAYER_JOIN, "MSG_TYPE_PLAYER_JOIN")
	assert_type_exists(MessageTypes.MSG_TYPE_PLAYER_LEAVE, "MSG_TYPE_PLAYER_LEAVE")
	assert_type_exists(MessageTypes.MSG_TYPE_PLAYER_UPDATE, "MSG_TYPE_PLAYER_UPDATE")
	assert_type_exists(MessageTypes.MSG_TYPE_PLAYER_ACTION, "MSG_TYPE_PLAYER_ACTION")
	
	# Проверка валидности типов сообщений о игроках
	assert_type_valid(MessageTypes.MSG_TYPE_PLAYER_JOIN, "MSG_TYPE_PLAYER_JOIN")
	assert_type_valid(MessageTypes.MSG_TYPE_PLAYER_LEAVE, "MSG_TYPE_PLAYER_LEAVE")
	assert_type_valid(MessageTypes.MSG_TYPE_PLAYER_UPDATE, "MSG_TYPE_PLAYER_UPDATE")
	assert_type_valid(MessageTypes.MSG_TYPE_PLAYER_ACTION, "MSG_TYPE_PLAYER_ACTION")

# Тест типов сообщений о перемещении
func test_movement_message_types():
	print("Тест: Типы сообщений о перемещении")
	
	# Проверка наличия типов сообщений о перемещении
	assert_type_exists(MessageTypes.MSG_TYPE_MOVEMENT_START, "MSG_TYPE_MOVEMENT_START")
	assert_type_exists(MessageTypes.MSG_TYPE_MOVEMENT_UPDATE, "MSG_TYPE_MOVEMENT_UPDATE")
	assert_type_exists(MessageTypes.MSG_TYPE_MOVEMENT_STOP, "MSG_TYPE_MOVEMENT_STOP")
	
	# Проверка валидности типов сообщений о перемещении
	assert_type_valid(MessageTypes.MSG_TYPE_MOVEMENT_START, "MSG_TYPE_MOVEMENT_START")
	assert_type_valid(MessageTypes.MSG_TYPE_MOVEMENT_UPDATE, "MSG_TYPE_MOVEMENT_UPDATE")
	assert_type_valid(MessageTypes.MSG_TYPE_MOVEMENT_STOP, "MSG_TYPE_MOVEMENT_STOP")

# Тест типов сообщений о состоянии игры
func test_game_state_message_types():
	print("Тест: Типы сообщений о состоянии игры")
	
	# Проверка наличия типов сообщений о состоянии игры
	assert_type_exists(MessageTypes.MSG_TYPE_GAME_STATE, "MSG_TYPE_GAME_STATE")
	assert_type_exists(MessageTypes.MSG_TYPE_GAME_EVENT, "MSG_TYPE_GAME_EVENT")
	assert_type_exists(MessageTypes.MSG_TYPE_GAME_COMMAND, "MSG_TYPE_GAME_COMMAND")
	
	# Проверка валидности типов сообщений о состоянии игры
	assert_type_valid(MessageTypes.MSG_TYPE_GAME_STATE, "MSG_TYPE_GAME_STATE")
	assert_type_valid(MessageTypes.MSG_TYPE_GAME_EVENT, "MSG_TYPE_GAME_EVENT")
	assert_type_valid(MessageTypes.MSG_TYPE_GAME_COMMAND, "MSG_TYPE_GAME_COMMAND")

# Тест типов сообщений о мире
func test_world_message_types():
	print("Тест: Типы сообщений о мире")
	
	# Проверка наличия типов сообщений о мире
	assert_type_exists(MessageTypes.MSG_TYPE_WORLD_UPDATE, "MSG_TYPE_WORLD_UPDATE")
	assert_type_exists(MessageTypes.MSG_TYPE_OBJECT_UPDATE, "MSG_TYPE_OBJECT_UPDATE")
	assert_type_exists(MessageTypes.MSG_TYPE_NPC_UPDATE, "MSG_TYPE_NPC_UPDATE")
	
	# Проверка валидности типов сообщений о мире
	assert_type_valid(MessageTypes.MSG_TYPE_WORLD_UPDATE, "MSG_TYPE_WORLD_UPDATE")
	assert_type_valid(MessageTypes.MSG_TYPE_OBJECT_UPDATE, "MSG_TYPE_OBJECT_UPDATE")
	assert_type_valid(MessageTypes.MSG_TYPE_NPC_UPDATE, "MSG_TYPE_NPC_UPDATE")

# Тест типов сообщений чата
func test_chat_message_types():
	print("Тест: Типы сообщений чата")
	
	# Проверка наличия типов сообщений чата
	assert_type_exists(MessageTypes.MSG_TYPE_CHAT_MESSAGE, "MSG_TYPE_CHAT_MESSAGE")
	assert_type_exists(MessageTypes.MSG_TYPE_CHAT_PRIVATE, "MSG_TYPE_CHAT_PRIVATE")
	assert_type_exists(MessageTypes.MSG_TYPE_CHAT_SYSTEM, "MSG_TYPE_CHAT_SYSTEM")
	
	# Проверка валидности типов сообщений чата
	assert_type_valid(MessageTypes.MSG_TYPE_CHAT_MESSAGE, "MSG_TYPE_CHAT_MESSAGE")
	assert_type_valid(MessageTypes.MSG_TYPE_CHAT_PRIVATE, "MSG_TYPE_CHAT_PRIVATE")
	assert_type_valid(MessageTypes.MSG_TYPE_CHAT_SYSTEM, "MSG_TYPE_CHAT_SYSTEM")

# Тест типов сообщений о сессии
func test_session_message_types():
	print("Тест: Типы сообщений о сессии")
	
	# Проверка наличия типов сообщений о сессии
	assert_type_exists(MessageTypes.MSG_TYPE_SESSION_CREATE, "MSG_TYPE_SESSION_CREATE")
	assert_type_exists(MessageTypes.MSG_TYPE_SESSION_JOIN, "MSG_TYPE_SESSION_JOIN")
	assert_type_exists(MessageTypes.MSG_TYPE_SESSION_LEAVE, "MSG_TYPE_SESSION_LEAVE")
	assert_type_exists(MessageTypes.MSG_TYPE_SESSION_UPDATE, "MSG_TYPE_SESSION_UPDATE")
	
	# Проверка валидности типов сообщений о сессии
	assert_type_valid(MessageTypes.MSG_TYPE_SESSION_CREATE, "MSG_TYPE_SESSION_CREATE")
	assert_type_valid(MessageTypes.MSG_TYPE_SESSION_JOIN, "MSG_TYPE_SESSION_JOIN")
	assert_type_valid(MessageTypes.MSG_TYPE_SESSION_LEAVE, "MSG_TYPE_SESSION_LEAVE")
	assert_type_valid(MessageTypes.MSG_TYPE_SESSION_UPDATE, "MSG_TYPE_SESSION_UPDATE")

# Тест типов сообщений о синхронизации
func test_sync_message_types():
	print("Тест: Типы сообщений о синхронизации")
	
	# Проверка наличия типов сообщений о синхронизации
	assert_type_exists(MessageTypes.MSG_TYPE_SYNC_REQUEST, "MSG_TYPE_SYNC_REQUEST")
	assert_type_exists(MessageTypes.MSG_TYPE_SYNC_RESPONSE, "MSG_TYPE_SYNC_RESPONSE")
	assert_type_exists(MessageTypes.MSG_TYPE_SYNC_UPDATE, "MSG_TYPE_SYNC_UPDATE")
	
	# Проверка валидности типов сообщений о синхронизации
	assert_type_valid(MessageTypes.MSG_TYPE_SYNC_REQUEST, "MSG_TYPE_SYNC_REQUEST")
	assert_type_valid(MessageTypes.MSG_TYPE_SYNC_RESPONSE, "MSG_TYPE_SYNC_RESPONSE")
	assert_type_valid(MessageTypes.MSG_TYPE_SYNC_UPDATE, "MSG_TYPE_SYNC_UPDATE")

# Тест типов сообщений об ошибках
func test_error_message_types():
	print("Тест: Типы сообщений об ошибках")
	
	# Проверка наличия типов сообщений об ошибках
	assert_type_exists(MessageTypes.MSG_TYPE_ERROR, "MSG_TYPE_ERROR")
	assert_type_exists(MessageTypes.MSG_TYPE_WARNING, "MSG_TYPE_WARNING")
	
	# Проверка валидности типов сообщений об ошибках
	assert_type_valid(MessageTypes.MSG_TYPE_ERROR, "MSG_TYPE_ERROR")
	assert_type_valid(MessageTypes.MSG_TYPE_WARNING, "MSG_TYPE_WARNING")

# Тест функции проверки валидности типа сообщения
func test_validation_function():
	print("Тест: Функция проверки валидности типа сообщения")
	
	# Проверка существующего типа
	var valid_type = MessageTypes.MSG_TYPE_PLAYER_JOIN
	assert_true(MessageTypes.is_valid_message_type(valid_type), "Проверка существующего типа")
	
	# Проверка несуществующего типа
	var invalid_type = "invalid_type"
	assert_false(MessageTypes.is_valid_message_type(invalid_type), "Проверка несуществующего типа")

# Тест функции получения всех типов сообщений
func test_get_all_types():
	print("Тест: Функция получения всех типов сообщений")
	
	var all_types = MessageTypes.get_all_message_types()
	assert_true(all_types.size() > 0, "Проверка наличия типов в списке")
	
	# Проверим, что все основные типы присутствуют в списке
	assert_true(all_types.has(MessageTypes.MSG_TYPE_CONNECTION), "Проверка наличия MSG_TYPE_CONNECTION в списке")
	assert_true(all_types.has(MessageTypes.MSG_TYPE_PLAYER_JOIN), "Проверка наличия MSG_TYPE_PLAYER_JOIN в списке")
	assert_true(all_types.has(MessageTypes.MSG_TYPE_CHAT_MESSAGE), "Проверка наличия MSG_TYPE_CHAT_MESSAGE в списке")

# Вспомогательные функции для тестирования

func assert_type_exists(type_value: String, type_name: String):
	if type_value != null and type_value != "":
		test_passed("Тип " + type_name + " существует")
	else:
		test_failed("Тип " + type_name + " не существует")

func assert_type_valid(type_value: String, type_name: String):
	if MessageTypes.is_valid_message_type(type_value):
		test_passed("Тип " + type_name + " валиден")
	else:
		test_failed("Тип " + type_name + " не валиден")

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