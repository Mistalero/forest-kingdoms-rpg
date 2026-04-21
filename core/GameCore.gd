extends Node
class_name GameCore

# Единое ядро игры, работающее на любом уровне абстракции
# От BIOS до вложенной сессии внутри другой игры

signal state_changed(new_state: Dictionary)
signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)

var session_id: String = ""
var is_host: bool = false
var world_state: Dictionary = {}
var peers: Array = []
var current_tick: int = 0
var tick_rate: int = 60

var _timer: Timer = null

func _ready() -> void:
    _init_session()
    _start_game_loop()

func _init_session() -> void:
    session_id = _generate_session_id()
    print("[CORE] Session initialized: ", session_id)
    # В реальной реализации здесь будет поиск пиров или создание новой сессии

func _start_game_loop() -> void:
    _timer = Timer.new()
    _timer.wait_time = 1.0 / float(tick_rate)
    _timer.timeout.connect(_on_tick)
    add_child(_timer)
    _timer.start()

func _on_tick() -> void:
    current_tick += 1
    _process_input()
    _update_physics()
    _update_logic()
    _sync_state()

func _process_input() -> void:
    # Обработка ввода (будет переопределено платформой)
    pass

func _update_physics() -> void:
    # Обновление физики
    pass

func _update_logic() -> void:
    # Обновление игровой логики
    pass

func _sync_state() -> void:
    # Синхронизация состояния с пирами
    var state_snapshot = get_world_state()
    state_changed.emit(state_snapshot)

func get_world_state() -> Dictionary:
    return world_state.duplicate(true)

func apply_state_delta(delta: Dictionary) -> void:
    for key in delta:
        world_state[key] = delta[key]
    state_changed.emit(world_state)

func _generate_session_id() -> String:
    return "session_%d_%d" % [Time.get_unix_time_from_system(), randi()]

func join_session(host_address: String) -> Error:
    # Логика подключения к существующей сессии
    print("[CORE] Joining session at: ", host_address)
    return OK

func create_session() -> Error:
    is_host = true
    print("[CORE] Created new session as host")
    return OK

func leave_session() -> void:
    if _timer:
        _timer.stop()
        _timer.queue_free()
    print("[CORE] Left session")
