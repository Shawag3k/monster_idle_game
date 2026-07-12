extends Node2D
class_name Creature
# Base compartilhada por Player e Enemy.
# Implementa as fórmulas de combate do Game Design Document (seção 5).

@export var max_hp: float = 50.0
@export var dmg: float = 10.0
@export var def: float = 5.0
@export var atk_speed: float = 1.0  # ataques por segundo
@export var creature_type: String = "Fogo"
@export var attack_range: float = 80.0

var hp: float
var _cooldown: float = 0.0

func _ready():
	hp = max_hp

func _process(delta):
	if _cooldown > 0.0:
		_cooldown -= delta

func can_attack() -> bool:
	return _cooldown <= 0.0

func reset_cooldown():
	# Cooldown_ataque = 1 / Velocidade_Ataque
	_cooldown = 1.0 / max(atk_speed, 0.01)

func take_damage(raw_dmg: float, attacker_type: String) -> float:
	# Dano_golpe = max(1, (DMG_atacante - DEF_alvo * 0.5)) * Multiplicador_tipo * Variancia
	var mult = TypeChart.get_multiplier(attacker_type, creature_type)
	var variance = randf_range(0.9, 1.0)
	var final_dmg = max(1.0, (raw_dmg - def * 0.5)) * mult * variance
	hp -= final_dmg
	if hp < 0.0:
		hp = 0.0
	return final_dmg
