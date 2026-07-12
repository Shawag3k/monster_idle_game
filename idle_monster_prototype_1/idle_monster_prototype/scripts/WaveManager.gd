extends Node
class_name WaveManager
# Executa as ondas de uma fase (Mundo -> Mapa -> Fase, seção 4 do documento).
# Simplificação de protótipo: cada onda spawna poucas unidades (enemies_per_wave),
# não os 20 inimigos por onda do design final - ver README.

@export var enemies_per_wave: int = 4
@export var enemy_scene: PackedScene = preload("res://scenes/Enemy.tscn")

var current_wave: int = 0
var total_waves: int = 5
var enemies_container: Node2D
var player: Node2D
var _finished: bool = true

var world: int = 1
var map: int = 1
var phase: int = 1
var _biome: Dictionary = {}

signal wave_started(wave_number)
signal phase_cleared()

func start_phase(p_world: int, p_map: int, p_phase: int):
	world = p_world
	map = p_map
	phase = p_phase
	_biome = GameData.biome_for_map(map)
	total_waves = GameData.waves_per_phase(world)
	current_wave = 0
	_finished = false
	_spawn_next_wave()

func stop():
	_finished = true
	current_wave = 0

func _process(_delta):
	if _finished or enemies_container == null or player == null:
		return
	if current_wave > 0 and enemies_container.get_child_count() == 0:
		if current_wave >= total_waves:
			_finished = true
			phase_cleared.emit()
		else:
			_spawn_next_wave()

func _spawn_next_wave():
	current_wave += 1
	wave_started.emit(current_wave)
	var is_last_wave = current_wave == total_waves
	var is_map_boss = is_last_wave and phase == GameData.PHASES_PER_MAP
	var count = 1 if is_last_wave else enemies_per_wave
	for i in range(count):
		var enemy: Enemy = enemy_scene.instantiate()
		var angle = randf() * TAU
		var dist = 260.0
		enemy.global_position = player.global_position + Vector2(cos(angle), sin(angle)) * dist
		enemy.target = player
		if current_wave <= 3 and world == 1:
			enemy.creature_type = "Normal"  # ondas iniciais do Mundo 1 (Fácil): só tipo Normal
		else:
			enemy.creature_type = _roll_biome_type()
		if is_last_wave:
			# Mini-boss (todas as fases) ou Boss de Mapa (fase 10) - seção 4.
			# Raridade de captura tratada como "Raro" fixo em ambos os casos;
			# só o multiplicador de stats muda (1.8x mini-boss, 5x boss de mapa).
			enemy.rarity = "Raro"
			var mult = 5.0 if is_map_boss else 1.8
			enemy.max_hp *= mult
			enemy.dmg *= mult
		else:
			enemy.rarity = _roll_rarity()
		enemies_container.add_child(enemy)

func _roll_biome_type() -> String:
	# Criaturas do bioma do mapa aparecem com mais frequência (seções 4 e 12),
	# mas outros tipos ainda podem surgir pra variar o combate.
	if not _biome.is_empty() and randf() < 0.6:
		var types: Array = _biome["types"]
		return types[randi() % types.size()]
	return TypeChart.random_type()

func _roll_rarity() -> String:
	# Segue a tabela de chance de aparição do Game Design Document (seção 7.1)
	var r = randf() * 100.0
	if r < 59.0:
		return "Comum"
	elif r < 84.0:
		return "Raro"
	elif r < 94.0:
		return "Epico"
	elif r < 99.0:
		return "Mitico"
	else:
		return "Lendario"
