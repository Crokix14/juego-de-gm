// One controller owns the puzzle state; the room contains no duplicate actors.
display_set_gui_size(1100, 820);
window_set_caption("Orbita - Laboratorio de puzles");
levels = orbita_levels();
level_index = 0;
mode = "menu";
original_art = true;
repeat_timer = 0;
history = [];
best = array_create(array_length(levels), 0);
ini_open("orbita_progress.ini");
for (var i = 0; i < array_length(best); ++i) {
    best[i] = max(0, ini_read_real("best", string(i), 0));
}
ini_close();
font_title = font_add("Arial", 32, true, false, 32, 255);
font_body = font_add("Arial", 15, false, false, 32, 255);
font_small = font_add("Arial", 11, false, false, 32, 255);
mint = make_color_rgb(183, 242, 120);
muted = make_color_rgb(141, 171, 164);
tile_size = 52;
board_left = 440;
board_top = 195;

box_at = function(_cx, _cy) {
    for (var i = 0; i < array_length(boxes); ++i) {
        if (boxes[i].cx == _cx && boxes[i].cy == _cy) return i;
    }
    return -1;
};
is_wall = function(_cx, _cy) {
    if (_cx < 0 || _cy < 0 || _cx >= grid_width || _cy >= grid_height) return true;
    return string_char_at(levels[level_index].map[_cy], _cx + 1) == "#";
};
count_active = function() {
    var total = 0;
    for (var i = 0; i < array_length(targets); ++i) {
        if (box_at(targets[i].cx, targets[i].cy) >= 0) ++total;
    }
    return total;
};
copy_boxes = function() {
    var result = [];
    for (var i = 0; i < array_length(boxes); ++i) {
        array_push(result, {cx: boxes[i].cx, cy: boxes[i].cy});
    }
    return result;
};
load_level = function(_index) {
    level_index = clamp(_index, 0, array_length(levels) - 1);
    var rows = levels[level_index].map;
    grid_width = string_length(rows[0]);
    grid_height = array_length(rows);
    boxes = [];
    targets = [];
    has_key = false;
    moves = 0;
    history = [];
    repeat_timer = 0;
    for (var cy = 0; cy < grid_height; ++cy) {
        for (var cx = 0; cx < grid_width; ++cx) {
            switch (string_char_at(rows[cy], cx + 1)) {
                case "P": player_cx = cx; player_cy = cy; break;
                case "B": array_push(boxes, {cx: cx, cy: cy}); break;
                case "T": array_push(targets, {cx: cx, cy: cy}); break;
                case "K": key_cx = cx; key_cy = cy; break;
                case "E": exit_cx = cx; exit_cy = cy; break;
            }
        }
    }
    render_cx = player_cx;
    render_cy = player_cy;
    message = "Recoge la llave y abre la salida.";
};
undo_move = function() {
    if (array_length(history) == 0) return;
    var snapshot = array_pop(history);
    player_cx = snapshot.cx;
    player_cy = snapshot.cy;
    boxes = snapshot.boxes;
    has_key = snapshot.has_key;
    moves = snapshot.moves;
    mode = "play";
    message = "Movimiento deshecho.";
};
try_move = function(_dx, _dy) {
    var nx = player_cx + _dx;
    var ny = player_cy + _dy;
    if (is_wall(nx, ny)) { message = "Un muro. Busca otro camino."; return; }
    var box = box_at(nx, ny);
    if (box >= 0 && (is_wall(nx + _dx, ny + _dy) || box_at(nx + _dx, ny + _dy) >= 0)) {
        message = "No hay espacio para empujar esa caja.";
        return;
    }
    array_push(history, {cx: player_cx, cy: player_cy, boxes: copy_boxes(), has_key: has_key, moves: moves});
    if (box >= 0) {
        boxes[box].cx += _dx;
        boxes[box].cy += _dy;
    }
    player_cx = nx;
    player_cy = ny;
    ++moves;
    message = box >= 0 ? "Caja movida." : "Encuentra tu camino.";
    if (!has_key && nx == key_cx && ny == key_cy) {
        has_key = true;
        message = "Llave recogida.";
    }
    if (nx == exit_cx && ny == exit_cy) {
        if (has_key && count_active() == array_length(targets)) {
            mode = "win";
            if (best[level_index] == 0 || moves < best[level_index]) {
                best[level_index] = moves;
                ini_open("orbita_progress.ini");
                ini_write_real("best", string(level_index), moves);
                ini_close();
            }
        } else {
            message = has_key ? "Activa todos los interruptores." : "Necesitas la llave.";
        }
    }
};
// Draw existing sprites at cell size, independent of their configured origins.
draw_asset = function(_sprite, _frame, _px, _py, _size, _colour) {
    var sx = _size / sprite_get_width(_sprite);
    var sy = _size / sprite_get_height(_sprite);
    draw_sprite_ext(_sprite, _frame, _px + sprite_get_xoffset(_sprite) * sx,
        _py + sprite_get_yoffset(_sprite) * sy, sx, sy, 0, _colour, 1);
};
load_level(0);
