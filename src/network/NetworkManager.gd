extends Node
class_name NetworkManager

## Децентрализованный P2P сетевой менеджер
## Поддерживает mesh-сети, динамические сессии-шарды

signal session_created(session_id: String)
signal session_destroyed()
signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)

var is_connected_flag: bool = false
var current_session_id: String = ""
var peers: Array = []
var is_light_node: bool = false
var connection_type: String = "p2p"

func initialize(light_node: bool = false):
is_light_node = light_node
print("[NetworkManager] Инициализация сети (light_node=%s)" % str(light_node))
# Здесь будет логика подключения к P2P сети
create_or_join_session()

func set_node_type(light: bool):
is_light_node = light
print("[NetworkManager] Тип ноды изменен: %s" % ("light" if light else "full"))

func create_or_join_session():
"""Создает новую сессию или присоединяется к существующей"""
current_session_id = "session_" + str(randi())
is_connected_flag = true
session_created.emit(current_session_id)
print("[NetworkManager] Сессия создана: %s" % current_session_id)

func shutdown():
"""Завершает сетевое соединение"""
is_connected_flag = false
peers.clear()
session_destroyed.emit()
print("[NetworkManager] Сеть остановлена")

func is_connected() -> bool:
return is_connected_flag

func get_peer_count() -> int:
return peers.size()
