extends Node
# Autoload singleton "GameData"
# Dados estáticos da estrutura de progressão do Game Design Document (seção 4 e 12).

const MAPS_PER_WORLD := 5
const PHASES_PER_MAP := 10
# Mundos 1-4 têm nome de dificuldade definido no documento; a fórmula de ondas
# por fase é genérica e funciona além disso, mas o protótipo só libera até o 4.
const NUM_WORLDS := 4

const WORLD_DIFFICULTY_NAMES := {
	1: "Fácil",
	2: "Normal",
	3: "Difícil",
	4: "Muito Difícil",
}

# 6 biomas confirmados (seção 12), ciclados entre os 5 mapas de cada mundo.
const BIOMES := [
	{"name": "Floresta", "types": ["Planta"]},
	{"name": "Vulcão", "types": ["Fogo"]},
	{"name": "Deserto", "types": ["Terra"]},
	{"name": "Tundra", "types": ["Gelo"]},
	{"name": "Costa", "types": ["Agua"]},
	{"name": "Planaltos/Cavernas", "types": ["Terra", "Voador"]},
]

func waves_per_phase(world: int) -> int:
	# Ondas_por_fase(mundo) = 5 x mundo
	return 5 * world

func world_difficulty_name(world: int) -> String:
	return WORLD_DIFFICULTY_NAMES.get(world, "Mundo %d" % world)

func biome_for_map(map_index: int) -> Dictionary:
	# map_index é 1-based; cicla pelos biomas confirmados (seção 12).
	return BIOMES[(map_index - 1) % BIOMES.size()]
