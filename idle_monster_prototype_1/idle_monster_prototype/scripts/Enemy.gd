extends Creature
class_name Enemy

@export var rarity: String = "Comum"
@export var move_speed: float = 40.0

var target: Node2D = null

func _ready():
	super._ready()
	_update_visual()

func _update_visual():
	if has_node("Visual"):
		$Visual.set_shape_color(TypeChart.type_colors.get(creature_type, Color.WHITE))

# Chances de captura definidas no Game Design Document (seção 6)
const CAPTURE_CHANCES = {
	"Comum": 0.50,
	"Raro": 0.25,
	"Epico": 0.10,
	"Mitico": 0.05,
	"Lendario": 0.01,
}

func _process(delta):
	super._process(delta)
	if has_node("HPBar"):
		$HPBar.max_value = max_hp
		$HPBar.value = hp
	if target == null or hp <= 0.0:
		return
	var dist = global_position.distance_to(target.global_position)
	if dist > attack_range:
		var dir = (target.global_position - global_position).normalized()
		global_position += dir * move_speed * delta
	elif can_attack():
		target.take_damage(dmg, creature_type)
		reset_cooldown()

func is_capturable() -> bool:
	return hp > 0.0 and hp <= max_hp * 0.3

func try_capture() -> bool:
	var chance = CAPTURE_CHANCES.get(rarity, 0.5)
	return randf() <= chance
