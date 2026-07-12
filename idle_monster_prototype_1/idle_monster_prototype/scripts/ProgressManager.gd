extends Node
# Autoload singleton "ProgressManager"
# Controla mundo/mapa/fase atual e o estado de desbloqueio (seção 4 do documento):
# completar a fase 10 (boss) de um mapa libera o próximo mapa; completar os 5
# mapas de um mundo libera o próximo mundo.
#
# Nota: progresso vive só em memória por enquanto (reinicia a cada sessão do
# jogo) - persistir em disco é uma próxima iteração.

var current_world: int = 1
var current_map: int = 1
var current_phase: int = 1

var highest_unlocked_world: int = 1
var _highest_unlocked_map: Dictionary = {1: 1}
var _highest_unlocked_phase: Dictionary = {"1_1": 1}

func _key(world: int, map: int) -> String:
	return "%d_%d" % [world, map]

func is_world_unlocked(world: int) -> bool:
	return world <= highest_unlocked_world

func is_map_unlocked(world: int, map: int) -> bool:
	if not is_world_unlocked(world):
		return false
	return map <= _highest_unlocked_map.get(world, 0)

func is_phase_unlocked(world: int, map: int, phase: int) -> bool:
	if not is_map_unlocked(world, map):
		return false
	return phase <= _highest_unlocked_phase.get(_key(world, map), 0)

func select_phase(world: int, map: int, phase: int):
	current_world = world
	current_map = map
	current_phase = phase

func mark_current_phase_complete():
	var world = current_world
	var map = current_map
	var phase = current_phase
	var k = _key(world, map)
	if phase < _highest_unlocked_phase.get(k, 0):
		return  # fase já tinha sido concluída antes, nada novo a desbloquear

	if phase < GameData.PHASES_PER_MAP:
		_highest_unlocked_phase[k] = phase + 1
		return

	# Completou a fase 10 (Boss de Mapa) -> libera o próximo mapa do mundo atual
	if map < GameData.MAPS_PER_WORLD:
		var next_map = map + 1
		_highest_unlocked_map[world] = max(_highest_unlocked_map.get(world, 0), next_map)
		var next_key = _key(world, next_map)
		_highest_unlocked_phase[next_key] = max(_highest_unlocked_phase.get(next_key, 0), 1)
		return

	# Completou os 5 mapas do mundo -> libera o próximo mundo
	if world < GameData.NUM_WORLDS:
		highest_unlocked_world = max(highest_unlocked_world, world + 1)
		_highest_unlocked_map[world + 1] = max(_highest_unlocked_map.get(world + 1, 0), 1)
		var first_key = _key(world + 1, 1)
		_highest_unlocked_phase[first_key] = max(_highest_unlocked_phase.get(first_key, 0), 1)

func next_phase_target() -> Dictionary:
	# Próximo mundo/mapa/fase lógico após a fase atual, pro botão "Próxima Fase".
	# Retorna {} se não houver mais conteúdo desbloqueável depois (fim do protótipo).
	var world = current_world
	var map = current_map
	var phase = current_phase
	if phase < GameData.PHASES_PER_MAP:
		return {"world": world, "map": map, "phase": phase + 1}
	elif map < GameData.MAPS_PER_WORLD:
		return {"world": world, "map": map + 1, "phase": 1}
	elif world < GameData.NUM_WORLDS:
		return {"world": world + 1, "map": 1, "phase": 1}
	return {}
