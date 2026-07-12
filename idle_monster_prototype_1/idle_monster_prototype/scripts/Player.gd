extends Creature
class_name Player

var enemies_container: Node2D
var projectiles_container: Node2D

@onready var hp_bar: ProgressBar = $HPBar
@onready var energy_bar: ProgressBar = $EnergyBar
@onready var xp_bar: ProgressBar = $XPBar

@export var projectile_scene: PackedScene = preload("res://scenes/Projectile.tscn")
@export var projectile_speed: float = 340.0

# Barra de energia: carrega com os ataques básicos e, ao encher, dispara um
# "poder" (bola do elemento do monstro, dano maior) - ver Projectile.gd.
const ENERGY_MAX := 100.0
@export var energy_per_attack: float = 25.0
const POWER_DAMAGE_MULT := 3.0
var energy: float = 0.0

var level: int = 1
var xp: float = 0.0
var xp_to_next_level: float = 50.0

# Crescimento por nível (seção 5.3) - valores placeholder, ajustar em playtest.
var _max_hp_growth: float = 8.0
var _dmg_growth: float = 1.2
var _def_growth: float = 0.6
var _atk_speed_growth: float = 0.02

# Recompensa de XP por abate (não definida no documento ainda) - placeholder,
# escalada pela mesma raridade usada na chance de captura (seção 7.1).
const XP_RARITY_MULT = {
	"Comum": 1.0,
	"Raro": 1.5,
	"Epico": 2.25,
	"Mitico": 3.5,
	"Lendario": 5.0,
}
const BASE_XP_PER_KILL := 8.0

signal leveled_up(new_level)

func _ready():
	super._ready()
	# Valores padrão até o jogador escolher o inicial na tela de seleção
	creature_type = "Fogo"
	max_hp = 100.0
	hp = max_hp
	dmg = 12.0
	def = 5.0
	atk_speed = 1.2
	attack_range = 90.0
	_update_visual()
	_update_xp_requirement()

func configure_starter(type: String):
	creature_type = type
	match type:
		"Agua":
			max_hp = 120.0
			dmg = 10.0
			def = 7.0
			atk_speed = 1.0
		"Planta":
			max_hp = 100.0
			dmg = 11.0
			def = 5.0
			atk_speed = 1.1
		"Fogo":
			max_hp = 90.0
			dmg = 14.0
			def = 4.0
			atk_speed = 1.2
	hp = max_hp
	_update_visual()

func _update_visual():
	if has_node("Visual"):
		$Visual.set_shape_color(TypeChart.type_colors.get(creature_type, Color.WHITE))

func _process(delta):
	super._process(delta)
	_update_bars()
	if not can_attack() or enemies_container == null:
		return
	var target = _find_nearest_enemy()
	if target and global_position.distance_to(target.global_position) <= attack_range:
		_fire_basic_attack(target)
		reset_cooldown()

func _fire_basic_attack(target: Node2D):
	_spawn_projectile(target, dmg, false)
	energy += energy_per_attack
	if energy >= ENERGY_MAX:
		energy -= ENERGY_MAX
		_spawn_projectile(target, dmg * POWER_DAMAGE_MULT, true)

func _spawn_projectile(target: Node2D, amount: float, is_power: bool):
	if projectiles_container == null or projectile_scene == null:
		return
	var proj: Projectile = projectile_scene.instantiate()
	proj.speed = projectile_speed * (1.4 if is_power else 1.0)
	proj.shooter = self
	projectiles_container.add_child(proj)
	proj.global_position = global_position
	proj.configure(target, amount, creature_type, is_power)

func _on_projectile_kill(enemy):
	gain_xp(BASE_XP_PER_KILL * XP_RARITY_MULT.get(enemy.rarity, 1.0))

func _update_bars():
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	energy_bar.max_value = ENERGY_MAX
	energy_bar.value = energy
	xp_bar.max_value = xp_to_next_level
	xp_bar.value = xp

func _update_xp_requirement():
	# XP_necessário(nível) = 50 x nível^1.5 (seção 5.4)
	xp_to_next_level = 50.0 * pow(level, 1.5)

func gain_xp(amount: float):
	xp += amount
	while xp >= xp_to_next_level:
		xp -= xp_to_next_level
		_level_up()

func _level_up():
	level += 1
	# Atributo_atual(nível) = Atributo_base + Atributo_growth x (nível - 1) (seção 5.3)
	max_hp += _max_hp_growth
	dmg += _dmg_growth
	def += _def_growth
	atk_speed += _atk_speed_growth
	hp = max_hp
	_update_xp_requirement()
	leveled_up.emit(level)

func _find_nearest_enemy() -> Node2D:
	var nearest = null
	var nearest_dist = INF
	for e in enemies_container.get_children():
		if e.hp <= 0.0:
			continue
		var d = global_position.distance_to(e.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = e
	return nearest
