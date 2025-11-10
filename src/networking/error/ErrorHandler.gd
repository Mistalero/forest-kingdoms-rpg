extends Node

# Обработчик ошибок в P2P фреймворке

# Сигналы
signal error_occurred(error_code, error_message)
signal error_resolved(error_code)
signal critical_error(error_code, error_message)

# Константы кодов ошибок
const ERR_NONE = 0
const ERR_CONNECTION_FAILED = 1
const ERR_CONNECTION_TIMEOUT = 2
const ERR_CONNECTION_LOST = 3
const ERR_MESSAGE_SEND_FAILED = 4
const ERR_MESSAGE_RECEIVE_FAILED = 5
const ERR_INVALID_MESSAGE = 6
const ERR_SESSION_FULL = 7
const ERR_SESSION_NOT_FOUND = 8
const ERR_PEER_NOT_FOUND = 9
const ERR_NETWORK_UNAVAILABLE = 10
const ERR_AUTHENTICATION_FAILED = 11
const ERR_VERSION_MISMATCH = 12
const ERR_DATA_CORRUPTED = 13
const ERR_RESOURCE_LIMIT = 14

# Словарь описаний ошибок
var error_descriptions = {
	ERR_CONNECTION_FAILED: "Не удалось установить соединение",
	ERR_CONNECTION_TIMEOUT: "Таймаут соединения",
	ERR_CONNECTION_LOST: "Соединение потеряно",
	ERR_MESSAGE_SEND_FAILED: "Не удалось отправить сообщение",
	ERR_MESSAGE_RECEIVE_FAILED: "Не удалось получить сообщение",
	ERR_INVALID_MESSAGE: "Получено некорректное сообщение",
	ERR_SESSION_FULL: "Сессия заполнена",
	ERR_SESSION_NOT_FOUND: "Сессия не найдена",
	ERR_PEER_NOT_FOUND: "Узел не найден",
	ERR_NETWORK_UNAVAILABLE: "Сеть недоступна",
	ERR_AUTHENTICATION_FAILED: "Ошибка аутентификации",
	ERR_VERSION_MISMATCH: "Несовместимая версия протокола",
	ERR_DATA_CORRUPTED: "Повреждены данные",
	ERR_RESOURCE_LIMIT: "Превышен лимит ресурсов"
}

# Статистика ошибок
var error_statistics = {}

# Лог ошибок
var error_log = []

# Максимальный размер лога
var max_log_size = 100

# Порог критической ошибки
var critical_error_threshold = 5

func _ready():
	# Инициализация статистики ошибок
	for error_code in error_descriptions.keys():
		error_statistics[error_code] = 0

# Регистрация ошибки
func register_error(error_code: int, additional_info: String = ""):
	# Проверяем, существует ли такой код ошибки
	if not error_descriptions.has(error_code):
		push_warning("Неизвестный код ошибки: ", error_code)
		return
	
	// Увеличиваем счетчик ошибок
	error_statistics[error_code] += 1
	
	// Создаем запись в логе
	var error_entry = {
		"timestamp": Time.get_ticks_msec(),
		"code": error_code,
		"message": error_descriptions[error_code],
		"info": additional_info
	}
	
	// Добавляем в лог
	error_log.append(error_entry)
	
	// Ограничиваем размер лога
	if error_log.size() > max_log_size:
		error_log.pop_front()
	
	// Выводим сообщение об ошибке
	var full_message = error_descriptions[error_code]
	if additional_info != "":
		full_message += " (" + additional_info + ")"
	
	printerr("P2P Ошибка [", error_code, "]: ", full_message)
	
	// Отправляем сигнал об ошибке
	emit_signal("error_occurred", error_code, full_message)
	
	// Проверяем, не является ли ошибка критической
	if error_statistics[error_code] >= critical_error_threshold:
		emit_signal("critical_error", error_code, full_message)

// Решение ошибки (например, после успешной повторной попытки)
func resolve_error(error_code: int):
	if error_statistics.has(error_code) and error_statistics[error_code] > 0:
		error_statistics[error_code] -= 1
		emit_signal("error_resolved", error_code)
		print("Ошибка решена: ", error_descriptions[error_code])

// Получение описания ошибки по коду
func get_error_description(error_code: int) -> String:
	if error_descriptions.has(error_code):
		return error_descriptions[error_code]
	return "Неизвестная ошибка"

// Получение статистики ошибок
func get_error_statistics() -> Dictionary:
	return error_statistics.duplicate()

// Получение лога ошибок
func get_error_log() -> Array:
	return error_log.duplicate()

// Очистка статистики ошибок
func clear_error_statistics():
	for error_code in error_statistics.keys():
		error_statistics[error_code] = 0

// Очистка лога ошибок
func clear_error_log():
	error_log.clear()

// Установка порога критической ошибки
func set_critical_error_threshold(threshold: int):
	critical_error_threshold = threshold

// Получение порога критической ошибки
func get_critical_error_threshold() -> int:
	return critical_error_threshold

// Проверка наличия критических ошибок
func has_critical_errors() -> bool:
	for error_code in error_statistics.keys():
		if error_statistics[error_code] >= critical_error_threshold:
			return true
	return false

// Получение списка критических ошибок
func get_critical_errors() -> Array:
	var critical_errors = []
	for error_code in error_statistics.keys():
		if error_statistics[error_code] >= critical_error_threshold:
			critical_errors.append({
				"code": error_code,
				"count": error_statistics[error_code],
				"description": error_descriptions[error_code]
			})
	return critical_errors

// Обработка сетевых ошибок
func handle_network_error(error_type: int, peer_id: int = -1, additional_info: String = ""):
	var error_message = ""
	match error_type:
		ERR_CONNECTION_FAILED:
			error_message = "Ошибка подключения к узлу " + str(peer_id)
		ERR_CONNECTION_TIMEOUT:
			error_message = "Таймаут подключения к узлу " + str(peer_id)
		ERR_CONNECTION_LOST:
			error_message = "Потеряно соединение с узлом " + str(peer_id)
		ERR_NETWORK_UNAVAILABLE:
			error_message = "Сеть недоступна"
	
	if error_message != "":
		register_error(error_type, error_message + " " + additional_info)

// Обработка ошибок сообщений
func handle_message_error(error_type: int, peer_id: int = -1, message_info: String = ""):
	var error_message = ""
	match error_type:
		ERR_MESSAGE_SEND_FAILED:
			error_message = "Не удалось отправить сообщение узлу " + str(peer_id)
		ERR_MESSAGE_RECEIVE_FAILED:
			error_message = "Не удалось получить сообщение от узла " + str(peer_id)
		ERR_INVALID_MESSAGE:
			error_message = "Получено некорректное сообщение от узла " + str(peer_id)
		ERR_DATA_CORRUPTED:
			error_message = "Повреждены данные сообщения от узла " + str(peer_id)
	
	if error_message != "":
		register_error(error_type, error_message + " " + message_info)

// Обработка ошибок сессий
func handle_session_error(error_type: int, session_id: int = -1, additional_info: String = ""):
	var error_message = ""
	match error_type:
		ERR_SESSION_FULL:
			error_message = "Сессия " + str(session_id) + " заполнена"
		ERR_SESSION_NOT_FOUND:
			error_message = "Сессия " + str(session_id) + " не найдена"
	
	if error_message != "":
		register_error(error_type, error_message + " " + additional_info)

// Автоматическое восстановление после ошибок
func attempt_error_recovery(error_code: int) -> bool:
	// В реальной реализации здесь будет логика автоматического восстановления
	// Например, повторная попытка подключения, пересылка сообщений и т.д.
	
	match error_code:
		ERR_CONNECTION_LOST:
			// Попытка повторного подключения
			print("Попытка восстановления соединения...")
			return true
		ERR_MESSAGE_SEND_FAILED:
			// Попытка повторной отправки сообщения
			print("Попытка повторной отправки сообщения...")
			return true
	
	return false

// Логирование ошибки в файл (в реальной реализации)
func log_error_to_file(error_entry: Dictionary):
	// В реальной реализации здесь будет код сохранения ошибки в файл
	// Для демонстрации просто выводим в консоль
	print("Логирование ошибки в файл: ", error_entry)