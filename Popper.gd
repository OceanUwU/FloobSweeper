extends RigidBody2D

const MAX_X_VEL = 300.0
const MIN_Y_VEL = -600.0
const MAX_Y_VEL = -100.0
const MAX_ANG_VEL = 2.0
const LIFETIME = 1.2

func _ready():
    randomize()
    linear_velocity.x = rand_range(-MAX_X_VEL, MAX_X_VEL)
    linear_velocity.y = rand_range(MIN_Y_VEL, MAX_Y_VEL)
    angular_velocity = randf() * MAX_ANG_VEL * 2 - MAX_ANG_VEL
    $Tween.interpolate_property(self, 'scale', scale, Vector2(0, 0), LIFETIME, Tween.TRANS_SINE, Tween.EASE_IN)
    $Tween.start()
    yield($Tween, 'tween_completed')
    queue_free()
