extends Control

signal set_mode(mode)

const Consts = preload('res://Consts.gd')

var first_pressed := false
var time_elapsed : float
var allow_playing := false
var playing := false
var flags_left := 0
var uncovers_left := 0

func _ready():
    $FlagButton.set_active(false)
    $SweepButton.set_active(true)

func start_game(difficulty):
    var tiles = pow(Consts.difficulties[difficulty].size, 2)
    flags_left = Consts.difficulties[difficulty].floobs
    uncovers_left = tiles - flags_left
    change_flags_left(0)
    change_uncovers_left(0)
    allow_playing = true
    time_elapsed = 0

func change_flags_left(amount):
    flags_left -= amount
    $FlagButton/Remaining.text = str(flags_left)
    $FlagButton/Remaining.set('custom_colors/font_color', Color(1, 1, 1, 1) if flags_left >= 0 else Color(1, 0, 0, 1))

func change_uncovers_left(amount):
    if allow_playing:
        playing = true
    uncovers_left -= amount
    $SweepButton/Remaining.text = str(uncovers_left)

func end_game():
    allow_playing = false
    playing = false

func _process(delta):
    if playing:
        time_elapsed += delta
    $Timer/ColorRect.rect_rotation = (fmod(time_elapsed, 60) / 60) * 360 - 180
    $Timer/Time.text = '%.1f' % time_elapsed

func _on_SweepButton_onned():
    emit_signal('set_mode', 1)
    $FlagButton.set_active(false)

func _on_FlagButton_onned():
    emit_signal('set_mode', 0)
    $SweepButton.set_active(false)
