# MSDPProtocol.gd
# Реализация MUD Server Data Protocol (MSDP)

extends Node

# MSDP переменные
var msdp_variables = {}

# Инициализация MSDP
func _init():
	# Инициализация стандартных переменных
	msdp_variables["SERVER_ID"] = "Forest Kingdoms RPG"
	msdp_variables["GAME_STATE"] = "MENU"
	msdp_variables["HEALTH"] = 0
	msdp_variables["HEALTH_MAX"] = 0
	msdp_variables["MANA"] = 0
	msdp_variables["MANA_MAX"] = 0
	msdp_variables["MOVEMENT"] = 0
	msdp_variables["MOVEMENT_MAX"] = 0
	msdp_variables["LEVEL"] = 1
	msdp_variables["EXPERIENCE"] = 0
	msdp_variables["EXPERIENCE_MAX"] = 100
	msdp_variables["GOLD"] = 0
	msdp_variables["LOCATION"] = ""
	msdp_variables["AREA"] = ""
	msdp_variables["OPPONENT_HEALTH"] = 0
	msdp_variables["OPPONENT_HEALTH_MAX"] = 0
	msdp_variables["OPPONENT_LEVEL"] = 0
	msdp_variables["OPPONENT_NAME"] = ""
	msdp_variables["WORLD_TIME"] = 0
	msdp_variables["PLAYED_TIME"] = 0

# Установка значения переменной MSDP
func set_variable(name: String, value):
	msdp_variables[name] = value
	# В реальной реализации здесь будет код для отправки обновления клиенту
	send_variable_update(name, value)

# Получение значения переменной MSDP
func get_variable(name: String):
	return msdp_variables.get(name, null)

# Отправка обновления переменной клиенту
func send_variable_update(name: String, value):
	# В реальной реализации здесь будет код для отправки MSDP данных клиенту
	# Формат: IAC SB MSDP MSDP_VAR name MSDP_VAL value IAC SE
	print("MSDP UPDATE: " + name + " = " + str(value))

# Отправка всех переменных клиенту
func send_all_variables():
	# В реальной реализации здесь будет код для отправки всех MSDP данных клиенту
	for name in msdp_variables.keys():
		send_variable_update(name, msdp_variables[name])

# Обработка MSDP команды от клиента
func handle_msdp_command(command: String, data):
	match command:
		"LIST":
			# Отправка списка всех доступных переменных
			send_variable_list()
		"SEND":
			# Отправка значений указанных переменных
			if data is Array:
				for var_name in data:
					if msdp_variables.has(var_name):
						send_variable_update(var_name, msdp_variables[var_name])
		"REPORT":
			# Включение автоматической отправки обновлений переменной
			# В реальной реализации здесь будет код для настройки отчетности
			pass
		"RESET":
			# Сброс всех настроек отчетности
			# В реальной реализации здесь будет код для сброса отчетности
			pass

# Отправка списка переменных клиенту
func send_variable_list():
	var var_list = []
	for name in msdp_variables.keys():
		var_list.append(name)
	
	# В реальной реализации здесь будет код для отправки списка клиенту
	print("MSDP VARIABLES: " + str(var_list))