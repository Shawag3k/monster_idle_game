extends Control
class_name MapSelect
# Tela de seleção de Mundo -> Mapa -> Fase (seção 4 do documento).
# Os botões de mapa/fase já existem na cena (5 mapas, 10 fases) - aqui só
# atualizamos texto/estado de bloqueio e emitimos qual fase o jogador escolheu.

signal phase_chosen(world: int, map: int, phase: int)

@onready var world_label: Label = $Panel/VBox/Header/WorldLabel
@onready var prev_btn: Button = $Panel/VBox/Header/PrevBtn
@onready var next_btn: Button = $Panel/VBox/Header/NextBtn
@onready var biome_label: Label = $Panel/VBox/BiomeLabel
@onready var maps_box: HBoxContainer = $Panel/VBox/MapsBox
@onready var phases_grid: GridContainer = $Panel/VBox/PhasesGrid

var _viewing_world: int = 1
var _selected_map: int = 1
var _map_buttons: Array = []
var _phase_buttons: Array = []

func _ready():
	prev_btn.pressed.connect(_on_prev_world)
	next_btn.pressed.connect(_on_next_world)

	for child in maps_box.get_children():
		_map_buttons.append(child)
	for child in phases_grid.get_children():
		_phase_buttons.append(child)

	for i in range(_map_buttons.size()):
		var map_index = i + 1
		_map_buttons[i].pressed.connect(_on_map_selected.bind(map_index))
	for i in range(_phase_buttons.size()):
		var phase_index = i + 1
		_phase_buttons[i].pressed.connect(_on_phase_selected.bind(phase_index))

func open(focus_world: int, focus_map: int):
	_viewing_world = focus_world
	_selected_map = focus_map
	visible = true
	refresh()

func _on_prev_world():
	if _viewing_world > 1:
		_viewing_world -= 1
		_selected_map = 1
		refresh()

func _on_next_world():
	if _viewing_world < GameData.NUM_WORLDS and ProgressManager.is_world_unlocked(_viewing_world + 1):
		_viewing_world += 1
		_selected_map = 1
		refresh()

func _on_map_selected(map: int):
	if not ProgressManager.is_map_unlocked(_viewing_world, map):
		return
	_selected_map = map
	refresh()

func _on_phase_selected(phase: int):
	if not ProgressManager.is_phase_unlocked(_viewing_world, _selected_map, phase):
		return
	phase_chosen.emit(_viewing_world, _selected_map, phase)

func refresh():
	world_label.text = "Mundo %d - %s" % [_viewing_world, GameData.world_difficulty_name(_viewing_world)]
	prev_btn.disabled = _viewing_world <= 1
	next_btn.disabled = not (_viewing_world < GameData.NUM_WORLDS and ProgressManager.is_world_unlocked(_viewing_world + 1))

	for i in range(_map_buttons.size()):
		var map_index = i + 1
		var unlocked = ProgressManager.is_map_unlocked(_viewing_world, map_index)
		var biome = GameData.biome_for_map(map_index)
		_map_buttons[i].text = ("Mapa %d\n%s" % [map_index, biome["name"]]) if unlocked else ("Mapa %d\n[bloqueado]" % map_index)
		_map_buttons[i].disabled = not unlocked

	var selected_biome = GameData.biome_for_map(_selected_map)
	var type_list: String = ", ".join(PackedStringArray(selected_biome["types"]))
	biome_label.text = "Bioma do Mapa %d: %s (tipos dominantes: %s)" % [_selected_map, selected_biome["name"], type_list]

	for i in range(_phase_buttons.size()):
		var phase_index = i + 1
		var unlocked = ProgressManager.is_phase_unlocked(_viewing_world, _selected_map, phase_index)
		var label = "Boss" if phase_index == GameData.PHASES_PER_MAP else str(phase_index)
		_phase_buttons[i].text = label if unlocked else "-"
		_phase_buttons[i].disabled = not unlocked
