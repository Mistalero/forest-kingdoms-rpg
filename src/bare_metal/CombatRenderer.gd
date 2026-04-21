class_name CombatRenderer
extends Node

## Рендерер боевой системы для Bare Metal режима
## Отображает информацию о бое, уроне и состоянии конечностей

# Цвета для боевых сообщений
var colors: Dictionary = {
    "damage": "\x1b[31m",         # Красный для урона
    "heal": "\x1b[32m",           # Зелёный для лечения
    "info": "\x1b[36m",           # Голубой для информации
    "warning": "\x1b[33m",        # Жёлтый для предупреждений
    "critical": "\x1b[35m",       # Пурпурный для критических
    "limb": "\x1b[34m",           # Синий для конечностей
    "reset": "\x1b[0m"
}

# Шаблоны сообщений
var message_templates: Dictionary = {
    "attack": "Атака по %s!",
    "damage_dealt": "Нанесено %d урона (%s) по %s.",
    "damage_received": "Получено %d урона (%s) от %s.",
    "limb_hit": "Попадание в %s!",
    "limb_critical": "%s - КРИТИЧЕСКОЕ ПОВРЕЖДЕНИЕ!",
    "limb_amputated": "%s ампутирована!",
    "bleeding": "Кровотечение! (-%d HP/ход)",
    "death": "%s погибает!"
}

func _ready() -> void:
    pass

func render_attack(attacker: String, target: String, weapon: String = "") -> String:
    """Рендеринг сообщения об атаке"""
    var msg = message_templates.get("attack", "Атака по %s!") % target
    
    if not weapon.is_empty():
        msg += " (Оружие: %s)" % weapon
    
    return "%s%s%s" % [colors["info"], msg, colors["reset"]]

func render_damage_dealt(target: String, amount: int, damage_type: String, source: String = "") -> String:
    """Рендеринг сообщения о нанесённом уроне"""
    var msg = message_templates.get("damage_dealt", "Нанесено %d урона (%s) по %s.")
    msg = msg % [amount, damage_type, target]
    
    if not source.is_empty():
        msg += " (Источник: %s)" % source
    
    return "%s%s%s" % [colors["damage"], msg, colors["reset"]]

func render_damage_received(source: String, amount: int, damage_type: String) -> String:
    """Рендеринг сообщения о полученном уроне"""
    var msg = message_templates.get("damage_received", "Получено %d урона (%s) от %s.")
    msg = msg % [amount, damage_type, source]
    
    return "%s%s%s" % [colors["damage"], msg, colors["reset"]]

func render_limb_hit(limb_name: String, damage: int, current_hp: int, max_hp: int) -> String:
    """Рендеринг попадания в конечность"""
    var output: Array[String] = []
    
    # Базовое сообщение
    var msg = message_templates.get("limb_hit", "Попадание в %s!") % limb_name
    output.append("%s%s%s" % [colors["limb"], msg, colors["reset"]])
    
    # HP конечности
    var hp_percent = float(current_hp) / float(max_hp) * 100 if max_hp > 0 else 0
    output.append("  Состояние: %d/%d HP (%.1f%%)" % [current_hp, max_hp, hp_percent])
    
    # Статус в зависимости от HP
    if hp_percent <= 0:
        output.append("  %s%s КОНЕЧНОСТЬ УНИЧТОЖЕНА!%s" % [colors["critical"], limb_name, colors["reset"]])
    elif hp_percent <= 25:
        output.append("  %s%s КРИТИЧЕСКИ ПОВРЕЖДЕНА!%s" % [colors["critical"], limb_name, colors["reset"]])
    elif hp_percent <= 50:
        output.append("  %s%s СИЛЬНО ПОВРЕЖДЕНА%s" % [colors["warning"], limb_name, colors["reset"]])
    
    return "\n".join(output)

func render_limb_amputation(limb_name: String, entity_name: String) -> String:
    """Рендеринг ампутации конечности"""
    var msg = message_templates.get("limb_amputated", "%s ампутирована!") % limb_name
    
    var output: Array[String] = []
    output.append("%s%s%s" % [colors["critical"], msg, colors["reset"]])
    output.append("  Цель: %s" % entity_name)
    output.append("  %sШанс кровотечения: 75%%%s" % [colors["warning"], colors["reset"]])
    output.append("  %sШтраф к атаке: -40%%%s" % [colors["warning"], colors["reset"]])
    
    return "\n".join(output)

func render_bleeding(amount: int, duration: int = -1) -> String:
    """Рендеринг кровотечения"""
    var msg = message_templates.get("bleeding", "Кровотечение! (-%d HP/ход)") % amount
    
    var output: Array[String] = []
    output.append("%s%s%s" % [colors["damage"], msg, colors["reset"]])
    
    if duration > 0:
        output.append("  Длительность: %d ходов" % duration)
    
    return "\n".join(output)

func render_death(entity_name: String, killer: String = "") -> String:
    """Рендеринг смерти"""
    var msg = message_templates.get("death", "%s погибает!") % entity_name
    
    var output: Array[String] = []
    output.append("%s%s%s" % [colors["critical"], msg, colors["reset"]])
    
    if not killer.is_empty():
        output.append("  Убийца: %s" % killer)
    
    return "\n".join(output)

func render_limb_status(limbs: Dictionary, entity_name: String = "") -> String:
    """
    Рендеринг статуса всех конечностей
    
    limbs: Dictionary с данными о конечностях
    Пример: {
        "head": {"name": "Голова", "hp": 50, "max_hp": 50, "status": "ok"},
        "torso": {"name": "Торс", "hp": 100, "max_hp": 100, "status": "ok"},
        "left_arm": {"name": "Левая рука", "hp": 0, "max_hp": 25, "status": "amputated"},
        ...
    }
    """
    var output: Array[String] = []
    
    output.append("")
    output.append("=== Статус конечностей ===")
    if not entity_name.is_empty():
        output.append("Цель: %s" % entity_name)
    output.append("")
    
    # Порядок отображения
    var limb_order = ["head", "torso", "left_arm", "right_arm", "left_leg", "right_leg"]
    
    for limb_key in limb_order:
        if limbs.has(limb_key):
            var limb = limbs[limb_key]
            var status_line = _render_single_limb(limb)
            output.append(status_line)
    
    output.append("")
    
    return "\n".join(output)

func _render_single_limb(limb_data: Dictionary) -> String:
    """Рендеринг одной конечности"""
    var name = limb_data.get("name", "Неизвестно")
    var hp = limb_data.get("hp", 0)
    var max_hp = limb_data.get("max_hp", 1)
    var status = limb_data.get("status", "unknown")
    
    var status_icon = ""
    var status_text = ""
    var color_code = colors["reset"]
    
    match status:
        "ok":
            status_icon = "✓"
            status_text = "OK"
            color_code = colors["heal"]
        "injured":
            status_icon = "⚠"
            status_text = "ПОВРЕЖДЕНА"
            color_code = colors["warning"]
        "critical":
            status_icon = "✗"
            status_text = "КРИТИЧЕСКИ"
            color_code = colors["critical"]
        "amputated":
            status_icon = "☠"
            status_text = "АМПУТИРОВАНА"
            color_code = colors["damage"]
        _:
            status_icon = "?"
            status_text = "НЕИЗВЕСТНО"
    
    var hp_text = ""
    if status != "amputated":
        hp_text = " (%d/%d HP)" % [hp, max_hp]
    
    return "  %s %s: %s%s%s%s" % [status_icon, name, color_code, status_text, colors["reset"], hp_text]

func render_combat_log(combat_data: Dictionary) -> String:
    """Рендеринг лога боя"""
    var output: Array[String] = []
    
    output.append("")
    output.append("=== Журнал боя ===")
    output.append("")
    
    var events = combat_data.get("events", [])
    if events.is_empty():
        output.append("[Нет событий в бою]")
    else:
        for event in events:
            var line = _render_combat_event(event)
            output.append(line)
    
    output.append("")
    
    return "\n".join(output)

func _render_combat_event(event: Dictionary) -> String:
    """Рендеринг отдельного события боя"""
    var event_type = event.get("type", "unknown")
    var timestamp = event.get("timestamp", 0)
    
    var msg = ""
    
    match event_type:
        "attack":
            msg = render_attack(
                event.get("attacker", "Неизвестно"),
                event.get("target", "Неизвестно"),
                event.get("weapon", "")
            )
        "damage":
            msg = render_damage_dealt(
                event.get("target", "Неизвестно"),
                event.get("amount", 0),
                event.get("damage_type", "physical"),
                event.get("source", "")
            )
        "limb_hit":
            msg = render_limb_hit(
                event.get("limb", "Неизвестно"),
                event.get("damage", 0),
                event.get("current_hp", 0),
                event.get("max_hp", 1)
            )
        "amputation":
            msg = render_limb_amputation(
                event.get("limb", "Неизвестно"),
                event.get("entity", "Неизвестно")
            )
        "death":
            msg = render_death(
                event.get("entity", "Неизвестно"),
                event.get("killer", "")
            )
        _:
            msg = "[Неизвестное событие: %s]" % event_type
    
    return msg

func render_prosthesis_equipped(prosthesis_type: String, limb_slot: String, bonuses: Dictionary) -> String:
    """Рендеринг установки протеза"""
    var output: Array[String] = []
    
    output.append("")
    output.append("=== Протез установлен ===")
    output.append("")
    output.append("Тип: %s" % prosthesis_type)
    output.append("Слот: %s" % limb_slot)
    output.append("")
    output.append("Эффекты:")
    
    for bonus in bonuses:
        var value = bonuses[bonus]
        var sign = "+" if value > 0 else ""
        output.append("  • %s: %s%d" % [bonus, sign, value])
    
    output.append("")
    
    return "\n".join(output)

func set_color(type: String, color_code: String) -> void:
    """Установка цвета для типа сообщения"""
    colors[type] = color_code

func enable_colors(enabled: bool) -> void:
    """Включение/отключение цветов"""
    if not enabled:
        for key in colors:
            colors[key] = ""
    else:
        # Восстановление цветов по умолчанию
        colors["damage"] = "\x1b[31m"
        colors["heal"] = "\x1b[32m"
        colors["info"] = "\x1b[36m"
        colors["warning"] = "\x1b[33m"
        colors["critical"] = "\x1b[35m"
        colors["limb"] = "\x1b[34m"
        colors["reset"] = "\x1b[0m"
