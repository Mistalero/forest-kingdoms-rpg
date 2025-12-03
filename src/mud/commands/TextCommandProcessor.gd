# TextCommandProcessor.gd
# Класс для обработки текстовых команд в MUD режиме

extends Node

# Сигналы
signal command_processed(command, args)

# Обработка команды
func process_command(input: String):
	# Разбор команды на части
	var parts = input.split(" ")
	if parts.size() == 0:
		return
	
	var command = parts[0].to_lower()
	var args = parts.slice(1, parts.size() - 1)
	
	# Обработка команды
	match command:
		"help":
			emit_signal("command_processed", command, args)
		"look":
			emit_signal("command_processed", command, args)
		"go":
			_process_movement_command(args)
		"inventory", "i":
			emit_signal("command_processed", command, args)
		"take":
			_process_take_command(args)
		"drop":
			_process_drop_command(args)
		"quests":
			emit_signal("command_processed", command, args)
		"say":
			_process_say_command(args)
		"quit":
			emit_signal("command_processed", command, args)
		_:
			emit_signal("command_processed", command, args)

# Обработка команды перемещения
func _process_movement_command(args: Array):
	if args.size() == 0:
		# Отобразить доступные направления
		emit_signal("command_processed", "look", [])
	else:
		var direction = args[0].to_lower()
		# Здесь должна быть логика перемещения игрока
		emit_signal("command_processed", "move", [direction])

# Обработка команды взятия предмета
func _process_take_command(args: Array):
	if args.size() == 0:
		print("Что вы хотите взять?")
	else:
		var item_name = " ".join(args)
		# Здесь должна быть логика взятия предмета
		emit_signal("command_processed", "take", [item_name])

# Обработка команды бросания предмета
func _process_drop_command(args: Array):
	if args.size() == 0:
		print("Что вы хотите бросить?")
	else:
		var item_name = " ".join(args)
		# Здесь должна быть логика бросания предмета
		emit_signal("command_processed", "drop", [item_name])

# Обработка команды говорения
func _process_say_command(args: Array):
	if args.size() == 0:
		print("Что вы хотите сказать?")
	else:
		var message = " ".join(args)
		# Здесь должна быть логика отправки сообщения
		emit_signal("command_processed", "say", [message])