# Enumeración de formas geométricas
class_name ShapeType

enum {
	TRIANGLE = 0,
	CIRCLE = 1,
	SQUARE = 2
}

static func get_color(shape_type: int) -> Color:
	match shape_type:
		TRIANGLE:
			return Color.YELLOW
		CIRCLE:
			return Color.RED
		SQUARE:
			return Color.BLUE
		_:
			return Color.WHITE

static func get_name(shape_type: int) -> String:
	match shape_type:
		TRIANGLE:
			return "Triangle"
		CIRCLE:
			return "Circle"
		SQUARE:
			return "Square"
		_:
			return "Unknown"
