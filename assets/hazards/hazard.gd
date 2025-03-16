class_name Hazard extends StaticBody2D

enum HazardType {
	LASER,
	MISSILE,
	ZAPPER,
}

var hazard_type: HazardType

func get_hazard_type() -> String:
	match hazard_type:
		HazardType.LASER: return "laser"
		HazardType.MISSILE: return "missile"
		HazardType.ZAPPER: return "zapper"
		_: return "none"

func _init(h_type: HazardType) -> void:
	hazard_type = h_type
