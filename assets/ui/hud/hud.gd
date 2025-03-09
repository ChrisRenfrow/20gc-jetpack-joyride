extends MarginContainer

func _process(_delta: float) -> void:
	var distance_raw := Globals.distance
	var coins := Globals.coins
	%DistanceLabel.text = "%.2f" % (distance_raw / 10.0) + "m"
	%CoinsLabel.text = str(coins)
