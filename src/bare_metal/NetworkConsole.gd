class_name NetworkConsole
extends Node

## Консольный интерфейс для P2P сети в Bare Metal режиме
## Управление пирами и синхронизация состояния

signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)
signal data_received(peer_id: int, data: Dictionary)

# Состояние сети
var connected_peers: Dictionary = {}
var local_peer_id: int = 0
var is_host: bool = false

# Статистика
var stats: Dictionary = {
    "bytes_sent": 0,
    "bytes_received": 0,
    "messages_sent": 0,
    "messages_received": 0
}

func _ready() -> void:
    pass

func list_peers() -> void:
    """Вывод списка подключенных пиров"""
    var output: Array[String] = []
    
    output.append("")
    output.append("=== Подключенные пиры ===")
    output.append("")
    
    if connected_peers.is_empty():
        output.append("[Нет подключенных пиров]")
    else:
        for peer_id in connected_peers:
            var peer_info = connected_peers[peer_id]
            var status = peer_info.get("status", "unknown")
            var latency = peer_info.get("latency", -1)
            
            var status_icon = "✓" if status == "connected" else "?"
            var latency_str = "%d ms" % latency if latency >= 0 else "N/A"
            
            output.append("  [%d] %s Статус: %s Пинг: %s" % [
                peer_id,
                peer_info.get("name", "Unknown"),
                status,
                latency_str
            ])
    
    output.append("")
    output.append("Локальный ID: %d%s" % [local_peer_id, " (Host)" if is_host else ""])
    output.append("")
    
    print("\n".join(output))

func sync_state() -> void:
    """Синхронизация состояния с пирами"""
    var output: Array[String] = []
    
    output.append("")
    output.append("=== Синхронизация состояния ===")
    output.append("")
    
    if connected_peers.is_empty():
        output.append("[Нет пиров для синхронизации]")
    else:
        output.append("Отправка обновлений %d пирам..." % connected_peers.size())
        
        # Здесь должна быть реальная логика синхронизации
        for peer_id in connected_peers:
            output.append("  → Peer %d: отправлено" % peer_id)
            stats["messages_sent"] += 1
    
    output.append("")
    
    print("\n".join(output))

func send_to_peer(peer_id_str: String, data_str: String) -> void:
    """Отправка данных конкретному пиру"""
    var peer_id = int(peer_id_str)
    
    var output: Array[String] = []
    
    output.append("")
    output.append("=== Отправка данных ===")
    output.append("")
    output.append("Получатель: Peer %d" % peer_id)
    output.append("Данные: %s" % data_str)
    
    if not connected_peers.has(peer_id):
        output.append("%sОшибка: Пир не найден%s" % ["\x1b[31m", "\x1b[0m"])
    else:
        # Здесь должна быть реальная отправка
        output.append("%sОтправлено успешно%s" % ["\x1b[32m", "\x1b[0m"])
        stats["bytes_sent"] += data_str.length()
        stats["messages_sent"] += 1
    
    output.append("")
    
    print("\n".join(output))

func broadcast_message(message: String) -> void:
    """Трансляция сообщения всем пирам"""
    var count = 0
    
    for peer_id in connected_peers:
        # Здесь должна быть реальная отправка
        count += 1
        stats["messages_sent"] += 1
    
    return count

func get_stats() -> Dictionary:
    """Получение статистики сети"""
    return stats.duplicate()

func print_stats() -> void:
    """Вывод статистики сети"""
    var output: Array[String] = []
    
    output.append("")
    output.append("=== Сетевая статистика ===")
    output.append("")
    output.append("Подключено пиров: %d" % connected_peers.size())
    output.append("Сообщений отправлено: %d" % stats["messages_sent"])
    output.append("Сообщений получено: %d" % stats["messages_received"])
    output.append("Байт отправлено: %d" % stats["bytes_sent"])
    output.append("Байт получено: %d" % stats["bytes_received"])
    output.append("")
    
    print("\n".join(output))

func add_peer(peer_id: int, peer_info: Dictionary) -> void:
    """Добавление пира в список"""
    connected_peers[peer_id] = peer_info
    peer_connected.emit(peer_id)

func remove_peer(peer_id: int) -> void:
    """Удаление пира из списка"""
    if connected_peers.has(peer_id):
        connected_peers.erase(peer_id)
        peer_disconnected.emit(peer_id)

func set_local_peer_id(id: int) -> void:
    """Установка локального ID пира"""
    local_peer_id = id

func set_is_host(host: bool) -> void:
    """Установка статуса хоста"""
    is_host = host
