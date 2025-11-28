# Тестовый раннер для игрового протокола Forest Kingdoms RPG
# Этот файл запускает все unit-тесты для компонентов протокола

extends Node

# Импорт тестов
const TestMessageTypes = preload("res://src/networking/protocol/tests/test_message_types.gd")
const TestMessageStructure = preload("res://src/networking/protocol/tests/test_message_structure.gd")
const TestMessageSerializer = preload("res://src/networking/protocol/tests/test_message_serializer.gd")
const TestMessageHandler = preload("res://src/networking/protocol/tests/test_message_handler.gd")

# Статистика тестов
var total_tests_passed = 0
var total_tests_failed = 0
var test_suites_count = 0

# Запуск всех тестов
func run_all_tests():
	print("========================================")
	print("Запуск всех тестов игрового протокола")
	print("========================================")
	print("")
	
	total_tests_passed = 0
	total_tests_failed = 0
	test_suites_count = 0
	
	# Запуск тестов для каждого компонента
	run_message_types_tests()
	run_message_structure_tests()
	run_message_serializer_tests()
	run_message_handler_tests()
	
	# Вывод финальных результатов
	print("")
	print("========================================")
	print("Финальные результаты тестирования")
	print("========================================")
	print("Запущено тестовых наборов: ", test_suites_count)
	print("Всего пройдено тестов: ", total_tests_passed)
	print("Всего провалено тестов: ", total_tests_failed)
	print("Общее количество тестов: ", (total_tests_passed + total_tests_failed))
	
	if total_tests_failed == 0:
		print("")
		print("🎉 Все тесты пройдены успешно!")
		return true
	else:
		print("")
		print("❌ Некоторые тесты провалены!")
		return false

# Запуск тестов для типов сообщений
func run_message_types_tests():
	print("Запуск тестов для типов сообщений...")
	test_suites_count += 1
	
	var test_instance = TestMessageTypes.new()
	var result = test_instance.run_tests()
	
	total_tests_passed += test_instance.tests_passed
	total_tests_failed += test_instance.tests_failed
	
	if result:
		print("✅ Тесты для типов сообщений пройдены")
	else:
		print("❌ Тесты для типов сообщений провалены")
	
	print("")

# Запуск тестов для структуры сообщений
func run_message_structure_tests():
	print("Запуск тестов для структуры сообщений...")
	test_suites_count += 1
	
	var test_instance = TestMessageStructure.new()
	var result = test_instance.run_tests()
	
	total_tests_passed += test_instance.tests_passed
	total_tests_failed += test_instance.tests_failed
	
	if result:
		print("✅ Тесты для структуры сообщений пройдены")
	else:
		print("❌ Тесты для структуры сообщений провалены")
	
	print("")

# Запуск тестов для сериализатора
func run_message_serializer_tests():
	print("Запуск тестов для сериализатора...")
	test_suites_count += 1
	
	var test_instance = TestMessageSerializer.new()
	var result = test_instance.run_tests()
	
	total_tests_passed += test_instance.tests_passed
	total_tests_failed += test_instance.tests_failed
	
	if result:
		print("✅ Тесты для сериализатора пройдены")
	else:
		print("❌ Тесты для сериализатора провалены")
	
	print("")

# Запуск тестов для обработчиков сообщений
func run_message_handler_tests():
	print("Запуск тестов для обработчиков сообщений...")
	test_suites_count += 1
	
	var test_instance = TestMessageHandler.new()
	var result = test_instance.run_tests()
	
	total_tests_passed += test_instance.tests_passed
	total_tests_failed += test_instance.tests_failed
	
	if result:
		print("✅ Тесты для обработчиков сообщений пройдены")
	else:
		print("❌ Тесты для обработчиков сообщений провалены")
	
	print("")

# Функция для запуска тестов
func _ready():
	# Тесты будут запускаться вручную или из внешнего скрипта
	pass

# Функция для запуска тестов из командной строки или другого скрипта
func _run_tests():
	return run_all_tests()