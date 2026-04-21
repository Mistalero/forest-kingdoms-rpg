extends Node
class_name GameCore

# Единая точка входа. Управляет жизненным циклом, детекцией среды и инициализацией подсистем.
# Работает в режимах: BIOS (Bare Metal), OS Shell, Libretro Core, Container, Standard App.

signal session_started(session_id: String)
signal session_ended()
signal environment_detected(env_type: String)

enum EnvironmentType {
	UNKNOWN,
	BARE_METAL,      # Загрузка напрямую с железа (BIOS/UEFI)
	OS_SHELL,        # Режим оболочки ОС (Desktop Replacement)
	LIBRETRO_CORE,   # Запуск внутри RetroArch/эмулятора
	CONTAINER,       # Docker/WASM/VM
	STANDARD_APP     # Обычное приложение (Windows/Linux/Mac)
}

var current_env: EnvironmentType = EnvironmentType.UNKNOWN
var is_headless: bool = false
var session_manager: Node = null
var network_node: Node = null
var visual_controller: Node = null
var data_manager: Node = null

func _ready() -> void:
	_detect_environment()
	_initialize_subsystems()
	_start_session()

func _detect_environment() -> void:
	# Определение среды запуска через проверку доступных API и флагов
	if OS.has_feature("dedicated_server") or OS.has_feature("bare_metal"):
		current_env = EnvironmentType.BARE_METAL
	elif OS.has_feature("libretro"):
		current_env = EnvironmentType.LIBRETRO_CORE
	elif OS.has_feature("container"):
		current_env = EnvironmentType.CONTAINER
	elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN and OS.get_name() == "Linux":
		# Эвристика для Shell-режима (полноэкранное приложение на Linux без оконного менеджера)
		current_env = EnvironmentType.OS_SHELL
	else:
		current_env = EnvironmentType.STANDARD_APP
	
	print("Environment detected: ", EnvironmentType.keys()[current_env])
	environment_detected.emit(EnvironmentType.keys()[current_env])

func _initialize_subsystems() -> void:
	# Инициализация подсистем в зависимости от среды
	# Визуальный контроллер (клиентская часть, не влияет на сеть)
	visual_controller = load("res://src/visual/VisualController.gd").new()
	add_child(visual_controller)
	
	# Сетевой менеджер (P2P, шарды, сессии)
	network_node = load("res://src/network/NetworkManager.gd").new()
	add_child(network_node)
	
	# Менеджер данных (локальный кэш + синхронизация)
	data_manager = load("res://src/data/DataManager.gd").new()
	add_child(data_manager)
	
	# Настройка под среду
	if current_env == EnvironmentType.LIBRETRO_CORE:
		is_headless = true # Libretro сам рендерит кадр, мы только отдаем буфер
		_setup_libretro_mode()
	elif current_env == EnvironmentType.BARE_METAL:
		_setup_bare_metal_mode()

func _setup_libretro_mode() -> void:
	# Специфичная настройка для Libretro: отключение окна, прямой вывод видеобуфера
	RenderingServer.set_default_clear_color(Color.BLACK)
	# Здесь будет код привязки к libretro_video_refresh_t

func _setup_bare_metal_mode() -> void:
	# Прямой доступ к железу, отключение лишних слоев ОС
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

func _start_session() -> void:
	# Поиск существующей сессии (шарда) или создание новой
	var session_id = network_node.find_or_create_session()
	session_started.emit(session_id)
	print("Joined/Created session: ", session_id)

func _process(_delta: float) -> void:
	# Основной цикл игры
	# Логика выполняется всегда, рендеринг зависит от визуального режима
	if not is_headless:
		visual_controller.update_render()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Корректное завершение: сохранение состояния, отключение от сети
		_shutdown_gracefully()

func _shutdown_gracefully() -> void:
	print("Shutting down node...")
	if network_node:
		network_node.disconnect_from_peers()
	if data_manager:
		data_manager.flush_cache()
	session_ended.emit()
	# После этого процесс завершается. Никаких демонов.
	get_tree().quit()
