extends Node
class_name P2PNetworkManager

## Децентрализованный P2P менеджер
## Поддерживает mesh-сети, динамическое обнаружение пиров и маршрутизацию

signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)
signal message_received(peer_id: int, data: Variant)
signal network_status_changed(status: String)

const MAX_PEERS = 100
const PING_INTERVAL = 5.0
const DISCOVERY_PORT = 9090
const DATA_PORT = 9091

var _multiplayer_api: MultiplayerAPI
var _peer_list: Dictionary = {} # peer_id -> PeerInfo
var _is_host: bool = false
var _network_id: String = ""
var _discovery_timer: Timer
var _ping_timer: Timer

class PeerInfo:
	var id: int
	var ip: String = ""
	var port: int = 0
	var last_seen: float = 0.0
	var latency: float = 0.0
	var is_relay: bool = false
	
	func _init(pid: int, pip: String = "", pport: int = 0):
		id = pid
		ip = pip
		port = pport
		last_seen = Time.get_unix_time_from_system()

func _ready():
	_setup_multiplayer()
	_setup_timers()
	print("[P2P] Network manager initialized")

func _setup_multiplayer():
	_multiplayer_api = MultiplayerAPI.new()
	multiplayer.multiplayer_peer = null # Инициализация позже

func _setup_timers():
	_discovery_timer = Timer.new()
	_discovery_timer.wait_time = 10.0
	_discovery_timer.timeout.connect(_on_discovery_timeout)
	add_child(_discovery_timer)
	
	_ping_timer = Timer.new()
	_ping_timer.wait_time = PING_INTERVAL
	_ping_timer.timeout.connect(_on_ping_timeout)
	add_child(_ping_timer)

func start_host(network_id: String = "default_world") -> bool:
	"""Запуск хоста новой сессии"""
	_network_id = network_id
	_is_host = true
	
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(DATA_PORT, MAX_PEERS)
	
	if error != OK:
		push_error("[P2P] Failed to create server: %s" % error_string(error))
		return false
	
	multiplayer.multiplayer_peer = peer
	_peer_list[1] = PeerInfo.new(1, "127.0.0.1", DATA_PORT) # Local host
	
	_discovery_timer.start()
	_ping_timer.start()
	
	emit_signal("network_status_changed", "hosting")
	print("[P2P] Hosting session '%s' on port %d" % [network_id, DATA_PORT])
	return true

func join_peer(host_ip: String, host_port: int = DATA_PORT) -> bool:
	"""Подключение к существующей сессии"""
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(host_ip, host_port)
	
	if error != OK:
		push_error("[P2P] Failed to connect to peer: %s" % error_string(error))
		return false
	
	multiplayer.multiplayer_peer = peer
	_discovery_timer.start()
	_ping_timer.start()
	
	emit_signal("network_status_changed", "connected")
	print("[P2P] Connected to %s:%d" % [host_ip, host_port])
	return true

func broadcast_message(data: Variant, exclude_peers: Array = []):
	"""Отправка сообщения всем пирам"""
	if not multiplayer.multiplayer_peer or multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return
	
	# Используем RPC для отправки
	_receive_message.rpc(data)

@rpc("any_peer", "unreliable")
func _receive_message(data: Variant):
	var sender_id = multiplayer.get_remote_sender_id()
	emit_signal("message_received", sender_id, data)
	
	# Обновляем информацию о пире
	if _peer_list.has(sender_id):
		_peer_list[sender_id].last_seen = Time.get_unix_time_from_system()
	else:
		_peer_list[sender_id] = PeerInfo.new(sender_id)
		emit_signal("peer_connected", sender_id)

func get_peer_count() -> int:
	return _peer_list.size()

func get_connected_peers() -> Array:
	return _peer_list.keys()

func disconnect_from_network():
	"""Отключение от сети"""
	if _discovery_timer:
		_discovery_timer.stop()
	if _ping_timer:
		_ping_timer.stop()
	
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	
	_peer_list.clear()
	_is_host = false
	_network_id = ""
	
	emit_signal("network_status_changed", "disconnected")
	print("[P2P] Disconnected from network")

func _on_discovery_timeout():
	"""Периодическое обнаружение пиров (упрощенная реализация)"""
	# В полной реализации здесь будет UDP широковещательная рассылка
	pass

func _on_ping_timeout():
	"""Проверка активности пиров"""
	var current_time = Time.get_unix_time_from_system()
	var peers_to_remove = []
	
	for peer_id in _peer_list:
		if peer_id == 1: # Пропускаем хоста
			continue
		var info: PeerInfo = _peer_list[peer_id]
		if current_time - info.last_seen > PING_INTERVAL * 3:
			peers_to_remove.append(peer_id)
	
	for peer_id in peers_to_remove:
		_peer_list.erase(peer_id)
		emit_signal("peer_disconnected", peer_id)
		print("[P2P] Peer %d timed out" % peer_id)

func _exit_tree():
	disconnect_from_network()
