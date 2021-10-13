extends Node

var grid
var uncovered : int
var flags : int
var difficulty := 'Easy'

func _ready():
    grid = $Grid
    start_game()

func start_game():
    get_tree().call_group('floobs', 'queue_free')
    grid.start_game(difficulty)
    $HUD.start_game(difficulty)
    uncovered = pow(grid.board.size, 2) - grid.board.floob_num
    flags = 0

func _on_Grid_flag(num):
    $HUD.change_flags_left(num)

func _on_Grid_uncover(num):
    $HUD.change_uncovers_left(num)

func _on_Grid_game_over(won):
    $HUD.end_game()
    $EndScreen.end($HUD.time_elapsed, difficulty, won)

func _on_HUD_set_mode(mode):
    $Grid.click_mode = mode
