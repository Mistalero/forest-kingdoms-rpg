class_name SkeleRealmsIntegration
extends Node

## Интеграция архитектуры SkeleRealms в Forest Kingdoms RPG
## Предоставляет мост между существующими системами игры и компонентами SkeleRealms

signal integration_complete
signal entity_registered(entity: SKEntity)
signal component_added(entity: SKEntity, component: SKEntityComponent)

# Ссылки на autoloadы SkeleRealms
var sk_global: Node
var game_info: Node
var save_system: Node
var coven_system: Node
var crime_master: Node

# Маппинг компонентов SkeleRealms для существующих систем
var component_mapping: Dictionary = {
    "DamageableComponent": "combat",
    "InventoryComponent": "inventory",
    "EquipmentComponent": "equipment",
    "GOAPComponent": "ai",
    "NPCComponent": "npc",
    "PlayerComponent": "player",
    "VitalsComponent": "vitals",
    "AttributesComponent": "attributes",
    "SkillsComponent": "skills",
    "EffectsComponent": "effects",
    "InteractiveComponent": "interaction",
    "TeleportComponent": "teleport",
    "ShopComponent": "barter",
    "CovensComponent": "covens"
}

func _ready() -> void:
    await get_tree().process_frame
    _initialize_skelerealms_autoloads()
    _integrate_with_existing_systems()
    integration_complete.emit()

func _initialize_skelerealms_autoloads() -> void:
    # Получаем ссылки на autoloadы SkeleRealms
    sk_global = get_node_or_null("/root/SkeleRealmsGlobal")
    game_info = get_node_or_null("/root/GameInfo")
    save_system = get_node_or_null("/root/SaveSystem")
    coven_system = get_node_or_null("/root/CovenSystem")
    crime_master = get_node_or_null("/root/CrimeMaster")
    
    if not sk_global:
        push_warning("SkeleRealmsGlobal autoload не найден")
    if not game_info:
        push_warning("GameInfo autoload не найден")

func _integrate_with_existing_systems() -> void:
    # Интеграция с GameManager
    var game_manager = get_node_or_null("/root/GameManager")
    if game_manager:
        _connect_to_game_manager(game_manager)
    
    # Интеграция с системой генерации
    _setup_generation_hooks()
    
    # Интеграция с сетевой системой
    _setup_networking_hooks()
    
    # Интеграция с MUD режимом
    _setup_mud_integration()

func _connect_to_game_manager(game_manager: Node) -> void:
    # Подключение к событиям GameManager
    if game_manager.has_signal("game_started"):
        game_manager.game_started.connect(_on_game_started)
    if game_manager.has_signal("game_saved"):
        game_manager.game_saved.connect(_on_game_saved)
    if game_manager.has_signal("game_loaded"):
        game_manager.game_loaded.connect(_on_game_loaded)

func _setup_generation_hooks() -> void:
    # Хуки для интеграции с генераторами мира
    var world_gen = get_node_or_null("/root/WorldGenerator")
    if world_gen and world_gen.has_signal("entity_generated"):
        world_gen.entity_generated.connect(_on_entity_generated)

func _setup_networking_hooks() -> void:
    # Интеграция с P2P сетью
    var network_manager = get_node_or_null("/root/NetworkManager")
    if network_manager:
        network_manager.peer_connected.connect(_on_peer_connected)
        network_manager.peer_disconnected.connect(_on_peer_disconnected)

func _setup_mud_integration() -> void:
    # Интеграция с MUD режимом
    var mud_system = get_node_or_null("/root/MUDSystem")
    if mud_system:
        mud_system.command_executed.connect(_on_mud_command)

func _on_game_started() -> void:
    print("[SkeleRealms] Игра запущена, активация систем...")
    if game_info:
        game_info.start_game()

func _on_game_saved() -> void:
    if save_system:
        save_system.save_game()

func _on_game_loaded() -> void:
    if save_system:
        save_system.load_game()

func _on_entity_generated(entity_data: Dictionary) -> void:
    # Создание entity с компонентами SkeleRealms
    var entity = _create_entity_from_data(entity_data)
    if entity:
        entity_registered.emit(entity)

func _create_entity_from_data(data: Dictionary) -> SKEntity:
    var entity = SKEntity.new()
    entity.form_id = data.get("form_id", "unknown")
    entity.world = data.get("world", "main")
    entity.position = data.get("position", Vector3.ZERO)
    entity.unique = data.get("unique", false)
    
    # Добавляем компоненты на основе типа entity
    var components: Array = data.get("components", [])
    for comp_type in components:
        var component = _create_component(comp_type)
        if component:
            entity.add_component(component)
            component_added.emit(entity, component)
    
    return entity

func _create_component(type: String) -> SKEntityComponent:
    match type:
        "damageable":
            return DamageableComponent.new()
        "inventory":
            var comp = load("res://addons/skelerealms/scripts/components/inventory_component.gd").new()
            return comp
        "equipment":
            var comp = load("res://addons/skelerealms/scripts/components/equipment_component.gd").new()
            return comp
        "goap":
            var comp = load("res://addons/skelerealms/scripts/components/goap_component.gd").new()
            return comp
        "npc":
            var comp = load("res://addons/skelerealms/scripts/components/npc_component.gd").new()
            return comp
        "vitals":
            var comp = load("res://addons/skelerealms/scripts/components/vitals_component.gd").new()
            return comp
        "attributes":
            var comp = load("res://addons/skelerealms/scripts/components/attributes_component.gd").new()
            return comp
        _:
            return null

func _on_peer_connected(peer_id: int) -> void:
    # Синхронизация entities при подключении нового пира
    pass

func _on_peer_disconnected(peer_id: int) -> void:
    # Очистка ресурсов при отключении пира
    pass

func _on_mud_command(command: String, args: Array) -> void:
    # Обработка команд MUD для взаимодействия с entities
    match command:
        "spawn":
            _handle_spawn_command(args)
        "info":
            _handle_info_command(args)
        "equip":
            _handle_equip_command(args)

func _handle_spawn_command(args: Array) -> void:
    if args.size() < 1:
        print("Использование: spawn <form_id>")
        return
    var form_id = args[0]
    # Логика спавна entity

func _handle_info_command(args: Array) -> void:
    if args.size() < 1:
        print("Использование: info <entity_id>")
        return
    # Показать информацию об entity

func _handle_equip_command(args: Array) -> void:
    if args.size() < 2:
        print("Использование: equip <slot> <item_id>")
        return
    # Логика экипировки

## Утилита для получения entity из дерева узлов
func get_entity_from_node(node: Node) -> SKEntity:
    if sk_global and sk_global.has_method("get_entity_in_tree"):
        return sk_global.get_entity_in_tree(node)
    return null

## Утилита для нанесения урона через SkeleRealms
func apply_damage(target: Node, damage_info: Dictionary) -> void:
    var entity = get_entity_from_node(target)
    if entity and entity.has_component("DamageableComponent"):
        var dmg_comp = entity.get_component("DamageableComponent")
        if dmg_comp:
            var info = DamageInfo.new()
            info.amount = damage_info.get("amount", 0)
            info.damage_type = damage_info.get("type", "physical")
            info.source = damage_info.get("source", null)
            dmg_comp.damage(info)
