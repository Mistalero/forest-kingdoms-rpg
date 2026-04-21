class_name EntityRenderer
extends Node

## Рендерер информации об entity для Bare Metal режима
## Отображает данные SkeleRealms entity в текстовом формате

# Форматы вывода
var output_formats: Dictionary = {
    "compact": false,
    "show_ids": true,
    "show_positions": true,
    "show_components": true,
    "component_details": true
}

# Цвета для разных типов данных (ANSI коды)
var colors: Dictionary = {
    "entity_id": "\x1b[36m",      # Cyan
    "form_id": "\x1b[32m",        # Green
    "position": "\x1b[33m",       # Yellow
    "component": "\x1b[35m",      # Magenta
    "stat": "\x1b[34m",           # Blue
    "warning": "\x1b[31m",        # Red
    "reset": "\x1b[0m"
}

func _ready() -> void:
    pass

func render_entity(entity: SKEntity, format: String = "default") -> String:
    """
    Рендеринг полной информации об entity
    
    Args:
        entity: SKEntity для рендеринга
        format: Формат вывода ("default", "compact", "detailed")
    
    Returns:
        String с отформатированным выводом
    """
    if not entity:
        return "[Invalid Entity]"
    
    match format:
        "compact":
            return _render_compact(entity)
        "detailed":
            return _render_detailed(entity)
        _:
            return _render_default(entity)

func _render_default(entity: SKEntity) -> String:
    """Стандартный формат вывода"""
    var output: Array[String] = []
    
    # Заголовок
    output.append("")
    output.append("=== Entity ===")
    output.append("")
    
    # Основная информация
    if output_formats.get("show_ids", true):
        output.append("ID: %s%s%s" % [colors["entity_id"], entity.form_id, colors["reset"]])
    
    output.append("World: %s" % entity.world)
    
    if output_formats.get("show_positions", true):
        output.append("Position: %s%s%s" % [colors["position"], str(entity.position), colors["reset"]])
    
    if entity.unique:
        output.append("%s[UNIQUE]%s" % [colors["warning"], colors["reset"]])
    
    # Компоненты
    if output_formats.get("show_components", true):
        output.append("")
        output.append("Компоненты:")
        
        var components = entity.get_components()
        if components.is_empty():
            output.append("  [Нет компонентов]")
        else:
            for comp in components:
                var comp_name = comp.get_class()
                output.append("  %s- %s%s" % [colors["component"], comp_name, colors["reset"]])
                
                if output_formats.get("component_details", true):
                    var details = _get_component_details(comp)
                    for detail in details:
                        output.append("    %s%s" % [colors["stat"], detail, colors["reset"]])
    
    return "\n".join(output)

func _render_compact(entity: SKEntity) -> String:
    """Компактный формат - одна строка"""
    var comp_count = entity.get_components().size()
    return "[%s] %s (%d компонентов)" % [entity.form_id, str(entity.position), comp_count]

func _render_detailed(entity: SKEntity) -> String:
    """Детальный формат со всей доступной информацией"""
    var output: Array[String] = []
    
    output.append("")
    output.append("╔══════════════════════════════════════╗")
    output.append("║         ENTITY INFORMATION           ║")
    output.append("╚══════════════════════════════════════╝")
    output.append("")
    
    # Основная информация
    output.append("📋 Основная информация:")
    output.append("   Form ID:    %s" % entity.form_id)
    output.append("   World:      %s" % entity.world)
    output.append("   Position:   %s" % str(entity.position))
    output.append("   Unique:     %s" % ("Да" if entity.unique else "Нет"))
    output.append("")
    
    # Компоненты с деталями
    output.append("🔧 Компоненты:")
    var components = entity.get_components()
    
    if components.is_empty():
        output.append("   [Нет компонентов]")
    else:
        for i in range(components.size()):
            var comp = components[i]
            var comp_name = comp.get_class()
            var icon = _get_component_icon(comp_name)
            
            output.append("   %s %s" % [icon, comp_name])
            
            var details = _get_component_details(comp)
            for detail in details:
                output.append("      └─ %s" % detail)
    
    output.append("")
    
    return "\n".join(output)

func _get_component_icon(component_name: String) -> String:
    """Получение иконки для типа компонента"""
    var icons: Dictionary = {
        "DamageableComponent": "⚔️",
        "InventoryComponent": "🎒",
        "EquipmentComponent": "🛡️",
        "GOAPComponent": "🧠",
        "NPCComponent": "👤",
        "PlayerComponent": "👤",
        "VitalsComponent": "❤️",
        "AttributesComponent": "📊",
        "SkillsComponent": "⭐",
        "EffectsComponent": "✨",
        "InteractiveComponent": "🖱️",
        "TeleportComponent": "🌀",
        "ShopComponent": "💰",
        "CovensComponent": "🔮"
    }
    
    return icons.get(component_name, "📦")

func _get_component_details(component: SKEntityComponent) -> Array[String]:
    """Получение деталей компонента для отображения"""
    var details: Array[String] = []
    
    if not component:
        return details
    
    var comp_name = component.get_class()
    
    match comp_name:
        "DamageableComponent":
            if component.has_method("get_health"):
                var hp = component.get_health()
                var max_hp = component.get_max_health() if component.has_method("get_max_health") else 100
                details.append("HP: %d/%d" % [hp, max_hp])
            if component.has_method("get_damage_types"):
                details.append("Типы урона: %s" % str(component.get_damage_types()))
        
        "InventoryComponent":
            if component.has_method("get_item_count"):
                var count = component.get_item_count()
                var capacity = component.get_capacity() if component.has_method("get_capacity") else 0
                details.append("Предметы: %d/%d" % [count, capacity])
        
        "VitalsComponent":
            if component.has_method("get_vitals"):
                var vitals = component.get_vitals()
                for key in vitals:
                    details.append("%s: %s" % [key, str(vitals[key])])
        
        "AttributesComponent":
            if component.has_method("get_attributes"):
                var attrs = component.get_attributes()
                for key in attrs:
                    details.append("%s: %d" % [key, attrs[key]])
        
        "GOAPComponent":
            if component.has_method("get_current_goal"):
                details.append("Текущая цель: %s" % str(component.get_current_goal()))
            if component.has_method("get_state"):
                details.append("Состояние: %s" % component.get_state())
        
        "EffectsComponent":
            if component.has_method("get_active_effects"):
                var effects = component.get_active_effects()
                details.append("Активных эффектов: %d" % effects.size())
        
        "EquipmentComponent":
            if component.has_method("get_equipped_items"):
                var equipped = component.get_equipped_items()
                details.append("Экипировано: %d предметов" % equipped.size())
        
        "SkillsComponent":
            if component.has_method("get_skills"):
                var skills = component.get_skills()
                details.append("Навыков: %d" % skills.size())
    
    return details

func render_entity_list(entities: Array, title: String = "Entity") -> String:
    """Рендеринг списка entity"""
    var output: Array[String] = []
    
    output.append("")
    output.append("=== %s ===" % title)
    output.append("")
    
    if entities.is_empty():
        output.append("[Нет entity]")
    else:
        for i in range(entities.size()):
            var entity = entities[i]
            if entity is SKEntity:
                output.append("  [%d] %s" % [i + 1, _render_compact(entity)])
            else:
                output.append("  [%d] %s" % [i + 1, str(entity)])
    
    output.append("")
    
    return "\n".join(output)

func render_component_info(component: SKEntityComponent) -> String:
    """Рендеринг информации об отдельном компоненте"""
    if not component:
        return "[Invalid Component]"
    
    var output: Array[String] = []
    
    output.append("")
    output.append("=== Компонент: %s ===" % component.get_class())
    output.append("")
    
    var details = _get_component_details(component)
    if details.is_empty():
        output.append("[Нет дополнительной информации]")
    else:
        for detail in details:
            output.append("  • %s" % detail)
    
    output.append("")
    
    return "\n".join(output)

func set_output_format(key: String, value: Variant) -> void:
    """Установка параметра формата вывода"""
    output_formats[key] = value

func get_output_format(key: String) -> Variant:
    """Получение параметра формата вывода"""
    return output_formats.get(key)

func set_color(type: String, color_code: String) -> void:
    """Установка ANSI цвета для типа данных"""
    colors[type] = color_code

func enable_colors(enabled: bool) -> void:
    """Включение/отключение цветов"""
    if not enabled:
        for key in colors:
            colors[key] = ""
    else:
        # Восстановление цветов по умолчанию
        colors["entity_id"] = "\x1b[36m"
        colors["form_id"] = "\x1b[32m"
        colors["position"] = "\x1b[33m"
        colors["component"] = "\x1b[35m"
        colors["stat"] = "\x1b[34m"
        colors["warning"] = "\x1b[31m"
        colors["reset"] = "\x1b[0m"
