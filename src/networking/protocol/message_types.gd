# Типы игровых сообщений для P2P протокола Forest Kingdoms RPG
# Этот файл определяет константы для всех типов сообщений, используемых в игре

extends Node

# Базовые типы сообщений
const MSG_TYPE_CONNECTION = "connection"
const MSG_TYPE_DISCONNECT = "disconnect"
const MSG_TYPE_PING = "ping"
const MSG_TYPE_PONG = "pong"

# Типы сообщений о игроках
const MSG_TYPE_PLAYER_JOIN = "player_join"
const MSG_TYPE_PLAYER_LEAVE = "player_leave"
const MSG_TYPE_PLAYER_UPDATE = "player_update"
const MSG_TYPE_PLAYER_ACTION = "player_action"

# Типы сообщений о перемещении
const MSG_TYPE_MOVEMENT_START = "movement_start"
const MSG_TYPE_MOVEMENT_UPDATE = "movement_update"
const MSG_TYPE_MOVEMENT_STOP = "movement_stop"

# Типы сообщений о состоянии игры
const MSG_TYPE_GAME_STATE = "game_state"
const MSG_TYPE_GAME_EVENT = "game_event"
const MSG_TYPE_GAME_COMMAND = "game_command"

# Типы сообщений о мире
const MSG_TYPE_WORLD_UPDATE = "world_update"
const MSG_TYPE_OBJECT_UPDATE = "object_update"
const MSG_TYPE_NPC_UPDATE = "npc_update"

# Типы сообщений чата
const MSG_TYPE_CHAT_MESSAGE = "chat_message"
const MSG_TYPE_CHAT_PRIVATE = "chat_private"
const MSG_TYPE_CHAT_SYSTEM = "chat_system"

# Типы сообщений о сессии
const MSG_TYPE_SESSION_CREATE = "session_create"
const MSG_TYPE_SESSION_JOIN = "session_join"
const MSG_TYPE_SESSION_LEAVE = "session_leave"
const MSG_TYPE_SESSION_UPDATE = "session_update"

# Типы сообщений о синхронизации
const MSG_TYPE_SYNC_REQUEST = "sync_request"
const MSG_TYPE_SYNC_RESPONSE = "sync_response"
const MSG_TYPE_SYNC_UPDATE = "sync_update"

# Типы сообщений об ошибках
const MSG_TYPE_ERROR = "error"
const MSG_TYPE_WARNING = "warning"

# Получение списка всех типов сообщений
func get_all_message_types() -> Array:
	return [
		MSG_TYPE_CONNECTION,
		MSG_TYPE_DISCONNECT,
		MSG_TYPE_PING,
		MSG_TYPE_PONG,
		MSG_TYPE_PLAYER_JOIN,
		MSG_TYPE_PLAYER_LEAVE,
		MSG_TYPE_PLAYER_UPDATE,
		MSG_TYPE_PLAYER_ACTION,
		MSG_TYPE_MOVEMENT_START,
		MSG_TYPE_MOVEMENT_UPDATE,
		MSG_TYPE_MOVEMENT_STOP,
		MSG_TYPE_GAME_STATE,
		MSG_TYPE_GAME_EVENT,
		MSG_TYPE_GAME_COMMAND,
		MSG_TYPE_WORLD_UPDATE,
		MSG_TYPE_OBJECT_UPDATE,
		MSG_TYPE_NPC_UPDATE,
		MSG_TYPE_CHAT_MESSAGE,
		MSG_TYPE_CHAT_PRIVATE,
		MSG_TYPE_CHAT_SYSTEM,
		MSG_TYPE_SESSION_CREATE,
		MSG_TYPE_SESSION_JOIN,
		MSG_TYPE_SESSION_LEAVE,
		MSG_TYPE_SESSION_UPDATE,
		MSG_TYPE_SYNC_REQUEST,
		MSG_TYPE_SYNC_RESPONSE,
		MSG_TYPE_SYNC_UPDATE,
		MSG_TYPE_ERROR,
		MSG_TYPE_WARNING
	]

# Проверка, является ли тип сообщения допустимым
func is_valid_message_type(message_type: String) -> bool:
	return get_all_message_types().has(message_type)