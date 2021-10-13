extends TextureButton

class_name SweepModeButton

signal onned

var active := false
        
func _pressed():
    set_active(true)

func set_active(new_active):
    active = new_active
    var color = 1.0 if active else 0.4
    modulate = Color(color, color, color, 1)
    if active:
        emit_signal('onned')
