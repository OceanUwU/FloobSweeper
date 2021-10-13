extends Object

class_name Board

const Consts = preload('res://Consts.gd')

var difficulty : String
var size : int
var floob_num : int
var floobs = []
var uncovered = []
var generated : bool

func _init(new_difficulty):
    randomize()
    difficulty = new_difficulty
    size = Consts.difficulties[difficulty].size
    floob_num = Consts.difficulties[difficulty].floobs
    
    for _y in range(size):
        var row = []
        for _x in range(size):
            row.append(false)
        uncovered.append(row)
    floobs = uncovered.duplicate(true)

func generate(forbidden_x, forbidden_y):
    floobs = uncovered.duplicate(true)
    for _i in range(floob_num):
        while true:
            var x = randi() % size
            var y = randi() % size
            
            if forbidden_x == x && forbidden_y == y:
                continue
            elif floobs[x][y]:
                continue
            else:
                floobs[x][y] = true
                break
    generated = true
    if adjacent(forbidden_x, forbidden_y) > 0:
        return generate(forbidden_x, forbidden_y)
        
func num_uncovered():
    var num = 0
    for row in uncovered:
        for cell in row:
            num += int(cell)
    return num
           
func adjacent(x, y):
    if !generated:
        generate(x, y)
    if floobs[x][y]:
        return 9
    var adjacent_floobs = 0
    for x_diff in range(-1, 2):
        for y_diff in range(-1, 2):
            if tile_exists(x+x_diff, y+y_diff) && floobs[x+x_diff][y+y_diff]:
                adjacent_floobs += 1
    return adjacent_floobs

func tile_exists(x, y):
    return 0 <= x && x < size && 0 <= y && y < size
