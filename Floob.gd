extends Node2D

const CHASE_DELAY_TIME = 1.3
const CHASE_DELAY_TIME_VARIATION = 0.5
const CHASE_TIME = 2.3
const TRAP_TIME = 0.8
const TIME_BETWEEN_TRAPPING_AND_FLIPPING = 0.5
const TIME_BETWEEN_FLIPS = 0.14

var primary := false
var flipping := false
var flip_timer := TIME_BETWEEN_FLIPS

func _ready():
    pass

func _process(delta):
    if flipping:
        flip_timer += delta
        if (flip_timer >= TIME_BETWEEN_FLIPS):
            flip_timer -= TIME_BETWEEN_FLIPS
            $Sprite.flip_h = !$Sprite.flip_h

func trap():
    yield(get_tree().create_timer(randf() * CHASE_DELAY_TIME_VARIATION), 'timeout')
    $Cage/Tween.interpolate_property($Cage, 'position:y', -600 / get_parent().scale.y, 0, TRAP_TIME, Tween.TRANS_QUAD, Tween.EASE_IN)
    $Cage/Tween.start()
    $Cage.show()
    yield($Cage/Tween, 'tween_completed')
    yield(get_tree().create_timer(TIME_BETWEEN_TRAPPING_AND_FLIPPING), 'timeout')
    flipping = true

func chase():
    yield(get_tree().create_timer(CHASE_DELAY_TIME+(0.0 if primary else (randf() * CHASE_DELAY_TIME_VARIATION))), 'timeout')
    flipping = true
    if primary:
        z_index += 1
    $Sprite/Modulate.interpolate_property($Sprite, 'modulate', Color(1, 1, 1, 1), Color(0, 0, 0, 1), CHASE_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $Sprite/Modulate.start()
    $Sprite/Scale.interpolate_property($Sprite, 'scale', $Sprite.scale, Vector2(1, 1) * 4 / get_parent().scale, CHASE_TIME, Tween.TRANS_QUAD, Tween.EASE_IN)
    $Sprite/Scale.start()
