extends Node
class_name NetworkManager

# Децентрализованный P2P менеджер
# Поддержка множественных протоколов (TCP, UDP, WebSocket, WebRTC)
# Работает без центрального сервера

signal peer_connected(peer_id: int, peer_info: Dictionary)
signal peer_disconnected(peer_id: int)
signal data_received(peer_id: int, data: Variant)
signal session_joined(session_id: String)

var local_peer_id: int = 0
var connected_peers: Dictionary = {} # peer_id -> info
var available_protocols: Array = ["tcp", "udp", "websocket", "webrtc"]
var current_protocol: String = "tcp"

var _server: MultiplayerPeer = null
var _is_host: bool = false

func _ready() -> void:
    local_peer_id = hash(str(OS.get_unique_id(), Time.get_ticks_msec())) % 100000
    print("[NETWORK] Local peer ID: ", local_peer_id)

func host_session(port: int = 7777, protocol: String = "tcp") -> Error:
    _is_host = true
    current_protocol = protocol
    
    match protocol:
        "tcp", "udp":
            _setup_enet_host(port)
        "websocket":
            _setup_websocket_host(port)
        "webrtc":
            _setup_webrtc_host()
    
    return OK

func join_session(host_address: String, port: int = 7777, protocol: String = "tcp") -> Error:
    current_protocol = protocol
    
    match protocol:
        "tcp", "udp":
            _setup_enet_client(host_address, port)
        "websocket":
            _setup_websocket_client(host_address, port)
        "webrtc":
            _setup_webrtc_client(host_address)
    
    return OK

func _setup_enet_host(port: int) -> void:
    var peer = ENetMultiplayerPeer.new()
    var error = peer.create_server(port, 32)
    if error == OK:
        _server = peer
        multiplayer.multiplayer_peer = peer
        print("[NETWORK] ENet server started on port ", port)
    else:
        print("[NETWORK] Failed to start ENet server: ", error)

func _setup_enet_client(address: String, port: int) -> void:
    var peer = ENetMultiplayerPeer.new()
    var error = peer.create_client(address, port)
    if error == OK:
        _server = peer
        multiplayer.multiplayer_peer = peer
        print("[NETWORK] ENet client connected to ", address, ":", port)
    else:
        print("[NETWORK] Failed to connect via ENet: ", error)

func _setup_websocket_host(port: int) -> void:
    # Заглушка для WebSocket хоста
    print("[NETWORK] WebSocket host mode not fully implemented yet")

func _setup_websocket_client(address: String, port: int) -> void:
    # Заглушка для WebSocket клиента
    print("[NETWORK] WebSocket client mode not fully implemented yet")

func _setup_webrtc_host() -> void:
    # Заглушка для WebRTC хоста
    print("[NETWORK] WebRTC host mode not fully implemented yet")

func _setup_webrtc_client(address: String) -> void:
    # Заглушка для WebRTC клиента
    print("[NETWORK] WebRTC client mode not fully implemented yet")

func send_to_all(data: Variant) -> void:
    if _is_host:
        # Хост рассылает всем пирам
        for peer_id in connected_peers:
            send_to_peer(peer_id, data)
    else:
        # Клиент отправляет только хосту
        send_to_peer(1, data)

func send_to_peer(peer_id: int, data: Variant) -> void:
    # Реализация отправки данных конкретному пиру
    # В Godot 4 это делается через RPC или прямой доступ к peer
    pass

func disconnect_from_session() -> void:
    if multiplayer.multiplayer_peer:
        multiplayer.multiplayer_peer.close()
        multiplayer.multiplayer_peer = null
    connected_peers.clear()
    print("[NETWORK] Disconnected from session")

func get_peer_count() -> int:
    return connected_peers.size()

func is_connected() -> bool:
    return multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED

func _on_peer_connected(id: int) -> void:
    if id != local_peer_id:
        connected_peers[id] = {"id": id, "joined_at": Time.get_unix_time_from_system()}
        peer_connected.emit(id, connected_peers[id])
        print("[NETWORK] Peer connected: ", id)

func _on_peer_disconnected(id: int) -> void:
    if connected_peers.has(id):
        connected_peers.erase(id)
        peer_disconnected.emit(id)
        print("[NETWORK] Peer disconnected: ", id)
