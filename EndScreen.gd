extends CanvasLayer

signal new_game(difficulty)

const Consts = preload('res://Consts.gd')
const WAIT_TIME = 2.8
const APPEAR_TIME := 0.6

var screen_width := 480

func _ready():
    scale = Vector2(-1, -1)
    for difficulty in Consts.difficulties:
        $Difficulty.add_item(difficulty)

func get_best(difficulty):
    var best_file = File.new()
    best_file.open('user://best-'+difficulty+'.dat', File.READ)
    return float(best_file.get_as_text())

func update_best(difficulty, new_time):
    var best_file = File.new()
    best_file.open('user://best-'+difficulty+'.dat', File.READ)
    var best = float(best_file.get_as_text())
    if best == 0.0 or new_time < best:
        best_file.open('user://best-'+difficulty+'.dat', File.WRITE)
        best_file.store_string(str(new_time))

func end(time, difficulty, won):
    $GameOver.text = 'Success!' if won else 'Fail.'
    var n = 0
    for i in Consts.difficulties:
        if difficulty == i:
            $Difficulty.selected = n
        n += 1
    
    if won:
        $Time/Label.text = '%.2f' % time
        update_best(difficulty, time)
    else:
        $Time/Label.text = '--.--'
    
    var best = get_best(difficulty)
    $Best/Label.text = ('%.2f' % best) if best > 0 else '--.--'
    
    yield(get_tree().create_timer(WAIT_TIME), 'timeout')
    $Offset.interpolate_property(self, 'offset:x', -screen_width, 0, APPEAR_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Offset.start()
    $ColorRect/Tween.interpolate_property($ColorRect, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), APPEAR_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $ColorRect/Tween.start()
    $ColorRect.modulate.a = 0 #stop it from appearing for a frame lol
    offset.x = -screen_width #stop it from appearing for a frame lol
    scale = Vector2(1, 1)

func dismiss():
    $Offset.interpolate_property(self, 'offset:x', 0, screen_width, APPEAR_TIME, Tween.TRANS_QUAD, Tween.EASE_IN)
    $Offset.start()
    $ColorRect/Tween.interpolate_property($ColorRect, 'modulate', Color(1, 1, 1, 1), Color(1, 1, 1, 0), APPEAR_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $ColorRect/Tween.start()
    yield($Offset, 'tween_completed')
    scale = Vector2(-1, -1)

func _on_Difficulty_item_selected(index):
    get_parent().difficulty = $Difficulty.get_item_text(index)

func _on_Start_pressed():
    get_parent().start_game()
    dismiss()
