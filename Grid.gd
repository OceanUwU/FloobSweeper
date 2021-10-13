extends TileMap

signal uncover(num)
signal flag(num)
signal game_over(won)

const WINDOW_SIZE = 480.0
const TILE_SIZE = 100.0
const Board = preload('res://Board.gd')
const COVERED = {
    "normal": 9,
    "active": 10,
    "hover": 11,
}

export (PackedScene) var Popper
export (PackedScene) var Flag
export (PackedScene) var Floob

var click_mode := 1
var playing = false
var board
var hovered = null
var pressed = null
var flags = []

func _ready():
    pass

func start_game(difficulty):
    playing = true
    for flag in flags:
        flag.queue_free()
    flags = []
    board = Board.new(difficulty)
    scale = Vector2(1.0, 1.0) / (float(board.size) / (WINDOW_SIZE / TILE_SIZE))
    for x in range(board.size):
        for y in range(board.size):
            set_cell(x, y, COVERED.normal)

func _input(event):
    if playing && 'position' in event:
        var pos = pos_to_grid_pos(event.position)
        if typeof(pos) == TYPE_ARRAY: #if mouse is on a tile
            if !board.uncovered[pos[0]][pos[1]]:
                if event is InputEventMouseMotion:
                    if !pressed || !(pos[0] == pressed[0] && pos[1] == pressed[1]):
                        un_press()
                        un_hover()
                        hovered = [pos[0], pos[1]]
                        set_cell(hovered[0], hovered[1], COVERED.hover)
                elif event is InputEventMouseButton:
                    if event.button_index == 1:
                        if click_mode == 1:
                            if event.pressed:
                                un_press()
                                un_hover()
                                pressed = [pos[0], pos[1]]
                                set_cell(pressed[0], pressed[1], COVERED.active)
                            elif pressed:
                                un_press()
                                un_hover()
                                var uncovered_before = board.num_uncovered()
                                uncover(pos[0], pos[1])
                                var now_uncovered = board.num_uncovered()
                                var uncovered = now_uncovered - uncovered_before
                                emit_signal('uncover', uncovered)
                                if uncovered > 1:
                                    get_parent().get_node('Camera2D').shake(0.2, 100, uncovered)
                                if pow(board.size, 2) - now_uncovered <= board.floob_num && playing:
                                    win()
                        elif event.pressed:
                            place_flag(pos[0], pos[1])
                                
                    elif event.button_index == 2 && event.pressed:
                        place_flag(pos[0], pos[1])
            else:
                un_press()
                un_hover()
        else:
            un_press()
            un_hover()

func un_hover():
    if hovered:
        set_cell(hovered[0], hovered[1], COVERED.normal)
        hovered = null

func un_press():
    if pressed:
        set_cell(pressed[0], pressed[1], COVERED.normal)
        pressed = null

func place_flag(x, y):
    for flag in flags:
        if flag.x == x && flag.y == y:
            emit_signal('flag', -1)
            return remove_flag(flag)
                
    var flag = Flag.instance()
    flag.x = x
    flag.y = y
    flag.position = grid_pos_to_pos(x, y)
    flag.scale = scale
    get_parent().add_child(flag)
    flags.append(flag)
    emit_signal('flag', 1)

func remove_flag(flag):
    var popper = Popper.instance()
    popper.get_node('Sprite').texture = flag.get_node('Sprite').texture
    popper.position = grid_pos_to_pos(flag.x, flag.y)
    popper.scale = scale
    get_parent().add_child(popper)
    
    flags.erase(flag)
    flag.queue_free()

func uncover(x, y):
    if !board.uncovered[x][y]:
        if playing:
            for flag in flags:
                if flag.x == x && flag.y == y:
                    return
        
        var adjacent = board.adjacent(x, y)
        board.uncovered[x][y] = true
        
        set_cell(x, y, adjacent if adjacent < 9 else 0)
        
        var popper = Popper.instance()
        popper.position = grid_pos_to_pos(x, y)
        popper.scale = scale
        get_parent().add_child(popper)
        
        if adjacent >= 9 && playing:
            game_over(x, y)
        elif adjacent == 0:
            for x_diff in range(-1, 2):
                for y_diff in range(-1, 2):
                    if (board.tile_exists(x+x_diff, y+y_diff)):
                        uncover(x+x_diff, y+y_diff) 

func place_floob(x, y):
    var floob = Floob.instance()
    floob.position = (grid_pos_to_pos(x, y) - position) / scale
    add_child(floob)
    return floob    

func game_over(x, y):
    playing = false
    emit_signal('game_over', false)
    var floob = place_floob(x, y)
    floob.primary = true
    floob.chase()
    yield(get_tree().create_timer(0.5), 'timeout')
    for f_x in range(board.size):
        for f_y in range(board.size):
            if board.floobs[f_x][f_y] && !(x == f_x && y == f_y):
                uncover(f_x, f_y)
                var curr_floob = place_floob(f_x, f_y)
                curr_floob.chase()
    while len(flags) > 0:
        remove_flag(flags[0])

func win():
    playing = false
    emit_signal('game_over', true)
    $ColorRect/Tween.interpolate_property($ColorRect, 'modulate', Color(1, 1, 1, 0.7), Color(1, 1, 1, 0), 1.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    $ColorRect.rect_scale = Vector2(1, 1) / scale
    $ColorRect/Tween.start()
    yield($ColorRect/Tween, 'tween_completed')
    for x in range(board.size):
        for y in range(board.size):
            if board.floobs[x][y]:
                var floob = place_floob(x, y)
                floob.trap()
                uncover(x, y)
    while len(flags) > 0:
        remove_flag(flags[0])     
    

func pos_to_grid_pos(pos): #vector2 to grid position in [x, y]
    var grid_pos = [
        pos.x / (TILE_SIZE * scale.x),
        (pos.y - position.y) / (TILE_SIZE * scale.y)
    ]
    for i in range(len(grid_pos)):
        var val = grid_pos[i]
        if val < 0 || val >= board.size:
            return null
        grid_pos[i] = int(val)
    return grid_pos

func grid_pos_to_pos(x, y):
    return Vector2(
        x * (TILE_SIZE * scale.x),
        y * (TILE_SIZE * scale.y) + position.y
    )
