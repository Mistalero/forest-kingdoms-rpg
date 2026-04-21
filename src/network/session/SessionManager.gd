extends Node
class_name SessionManager

## Менеджер рекурсивных сессий-шардов
## Управляет вложенными мирами и их жизненным циклом

signal session_created(session_id: String)
signal session_destroyed(session_id: String)
signal player_joined_session(session_id: String, player_id: int)
signal player_left_session(session_id: String, player_id: int)

const MAX_NESTING_LEVEL = 10 # Максимальная глубина вложенности

var _active_sessions: Dictionary = {} # session_id -> ShardSession
var _player_sessions: Dictionary = {} # player_id -> session_id
var _session_counter: int = 0

func _ready():
	print("[Session] Manager initialized")

func create_session(parent_session_id: String = "", config: Dictionary = {}) -> String:
	"""Создание новой сессии (возможно вложенной)"""
	_session_counter += 1
	var session_id = "session_%d" % _session_counter
	
	# Проверка уровня вложенности
	if not parent_session_id.is_empty():
		var parent_level = _get_nesting_level(parent_session_id)
		if parent_level >= MAX_NESTING_LEVEL:
			push_error("[Session] Maximum nesting level reached")
			return ""
	
	var session = ShardSession.new()
	session.session_id = session_id
	session.parent_session_id = parent_session_id
	session.config = config
	
	_active_sessions[session_id] = session
	emit_signal("session_created", session_id)
	
	print("[Session] Created '%s' (parent: %s)" % [session_id, parent_session_id if not parent_session_id.is_empty() else "none"])
	return session_id

func join_session(session_id: String, player_id: int) -> bool:
	"""Присоединение игрока к сессии"""
	if not _active_sessions.has(session_id):
		push_error("[Session] Session '%s' not found" % session_id)
		return false
	
	var session: ShardSession = _active_sessions[session_id]
	session.add_player(player_id)
	
	_player_sessions[player_id] = session_id
	emit_signal("player_joined_session", session_id, player_id)
	
	print("[Session] Player %d joined '%s'" % [player_id, session_id])
	return true

func leave_session(player_id: int) -> bool:
	"""Выход игрока из сессии"""
	if not _player_sessions.has(player_id):
		return false
	
	var session_id: String = _player_sessions[player_id]
	if _active_sessions.has(session_id):
		var session: ShardSession = _active_sessions[session_id]
		session.remove_player(player_id)
		
		# Если сессия пуста и не является корневой, уничтожаем её
		if session.get_player_count() == 0 and not session.parent_session_id.is_empty():
			destroy_session(session_id)
	
	_player_sessions.erase(player_id)
	emit_signal("player_left_session", session_id, player_id)
	
	print("[Session] Player %d left '%s'" % [player_id, session_id])
	return true

func destroy_session(session_id: String) -> bool:
	"""Уничтожение сессии и всех вложенных"""
	if not _active_sessions.has(session_id):
		return false
	
	# Сначала уничтожаем все вложенные сессии
	var sessions_to_destroy = []
	for sid in _active_sessions:
		var s: ShardSession = _active_sessions[sid]
		if s.parent_session_id == session_id:
			sessions_to_destroy.append(sid)
	
	for sid in sessions_to_destroy:
		destroy_session(sid)
	
	var session: ShardSession = _active_sessions[session_id]
	session.cleanup()
	_active_sessions.erase(session_id)
	
	emit_signal("session_destroyed", session_id)
	print("[Session] Destroyed '%s'" % session_id)
	return true

func get_session_for_player(player_id: int) -> String:
	return _player_sessions.get(player_id, "")

func get_active_session_count() -> int:
	return _active_sessions.size()

func _get_nesting_level(session_id: String) -> int:
	if not _active_sessions.has(session_id):
		return 0
	
	var level = 0
	var current_id = session_id
	
	while not _active_sessions[current_id].parent_session_id.is_empty():
		current_id = _active_sessions[current_id].parent_session_id
		level += 1
		
		if level > MAX_NESTING_LEVEL:
			break
	
	return level

func _exit_tree():
	# Очистка всех сессий при выходе
	for session_id in _active_sessions.keys():
		destroy_session(session_id)
