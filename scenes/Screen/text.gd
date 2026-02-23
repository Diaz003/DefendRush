extends Label

func _process(delta):
	var tiempo = Time.get_time_dict_from_system()
	text = "%02d:%02d" % [tiempo.hour, tiempo.minute]
