# MUDUtils.gd
# Вспомогательные утилиты для MUD режима

extends Node

# Форматирование текста для отображения в терминале
static func format_text(text: String, width: int = 80) -> String:
	var lines = []
	var words = text.split(" ")
	var current_line = ""
	
	for word in words:
		if current_line.length() + word.length() + 1 <= width:
			if current_line != "":
				current_line += " "
			current_line += word
		else:
			if current_line != "":
				lines.append(current_line)
			current_line = word
	
	if current_line != "":
		lines.append(current_line)
	
	return lines.join("
")

# Создание разделителя
static func create_separator(char: String = "-", length: int = 50) -> String:
	return char.repeat(length)

# Форматирование числовых значений
static func format_number(number: int) -> String:
	if number >= 1000000:
		return str(number / 1000000) + "M"
	elif number >= 1000:
		return str(number / 1000) + "K"
	else:
		return str(number)

# Преобразование секунд в формат ЧЧ:ММ:СС
static func format_time(seconds: int) -> String:
	var hours = seconds / 3600
	var minutes = (seconds % 3600) / 60
	var secs = seconds % 60
	
	return "%02d:%02d:%02d" % [hours, minutes, secs]

# Генерация случайного числа в диапазоне
static func random_range(min_val: int, max_val: int) -> int:
	return randi() % (max_val - min_val + 1) + min_val

# Проверка вероятности (в процентах)
static func check_probability(chance: int) -> bool:
	return random_range(1, 100) <= chance

# Создание цветного текста (для терминалов с поддержкой ANSI)
static func colorize_text(text: String, color: String) -> String:
	var color_codes = {
		"red": "\033[31m",
		"green": "\033[32m",
		"yellow": "\033[33m",
		"blue": "\033[34m",
		"magenta": "\033[35m",
		"cyan": "\033[36m",
		"white": "\033[37m",
		"reset": "\033[0m"
	}
	
	if color_codes.has(color):
		return color_codes[color] + text + color_codes["reset"]
	else:
		return text

# Создание текстового прогресс бара
static func create_progress_bar(current: int, max_val: int, width: int = 20) -> String:
	var filled = width * current / max_val
	var bar = "[" + "=".repeat(filled) + " ".repeat(width - filled) + "]"
	return bar + " " + str(current) + "/" + str(max_val)