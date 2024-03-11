extends Node


func weightedChoice(list: Dictionary) -> Variant:
	var sum: = 0.
	for i in list.values():
		sum += i
	var dart: = randf_range(0., sum)
	sum = 0.
	for i in range(len(list)):
		if dart <= sum + list.values()[i]:
			return list.keys()[i]
		sum += list.values()[i]
	return ERR_BUG


func pol2Car(r: float, theta: float) -> Vector2:
	return r * Vector2(cos(theta), sin(theta))
