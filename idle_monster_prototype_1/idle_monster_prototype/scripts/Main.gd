extends Node2D

@onready var player: Player = $Player
@onready var enemies_container: Node2D = $EnemiesContainer
@onready var projectiles_container: Node2D = $ProjectilesContainer
@onready var wave_manager: WaveManager = $WaveManager
@onready var ui = $CanvasLayer/UI
@onready var btn_map_during_combat: Button = $CanvasLayer/UI/BtnMapDuringCombat
@onready var starter_layer: CanvasLayer = $StarterLayer
@onready var btn_agua: Button = $StarterLayer/StarterPanel/VBox/HBox/BtnAgua
@onready var btn_planta: Button = $StarterLayer/StarterPanel/VBox/HBox/BtnPlanta
@onready var btn_fogo: Button = $StarterLayer/StarterPanel/VBox/HBox/BtnFogo
@onready var map_layer: CanvasLayer = $MapLayer
@onready var map_select: MapSelect = $MapLayer/MapSelect
@onready var phase_cleared_layer: CanvasLayer = $PhaseClearedLayer
@onready var phase_cleared_label: Label = $PhaseClearedLayer/Panel/VBox/ResultLabel
@onready var btn_next_phase: Button = $PhaseClearedLayer/Panel/VBox/HBox/BtnNext
@onready var btn_back_to_map: Button = $PhaseClearedLayer/Panel/VBox/HBox/BtnMap

var _capture_key_was_down: bool = false
var _game_started: bool = false

func _ready():
	player.enemies_container = enemies_container
	player.projectiles_container = projectiles_container
	wave_manager.enemies_container = enemies_container
	wave_manager.player = player
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.phase_cleared.connect(_on_phase_cleared)
	player.leveled_up.connect(_on_player_leveled_up)

	btn_agua.pressed.connect(func(): _on_starter_chosen("Agua"))
	btn_planta.pressed.connect(func(): _on_starter_chosen("Planta"))
	btn_fogo.pressed.connect(func(): _on_starter_chosen("Fogo"))

	map_select.phase_chosen.connect(_on_phase_chosen)
	btn_next_phase.pressed.connect(_on_next_phase_pressed)
	btn_back_to_map.pressed.connect(_open_map_select)
	btn_map_during_combat.pressed.connect(_open_map_select)

	map_layer.visible = false
	phase_cleared_layer.visible = false
	# Jogo fica parado (sem ondas) até o jogador escolher o inicial

func _on_starter_chosen(type: String):
	player.configure_starter(type)
	starter_layer.visible = false
	ui.log_message("Você escolheu o inicial do tipo %s!" % type)
	_open_map_select()

func _open_map_select():
	_game_started = false
	wave_manager.stop()
	_clear_enemies()
	_clear_projectiles()
	phase_cleared_layer.visible = false
	map_layer.visible = true
	map_select.open(ProgressManager.current_world, ProgressManager.current_map)

func _clear_enemies():
	for e in enemies_container.get_children():
		e.queue_free()

func _clear_projectiles():
	for p in projectiles_container.get_children():
		p.queue_free()

func _on_phase_chosen(world: int, map: int, phase: int):
	ProgressManager.select_phase(world, map, phase)
	map_layer.visible = false
	player.hp = player.max_hp
	_game_started = true
	ui.set_phase_info(world, map, phase)
	ui.log_message("Mundo %d, Mapa %d, Fase %d começou!" % [world, map, phase])
	wave_manager.start_phase(world, map, phase)

func _on_player_leveled_up(new_level: int):
	ui.log_message("Subiu para o nível %d!" % new_level)

func _on_wave_started(n):
	ui.set_wave(n, wave_manager.total_waves)
	ui.log_message("Onda %d começou!" % n)

func _on_phase_cleared():
	_game_started = false
	ProgressManager.mark_current_phase_complete()
	phase_cleared_label.text = "Fase concluída! Mundo %d - Mapa %d - Fase %d" % [
		ProgressManager.current_world, ProgressManager.current_map, ProgressManager.current_phase
	]
	var next = ProgressManager.next_phase_target()
	btn_next_phase.visible = not next.is_empty()
	phase_cleared_layer.visible = true

func _on_next_phase_pressed():
	var next = ProgressManager.next_phase_target()
	if next.is_empty():
		return
	phase_cleared_layer.visible = false
	_on_phase_chosen(next["world"], next["map"], next["phase"])

func _on_player_defeated():
	_game_started = false
	wave_manager.stop()
	_clear_enemies()
	_clear_projectiles()
	player.hp = player.max_hp
	ui.log_message("Você foi derrotado! Voltando ao mapa...")
	_open_map_select()

func _process(_delta):
	if not _game_started:
		return
	ui.set_player_hp(player.hp, player.max_hp)

	# Remove inimigos mortos (versão simples, sem sinal dedicado)
	for e in enemies_container.get_children():
		if e.hp <= 0.0:
			e.queue_free()

	if player.hp <= 0.0:
		_on_player_defeated()
		return

	# Captura manual: tecla C, debounce manual (sem precisar configurar Input Map)
	var capture_down = Input.is_physical_key_pressed(KEY_C)
	if capture_down and not _capture_key_was_down:
		_try_capture_nearest()
	_capture_key_was_down = capture_down

func _try_capture_nearest():
	var nearest = null
	var nearest_dist = INF
	for e in enemies_container.get_children():
		if not e.is_capturable():
			continue
		var d = player.global_position.distance_to(e.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = e
	if nearest == null:
		ui.log_message("Nenhum alvo capturável (precisa estar abaixo de 30% de HP)")
		return
	if nearest.try_capture():
		ui.log_message("Capturou um %s (%s)!" % [nearest.creature_type, nearest.rarity])
		nearest.queue_free()
	else:
		ui.log_message("Captura de %s (%s) falhou..." % [nearest.creature_type, nearest.rarity])
