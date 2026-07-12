extends Node2D
class_name Projectile
# Bolinha que viaja até o alvo e aplica dano no impacto - usada pelos ataques
# à distância dos monstrinhos aliados (básico e "poder").

@onready var visual: ShapeDraw = $Visual

var target: Node2D
var shooter: Node = null
var dmg: float = 0.0
var attacker_type: String = "Normal"
var speed: float = 340.0
var hit_distance: float = 10.0

func configure(p_target: Node2D, p_dmg: float, p_type: String, is_power: bool = false):
	target = p_target
	dmg = p_dmg
	attacker_type = p_type
	visual.size = 12.0 if is_power else 6.0
	visual.set_shape_color(TypeChart.type_colors.get(p_type, Color.WHITE))

func _process(delta):
	if target == null or not is_instance_valid(target) or target.hp <= 0.0:
		queue_free()
		return
	var to_target = target.global_position - global_position
	if to_target.length() <= hit_distance:
		target.take_damage(dmg, attacker_type)
		if target.hp <= 0.0 and shooter != null and shooter.has_method("_on_projectile_kill"):
			shooter._on_projectile_kill(target)
		queue_free()
		return
	global_position += to_target.normalized() * speed * delta
