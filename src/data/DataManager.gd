extends Node
class_name DataManager

## Менеджер данных с поддержкой распределенного хранения
## Работает с локальным кэшем и синхронизируется с сетью

signal data_synced(session_id: String)
signal data_loaded(session_id: String)

var local_cache: Dictionary = {}
var pending_syncs: Array = []
var is_connected_to_network: bool = false

func _ready():
	print("[DataManager] Инициализация системы хранения")
	setup_storage_paths()
	load_local_cache()

func setup_storage_paths():
	"""Настройка путей к хранилищам в зависимости от режима запуска"""
	var user_path = OS.get_user_data_dir()
	if not DirAccess.dir_exists_absolute(user_path + "/game_state"):
		DirAccess.make_dir_recursive_absolute(user_path + "/game_state")

func load_local_cache():
	"""Загрузка локального кэша с диска"""
	var user_path = OS.get_user_data_dir()
	var save_file = user_path + "/game_state/cache.json"
	
	if FileAccess.file_exists(save_file):
		var file = FileAccess.open(save_file, FileAccess.READ)
		if file:
			local_cache = JSON.parse_string(file.get_as_text())
			print("[DataManager] Загружено ", local_cache.size(), " записей из кэша")

func save_local_cache():
	"""Сохранение локального кэша на диск"""
	var user_path = OS.get_user_data_dir()
	var save_file = user_path + "/game_state/cache.json"
	
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(local_cache))
		print("[DataManager] Сохранено ", local_cache.size(), " записей в кэш")

func get_data(key: String, session_id: String = "") -> Variant:
	"""Получение данных по ключу"""
	var full_key = session_id + "/" + key if session_id != "" else key
	
	if local_cache.has(full_key):
		return local_cache[full_key]
	
	# Если данных нет в кэше, запрашиваем из сети
	if is_connected_to_network:
		request_from_network(full_key)
	
	return null

func set_data(key: String, value: Variant, session_id: String = "", sync_immediately: bool = false):
	"""Установка данных с опциональной синхронизацией"""
	var full_key = session_id + "/" + key if session_id != "" else key
	local_cache[full_key] = value
	
	if sync_immediately and is_connected_to_network:
		sync_to_network(full_key, value)
	else:
		pending_syncs.append({"key": full_key, "value": value})

func sync_all_pending():
	"""Синхронизация всех отложенных изменений"""
	if not is_connected_to_network:
		return
	
	for item in pending_syncs:
		sync_to_network(item["key"], item["value"])
	
	pending_syncs.clear()
	data_synced.emit("")

func sync_to_network(key: String, value: Variant):
	"""Отправка данных в сеть"""
	# Здесь будет интеграция с NetworkManager
	print("[DataManager] Синхронизация с сетью: ", key)

func request_from_network(key: String):
	"""Запрос данных из сети"""
	print("[DataManager] Запрос из сети: ", key)

func enable_network_mode():
	is_connected_to_network = true
	print("[DataManager] Сетевой режим включен")

func disable_network_mode():
	is_connected_to_network = false
	print("[DataManager] Сетевой режим выключен")

func clear_cache():
	local_cache.clear()
	save_local_cache()
	print("[DataManager] Кэш очищен")

func get_cache_stats() -> Dictionary:
	return {
		"entries_count": local_cache.size(),
		"pending_syncs": pending_syncs.size(),
		"is_networked": is_connected_to_network
	}
