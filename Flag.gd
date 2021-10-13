extends Node2D

const SHOW_TIME = 0.2

var x : int
var y : int

func _ready():
    $Light2D/Tween.interpolate_property($Light2D, 'rotation_degrees', -20, 30, SHOW_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    $Light2D/Tween.start()
    yield($Light2D/Tween, 'tween_completed')
    $Light2D.queue_free()
