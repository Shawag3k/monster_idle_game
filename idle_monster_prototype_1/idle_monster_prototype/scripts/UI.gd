extends Control

@onready var phase_label: Label = $VBoxContainer/PhaseLabel
@onready var wave_label: Label = $VBoxContainer/WaveLabel
@onready var hp_label: Label = $VBoxContainer/HPLabel
@onready var help_label: Label = $VBoxContainer/HelpLabel
@onready var log_label: Label = $VBoxContainer/LogLabel

func _ready():
	help_label.text = "Pressione C para tentar capturar o inimigo mais próximo com HP abaixo de 30%"
	log_label.text = ""

func set_phase_info(world: int, map: int, phase: int):
	var phase_name = "Boss (Fase %d)" % phase if phase == GameData.PHASES_PER_MAP else "Fase %d" % phase
	phase_label.text = "Mundo %d (%s) - Mapa %d - %s" % [world, GameData.world_difficulty_name(world), map, phase_name]

func set_wave(current: int, total: int):
	wave_label.text = "Onda: %d / %d" % [current, total]

func set_player_hp(hp: float, max_hp: float):
	hp_label.text = "HP do Jogador: %d / %d" % [int(hp), int(max_hp)]

func log_message(msg: String):
	log_label.text = msg
