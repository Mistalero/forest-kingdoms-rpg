# Децентрализованная Игровая Экосистема

Универсальная платформа для создания и запуска игр с полной децентрализацией, поддержкой множественных стилей отображения и кроссплатформенностью.

## Ключевые Возможности

- **P2P Сеть**: Полностью децентрализованная архитектура без центральных серверов
- **Полиморфный Рендеринг**: Поддержка Voxel, Anime, 2D, Isometric, Sprite3D, Text, ASCII режимов
- **Рекурсивные Сессии**: Матрёшка-архитектура с вложенными шардами
- **Мультипротокольность**: TCP, UDP, WebSocket, QUIC, WebRTC, Tor, I2P
- **Кроссплатформенность**: Запуск на ПК, консолях, мобильных устройствах, в браузере
- **Libretro Интеграция**: Работа через RetroArch на любых эмуляторах
- **Без Демонов**: Процесс существует только во время работы приложения

## Структура Проекта

```
src/
├── core/                  # Ядро системы
│   ├── Main.gd           # Точка входа
│   └── InputHandler.gd   # Обработка ввода
├── network/              # Сетевой слой
│   ├── NetworkManager.gd # P2P менеджер
│   └── ShardSession.gd   # Управление сессиями-шардами
├── visual/               # Визуализация
│   ├── VisualController.gd # Контроллер рендеринга
│   └── renderers/        # Движки рендеринга
│       ├── VoxelRenderer.gd
│       ├── AnimeRenderer.gd
│       ├── 2DRenderer.gd
│       ├── IsometricRenderer.gd
│       ├── Sprite3DRenderer.gd
│       ├── TextRenderer.gd
│       └── ASCIIRenderer.gd
├── data/                 # Управление данными
│   └── DataManager.gd    # Локальный кэш + синхронизация
└── platform/             # Платформенные адаптеры
    └── libretro/         # Libretro核心
        └── libretro_core.c

docs/                     # Документация
build/                    # Скрипты сборки
```

## Архитектура

### Сетевая Модель
Каждый клиент является полноценной нодой:
- Хранит локальное состояние мира
- Участвует в консенсусе
- Маршрутизирует трафик
- Не требует центрального сервера

### Визуальная Изоляция
Стили отображения клиентские:
- Игрок А видит Minecraft (Voxel)
- Игрок Б видит Anime (Cel-Shader)
- Игрок В видит Текстовый интерфейс
- Общая логика и физика для всех

### Рекурсивные Сессии
Сессии могут содержать вложенные сессии:
```
Сессия_Главная
├── Сессия_Город_1
│   ├── Сессия_Дом_А
│   └── Сессия_Дом_Б
└── Сессия_Подземелье_X
```

## Запуск

### Стандартный Режим (Godot)
```bash
godot src/core/Main.tscn
```

### Libretro / RetroArch
```bash
# Компиляция ядра
gcc -shared -fPIC -o omnigame_libretro.so src/platform/libretro/libretro_core.c

# Запуск в RetroArch
retroarch -L omnigame_libretro.so game.omni
```

### Как Оболочка ОС
Настройте автозагрузку приложения при старте системы для режима "Игра = ОС".

## Сборка

### Desktop (Windows/Linux/Mac)
```bash
godot --export-release "Desktop" build/game.exe
```

### WebAssembly
```bash
godot --export-release "Web" build/index.html
```

### Libretro Core
```bash
make -C src/platform/libretro/
```

## Конфигурация

Параметры настраиваются через `project.godot` или CLI:
- `render_mode`: VOXEL, ANIME, 2D, ISOMETRIC, SPRITE3D, TEXT, ASCII
- `quality_level`: 0 (Low) - 3 (Ultra)
- `session_id`: Идентификатор сессии для подключения

## Лицензия

MIT License - см. файл LICENSE

## Документация

- [Сетевая Архитектура](docs/network/README.md)
- [Визуальные Режимы](docs/visual/README.md)
- [Развёртывание](docs/deployment/README.md)
- [API Reference](docs/api/README.md)
