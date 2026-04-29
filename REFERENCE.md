# Shape Match - Referencia del Proyecto

## Estructura General

Juego 2D para Android en Godot 4.6 donde formas geométricas caen desde el centro de la pantalla y el jugador debe coincidir su forma con la que cae tocando el lado izquierdo o derecho de la pantalla.

---

## Configuración Principal (`project.godot`)

| Configuración | Valor | Descripción |
|---|---|---|
| `display/size/viewport_width` | 1080 | Resolución horizontal del viewport |
| `display/size/viewport_height` | 1920 | Resolución vertical del viewport (9:16) |
| `display/size/mode` | 3 | Pantalla completa |
| `display/stretch/mode` | canvas_items | Escala todos los elementos para llenar pantalla |
| `display/stretch/aspect` | keep | Mantiene relación de aspecto sin deformar |
| `display/handheld/orientation` | 1 | Modo portrait (vertical) |
| `input/move_left` | A, ← | Acción de teclado para forma anterior |
| `input/move_right` | D, → | Acción de teclado para forma siguiente |

---

## Escenarios

### `main_menu.tscn` - Menú Principal
Pantalla de inicio con título decorativo, figuras geométricas de fondo y botones de Play. Muestra `Last Score` y `Record`.

### `game.tscn` - Escena de Juego
Contiene el área de juego con fondo, GameManager, InputManager, Player (Area2D), HUD con ScoreLabel, LivesLabel, GameOverPanel, FlashRect, ScoreManager y UIManager.

### `falling_item.tscn` - Forma que Cae
Escena instanciable de Area2D con CollisionShape2D. Contiene los parámetros `fall_speed` y `shape_size`.

---

## Scripts

### `scripts/shape_type.gd`
Constantes y utilidades de las formas geométricas.

| Método | Parámetros | Retorna | Descripción |
|---|---|---|---|
| `get_color()` | `shape_type: int` | `Color` | Devuelve el color: amarillo (triángulo), rojo (círculo), azul (cuadrado) |
| `get_name()` | `shape_type: int` | `String` | Devuelve el nombre en inglés de la forma |

**Formas:**
- `TRIANGLE = 0` - Triángulo amarillo
- `CIRCLE = 1` - Círculo rojo
- `SQUARE = 2` - Cuadrado azul

---

### `scripts/shape_renderer.gd`
Crea nodos con figuras geométricas visuales (polígono + borde).

| Método | Parámetros | Retorna | Descripción |
|---|---|---|---|
| `create_shape_node()` | `shape_type: int, size: float` | `Node2D` | Crea y devuelve un nodo con la forma visual correspondiente |
| `build_triangle()` | `node: Node2D, size: float, color: Color` | `void` | Añade polígono triangular y borde al nodo |
| `build_circle()` | `node: Node2D, size: float, color: Color` | `void` | Añade polígono circular (32 segmentos) y borde al nodo |
| `build_square()` | `node: Node2D, size: float, color: Color` | `void` | Añade polígono cuadrado y borde al nodo |

---

### `scripts/falling_item.gd` (`FallingShape`)
Controla cada forma que cae. Extiende `Area2D`.

| Propiedad | Tipo | Valor por defecto | Descripción |
|---|---|---|---|
| `fall_speed` | `float` | 200.0 | Velocidad de caída en píxeles/segundo |
| `shape_size` | `float` | 100.0 | Tamaño de la forma en píxeles |
| `shape_type` | `int` | Aleatorio | Tipo de forma (0-2) |
| `is_falling` | `bool` | `true` | Estado de movimiento |
| `screen_height` | `float` | - | Altura del viewport |

| Señal | Parámetros | Descripción |
|---|---|---|
| `shape_reached_bottom` | `shape: int` | Se emite cuando la forma sale de la pantalla |

| Método | Descripción |
|---|---|
| `_ready()` | Registra al grupo "falling_shapes", asigna forma aleatoria, crea visual |
| `_process(delta)` | Mueve la forma hacia abajo, emite señal si sale de pantalla |
| `setup_visual()` | Crea el polígono visual y configura el CollisionShape2D |
| `get_shape_type()` | Retorna el tipo de forma actual |

---

### `scripts/player_controller.gd` (`PlayerShape`)
Controla la forma del jugador en la parte inferior. Extiende `Area2D`.

| Propiedad | Tipo | Valor por defecto | Descripción |
|---|---|---|---|
| `shape_size` | `float` | 140.0 | Tamaño de la forma del jugador |
| `screen_bottom_offset` | `float` | 150 | Distancia desde el borde inferior |
| `current_shape` | `int` | TRIANGLE (0) | Forma actual del jugador |

| Señal | Parámetros | Descripción |
|---|---|---|
| `shape_changed` | `new_shape: int` | Se emite al cambiar de forma |
| `shape_collision` | `player_shape: int, falling_shape: int` | Se emite al colisionar con una forma que cae |

| Método | Descripción |
|---|---|
| `_ready()` | Posiciona al jugador en el centro inferior, conecta input y colisiones |
| `_process()` | Detecta teclado (acciones `move_left`/`move_right`) |
| `setup_visual()` | Regenera el polígono visual y colisión para la forma actual |
| `_on_touch_left()` | Cambia a la forma anterior en el ciclo (ciclo: ←) |
| `_on_touch_right()` | Cambia a la forma siguiente en el ciclo (ciclo: →) |
| `change_shape()` | Actualiza forma, regenera visual y emite señal |
| `_on_area_entered()` | Detecta colisión con formas que caen y emite `shape_collision` |
| `get_current_shape()` | Retorna la forma actual del jugador |

---

### `scripts/game_manager.gd` (`GameManager`)
Control central del juego: spawns, puntuación, vidas, dificultad, game over.

| Propiedad | Tipo | Valor | Descripción |
|---|---|---|---|
| `initial_spawn_interval` | `float` | 2.0 | Segundos entre apariciones (inicial) |
| `spawn_interval_decrease` | `float` | 0.1 | Reducción de intervalo cada 5 puntos (segundos) |
| `spawn_height` | `float` | -150 | Posición Y donde aparecen las formas |
| `max_lives` | `int` | 3 | Vidas máximas del jugador |
| `current_score` | `int` | 0 | Puntuación actual |
| `current_lives` | `int` | `max_lives` | Vidas actuales |
| `game_over` | `bool` | `false` | Estado de fin de juego |
| `falling_shapes` | `Array` | `[]` | Referencias a formas activas |

| Método | Descripción |
|---|---|
| `get_spawn_interval()` | Calcula intervalo actual: `max(0.5, 2.0 - (score/5 * 0.1))` |
| `get_speed_multiplier()` | Calcula multiplicador de velocidad: `1.0 + (score/5 * 0.1)` (+10% cada 5 pts) |
| `spawn_shape()` | Crea nueva forma, aplica velocidad escalada, conecta señal de fondo |
| `update_falling_shapes()` | Limpia referencias a formas que ya no existen |
| `_on_player_shape_collision()` | Compara formas: si coinciden +1 punto, si no -1 vida |
| `trigger_match_effect()` | Flash verde y efecto visual al acertar |
| `trigger_miss_effect()` | Flash rojo y efecto visual al fallar |
| `_on_shape_reached_bottom()` | -1 vida cuando una forma sale de pantalla sin colisionar |
| `end_game()` | Marca game over, guarda puntuación, muestra panel |
| `reset_game()` | Reinicia estado: vidas, score, timer, limpia formas activas |
| `get_current_score()` | Retorna puntuación actual |
| `get_current_lives()` | Retorna vidas actuales |

---

### `scripts/input_manager.gd`
Maneja input táctil (Android) y teclado (PC).

| Señal | Descripción |
|---|---|
| `touch_left` | Se emite al tocar lado izquierdo o tecla A/← |
| `touch_right` | Se emite al tocar lado derecho o tecla D/→ |

| Método | Descripción |
|---|---|
| `_input(event)` | Detecta InputEventKey y InputEventScreenTouch/Drag |
| `handle_touch_down()` | Determina lado de pantalla y emite señal correspondiente |
| `handle_touch_drag()` | Igual que touch_down pero durante arrastre |

---

### `scripts/score_manager.gd` (`ScoreManager`)
Persistencia y gestión de puntuaciones en JSON.

| Propiedad | Tipo | Descripción |
|---|---|---|
| `current_score` | `int` | Puntuación de la partida actual |
| `high_score` | `int` | Mejor puntuación guardada |
| `last_score` | `int` | Última puntuación jugada |
| `save_file_path` | `String` | `user://falling_game_data.json` |

| Señal | Parámetros | Descripción |
|---|---|---|
| `score_changed` | `new_score: int` | Cuando cambia la puntuación |
| `high_score_updated` | `new_high_score: int` | Cuando se supera el récord |
| `last_score_loaded` | `last_score: int` | Al cargar última puntuación |

| Método | Descripción |
|---|---|
| `_ready()` | Carga puntuaciones guardadas |
| `add_score()` | Suma puntos y emite `score_changed` |
| `save_last_score()` | Guarda última puntuación, actualiza récord si corresponde |
| `save_scores()` | Escribe datos como JSON en disco |
| `load_scores()` | Lee y parsea JSON del archivo guardado |
| `reset_current_score()` | Resetea puntuación actual a 0 |
| `get_high_score()` | Retorna mejor puntuación |
| `get_last_score()` | Retorna última puntuación |
| `get_current_score()` | Retorna puntuación actual |

---

### `scripts/ui_manager.gd` (`UIManager`)
Actualiza la interfaz visual del HUD.

| Método | Parámetros | Descripción |
|---|---|---|
| `_ready()` | - | Conecta botones, oculta panel de game over, inicializa labels |
| `update_score()` | `score: int` | Actualiza texto de `ScoreLabel` |
| `update_lives()` | `lives: int` | Actualiza texto de `LivesLabel` con corazones |
| `show_game_over()` | `final_score: int` | Muestra panel, actualiza `LastScoreLabel` |
| `_on_restart_pressed()` | - | Oculta panel y reinicia juego vía GameManager |
| `_on_menu_pressed()` | - | Cambia escena a menú principal |

---

### `scenes/main_menu.gd`
Controla el menú principal con figuras decorativas y puntuaciones.

| Método | Descripción |
|---|---|
| `_ready()` | Crea figuras decorativas, carga scores, conecta botón Play |
| `_create_decorative_shape()` | Crea una forma semi-transparente de fondo (triángulo, círculo o cuadrado) |
| `_add_triangle()` | Crea polígono + borde de triángulo decorativo |
| `_add_circle()` | Crea polígono + borde de círculo decorativo (32 segmentos) |
| `_add_square()` | Crea polígono + borde de cuadrado decorativo |
| `load_scores()` | Carga y muestra `Last Score` y `Record` desde JSON |
| `_on_play_pressed()` | Cambia escena a `game.tscn` |

---

## Flujo del Juego

```
main_menu.tscn
  │
  ├─ Muestra Last Score y Record (desde JSON)
  ├─ Figuras decorativas de fondo
  └─ Botón Play → game.tscn

game.tscn
  │
  ├─ GameManager: spawnea formas cada intervalo
  ├─ InputManager: detecta toque izquierda/derecha
  ├─ Player: cambia forma cíclicamente ← △ ○ □ →
  ├─ Colisión:
  │   ├─ Formas coinciden → +1 punto, flash verde
  │   └─ Formas distintas → -1 vida, flash rojo
  ├─ Forma sale de pantalla → -1 vida
  ├─ Cada 5 puntos: velocidad +10%, spawn -100ms
  └─ Vidas = 0 → Game Over, guarda score → RESTART o MENU
```

---

## Dificultad Progresiva

| Puntuación | Velocidad | Intervalo de Spawn |
|---|---|---|
| 0 | 200 px/s (100%) | 2.0 s |
| 5 | 220 px/s (+10%) | 1.9 s |
| 10 | 240 px/s (+20%) | 1.8 s |
| 15 | 260 px/s (+30%) | 1.7 s |
| 20 | 280 px/s (+40%) | 1.6 s |
| ... | ... | ... (mínimo 0.5s) |
