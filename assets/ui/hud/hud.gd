extends MarginContainer

func _process(_delta: float) -> void:
	var coins := Globals.coins
	%DistanceLabel.text = Globals.get_formatted_distance()
	%CoinsLabel.text = str(coins)
