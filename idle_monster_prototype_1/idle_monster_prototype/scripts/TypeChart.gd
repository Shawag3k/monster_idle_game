extends Node
# Autoload singleton - acessível globalmente como "TypeChart"
# Implementa a tabela de vantagens de tipo definida no Game Design Document.

var strong_against = {
	"Fogo": ["Planta", "Gelo"],
	"Agua": ["Fogo", "Terra"],
	"Planta": ["Agua", "Terra"],
	"Terra": ["Fogo", "Eletrico"],
	"Voador": ["Planta", "Terra"],
	"Eletrico": ["Agua", "Voador"],
	"Gelo": ["Voador", "Planta"],
}

var all_types = ["Fogo", "Agua", "Planta", "Terra", "Voador", "Eletrico", "Gelo"]

# Cores usadas pra desenhar as criaturas sem precisar de arte ainda.
var type_colors = {
	"Fogo": Color(0.9, 0.2, 0.15),
	"Agua": Color(0.2, 0.45, 0.95),
	"Planta": Color(0.25, 0.75, 0.3),
	"Terra": Color(0.55, 0.35, 0.15),
	"Voador": Color(0.6, 0.85, 1.0),
	"Eletrico": Color(0.95, 0.9, 0.15),
	"Gelo": Color(0.75, 0.95, 1.0),
	"Normal": Color(0.6, 0.6, 0.6),
}

func get_multiplier(attacker_type: String, defender_type: String) -> float:
	# Tipo Normal nunca tem vantagem nem desvantagem, em nenhuma direção.
	if attacker_type == "Normal" or defender_type == "Normal":
		return 1.0
	if strong_against.has(attacker_type) and strong_against[attacker_type].has(defender_type):
		return 1.5
	if strong_against.has(defender_type) and strong_against[defender_type].has(attacker_type):
		return 0.5
	return 1.0

func random_type() -> String:
	return all_types[randi() % all_types.size()]
