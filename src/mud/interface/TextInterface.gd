# TextInterface.gd
# Класс для текстового интерфейса MUD режима

extends Node

# Сигналы
signal user_input_received(input_text)

# Отображение приветственного сообщения
func display_welcome_message():
	print("+--------------------------------------------------+")
	print("|                                                  |")
	print("|            Forest Kingdoms RPG                   |")
	print("|              Текстовый режим (MUD)               |")
	print("|                                                  |")
	print("+--------------------------------------------------+")
	print("")
	print("Добро пожаловать в текстовую версию Forest Kingdoms RPG!")
	print("Введите 'help' для получения списка доступных команд.")
	print("Введите 'quit' для выхода из игры.")
	print("")

# Отображение главного меню
func display_main_menu():
	print("Главное меню:")
	print("1. Новая игра")
	print("2. Загрузить игру")
	print("3. Настройки")
	print("4. Выход")
	print("")

# Получение ввода от пользователя
func get_user_input() -> String:
	var input = ""
	# В реальной реализации здесь будет код для получения ввода от пользователя
	# Например, через Input.get_line() или другой метод
	return input

# Отображение справки
func display_help():
	print("Доступные команды:")
	print("  help - показать эту справку")
	print("  look - осмотреть текущую локацию")
	print("  go <direction> - переместиться в указанном направлении")
	print("  inventory или i - показать инвентарь")
	print("  take <item> - взять предмет")
	print("  drop <item> - бросить предмет")
	print("  quests - показать список квестов")
	print("  say <message> - сказать что-то")
	print("  quit - выйти из игры")
	print("")

# Отображение сообщения о неизвестной команде
func display_unknown_command(command: String):
	print("Неизвестная команда: " + command)
	print("Введите 'help' для получения списка доступных команд.")
	print("")

# Отображение прощального сообщения
func display_goodbye_message():
	print("Спасибо за игру в Forest Kingdoms RPG!")
	print("Ваш прогресс сохранен.")
	print("До скорой встречи!")
	print("")

# Отображение текста в интерфейсе
func display_text(text: String):
	print(text)

# Отображение ошибки
func display_error(error: String):
	print("Ошибка: " + error)