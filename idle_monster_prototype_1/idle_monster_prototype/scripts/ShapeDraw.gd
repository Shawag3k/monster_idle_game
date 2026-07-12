extends Node2D
class_name ShapeDraw
# Desenha um círculo (jogador) ou triângulo (inimigo) colorido pelo tipo elemental.
# Evita precisar de sprites/arte pra já testar o jogo.

@export var shape: String = "circle"  # "circle" ou "triangle"
@export var color: Color = Color.WHITE
@export var size: float = 16.0

func _draw():
	match shape:
		"circle":
			draw_circle(Vector2.ZERO, size, color)
		"triangle":
			var pts = PackedVector2Array([
				Vector2(0, -size),
				Vector2(size * 0.87, size * 0.6),
				Vector2(-size * 0.87, size * 0.6),
			])
			draw_colored_polygon(pts, color)

func set_shape_color(c: Color):
	color = c
	queue_redraw()
