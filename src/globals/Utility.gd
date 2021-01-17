extends Node


static func create_new_tween(tween_parent):
	var tween = Tween.new()
	tween_parent.add_child(tween)
	return tween
