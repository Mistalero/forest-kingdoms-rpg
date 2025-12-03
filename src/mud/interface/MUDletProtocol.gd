# MUDletProtocol.gd
# Поддержка расширенных протоколов MUDlet

extends Node

# Поддерживаемые протоколы
enum Protocols {
	ANSI,    # ANSI цвета
	MSDP,    # MUD Server Data Protocol
	GMCP,    # Generic MUD Communication Protocol
	MCCP,    # MUD Client Compression Protocol
	MXP      # MUD eXtension Protocol
}

# Состояние поддерживаемых протоколов
var supported_protocols = {
	Protocols.ANSI: true,
	Protocols.MSDP: false,
	Protocols.GMCP: false,
	Protocols.MCCP: false,
	Protocols.MXP: false
}

# ANSI цвета
var ansi_colors = {
	"black": "\033[30m",
	"red": "\033[31m",
	"green": "\033[32m",
	"yellow": "\033[33m",
	"blue": "\033[34m",
	"magenta": "\033[35m",
	"cyan": "\033[36m",
	"white": "\033[37m",
	"bright_black": "\033[90m",
	"bright_red": "\033[91m",
	"bright_green": "\033[92m",
	"bright_yellow": "\033[93m",
	"bright_blue": "\033[94m",
	"bright_magenta": "\033[95m",
	"bright_cyan": "\033[96m",
	"bright_white": "\033[97m",
	"bg_black": "\033[40m",
	"bg_red": "\033[41m",
	"bg_green": "\033[42m",
	"bg_yellow": "\033[43m",
	"bg_blue": "\033[44m",
	"bg_magenta": "\033[45m",
	"bg_cyan": "\033[46m",
	"bg_white": "\033[47m",
	"reset": "\033[0m",
	"bold": "\033[1m",
	"underline": "\033[4m",
	"reverse": "\033[7m"
}

# Инициализация протоколов
func _init():
	pass

# Проверка поддержки протокола
func is_protocol_supported(protocol: int) -> bool:
	return supported_protocols.get(protocol, false)

# Включение поддержки протокола
func enable_protocol(protocol: int):
	supported_protocols[protocol] = true

# Отключение поддержки протокола
func disable_protocol(protocol: int):
	supported_protocols[protocol] = false

# Создание цветного текста с ANSI кодами
func colorize_text(text: String, color: String) -> String:
	if supported_protocols[Protocols.ANSI] and ansi_colors.has(color):
		return ansi_colors[color] + text + ansi_colors["reset"]
	else:
		return text

# Создание текста с множественными ANSI атрибутами
func format_text(text: String, attributes: Array) -> String:
	if !supported_protocols[Protocols.ANSI]:
		return text
	
	var codes = []
	for attr in attributes:
		if ansi_colors.has(attr):
			codes.append(ansi_colors[attr])
	
	if codes.size() > 0:
		return codes.join("") + text + ansi_colors["reset"]
	else:
		return text

# Отправка MSDP данных
func send_msdp_data(table_name: String, data):
	if !supported_protocols[Protocols.MSDP]:
		return
	
	# Формат MSDP: IAC SB MSDP <table_name> <data> IAC SE
	# В реальной реализации здесь будет код для отправки MSDP данных
	print("MSDP: " + table_name + " = " + str(data))

# Отправка GMCP данных
func send_gmcp_data(module: String, data):
	if !supported_protocols[Protocols.GMCP]:
		return
	
	# Формат GMCP: IAC SB GMCP <module> " " <data> IAC SE
	# В реальной реализации здесь будет код для отправки GMCP данных
	print("GMCP: " + module + " = " + str(data))

# Отправка MXP данных
func send_mxp_data(tag: String, attributes: Dictionary, content: String):
	if !supported_protocols[Protocols.MXP]:
		return
	
	# Формат MXP: <tag attributes>content</tag>
	# В реальной реализации здесь будет код для отправки MXP данных
	var attr_string = ""
	for key in attributes.keys():
		attr_string += " " + key + "='" + str(attributes[key]) + "'"
	
	print("<" + tag + attr_string + ">" + content + "</" + tag + ">")