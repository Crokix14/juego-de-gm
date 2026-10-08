// One controller owns the puzzle state; the room contains no duplicate actors.
display_set_gui_size(1100, 820);
window_set_caption("Orbita - Laboratorio del Custodio");
levels = orbita_levels();
level_index = 0;
mode = "play";
original_art = true;
repeat_timer = 0;
history = [];
best = array_create(array_length(levels), 0);
ini_open("orbita_progress.ini");
for (var i = 0; i < array_length(best); i += 1) {
    best[i] = max(0, ini_read_real("best", string(i), 0));
}
ini_close();
font_title = font_add("Arial", 32, true, false, 32, 255);
font_body = font_add("Arial", 15, false, false, 32, 255);
font_small = font_add("Arial", 11, false, false, 32, 255);
mint = make_color_rgb(183, 242, 120);
muted = make_color_rgb(141, 171, 164);
tile_size = 52;
boss_names = ["Cruz de acero", "Anillo interior", "Columna marcada", "Fila marcada", "Barrido izquierdo", "Barrido derecho", "Suelo alterno", "Invocacion", "Onda expansiva", "Impacto dirigido"];
board_left = 440;
board_top = 195;

// Tiempos en segundos: ajusta estos valores para experimentar con el jefe.
boss_warn_duration = 0.75;
boss_enraged_warn_duration = 0.5;
boss_strike_duration = 0.45;
boss_recover_duration = 1.0;

boss_move_interval = 0.28;
boss_chase_duration = 1.4;
boss_melee_warn_duration = 0.4;
iso_half_width = 24;
iso_half_height = 12;
iso_origin_x = 730;
iso_origin_y = 235;
iso_x = function(_cx, _cy) { return iso_origin_x + (_cx - _cy) * iso_half_width; };
iso_y = function(_cx, _cy) { return iso_origin_y + (_cx + _cy) * iso_half_height; };
iso_tile = function(_px, _py, _lift, _outline) {
    draw_triangle(_px - iso_half_width, _py - _lift, _px, _py - iso_half_height - _lift,
        _px + iso_half_width, _py - _lift, _outline);
    draw_triangle(_px - iso_half_width, _py - _lift, _px, _py + iso_half_height - _lift,
        _px + iso_half_width, _py - _lift, _outline);
};

box_at = function(_cx, _cy) {
    for (var i = 0; i < array_length(boxes); i += 1) {
        if (boxes[i].cx == _cx && boxes[i].cy == _cy) return i;
    }
    return -1;
};
is_wall = function(_cx, _cy) {
    if (_cx < 0 || _cy < 0 || _cx >= grid_width || _cy >= grid_height) return true;
    var cell = string_char_at(levels[level_index].map[_cy], _cx + 1);
    return cell == "#" || (cell == "G" && count_active() < array_length(targets));
};
count_active = function() {
    var total = 0;
    for (var i = 0; i < array_length(targets); i += 1) {
        if (box_at(targets[i].cx, targets[i].cy) >= 0) total += 1;
    }
    return total;
};
copy_boxes = function() {
    var result = [];
    for (var i = 0; i < array_length(boxes); i += 1) {
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
    tile_size = min(52, min(580 / grid_width, 480 / grid_height));
    hp = 5; invulnerable = 0; world_time = 0;
    attack_cooldown = 0; slash_timer = 0;
    has_sword = true;
    sword_cx = -1; sword_cy = -1;
    key_cx = -1; key_cy = -1;
    enemies = []; traps = []; enemy_timer = 0.9; enemy_axis = 0;
    boss_alive = false; boss_hp = 100; boss_cx = -1; boss_cy = -1;
    boss_stage = "warn"; boss_pattern = 0; boss_timer = boss_warn_duration;
    boss_cells = []; boss_hit_in_window = false;
    boss_melee = false; boss_move_timer = 0; boss_chase_timer = boss_chase_duration;
    for (var cy = 0; cy < grid_height; cy += 1) {
        for (var cx = 0; cx < grid_width; cx += 1) {
            switch (string_char_at(rows[cy], cx + 1)) {
                case "P": player_cx = cx; player_cy = cy; break;
                case "B": array_push(boxes, {cx: cx, cy: cy}); break;
                case "T": array_push(targets, {cx: cx, cy: cy}); break;
                case "K": key_cx = cx; key_cy = cy; break;
                case "H": array_push(traps, {cx: cx, cy: cy, kind: "H"}); break;
                case "S": array_push(traps, {cx: cx, cy: cy, kind: "S"}); break;
                case "N": array_push(enemies, {cx: cx, cy: cy, hp: 2}); break;
                case "F": sword_cx = cx; sword_cy = cy; break;
                case "Q": boss_cx = cx; boss_cy = cy; boss_alive = true; break;
                case "E": exit_cx = cx; exit_cy = cy; break;
            }
        }
    }
    if (boss_alive) boss_stage = "chase";
    render_cx = player_cx;
    render_cy = player_cy;
    message = "Esquiva los ataques y golpea con ESPACIO durante la recuperacion. R: reiniciar.";
};
undo_move = function() {
    if (boss_alive || mode == "dead") { message = "En combate con el jefe no puedes deshacer."; return; }
    if (array_length(history) == 0) return;
    var snapshot = array_pop(history);
    player_cx = snapshot.cx;
    player_cy = snapshot.cy;
    boxes = snapshot.boxes;
    has_key = snapshot.has_key;
    has_sword = snapshot.has_sword;
    moves = snapshot.moves;
    mode = "play";
    message = "Movimiento deshecho.";
};
try_move = function(_dx, _dy) {
    var nx = player_cx + _dx;
    var ny = player_cy + _dy;
    if (actor_blocks(nx, ny)) { message = "Un enemigo bloquea el paso. Rodealo o usa la espada."; return; }
    if (is_wall(nx, ny)) { message = "Un muro. Busca otro camino."; return; }
    var box = box_at(nx, ny);
    if (box >= 0 && (is_wall(nx + _dx, ny + _dy) || box_at(nx + _dx, ny + _dy) >= 0 || actor_blocks(nx + _dx, ny + _dy))) {
        message = "No hay espacio para empujar esa caja.";
        return;
    }
    array_push(history, {cx: player_cx, cy: player_cy, boxes: copy_boxes(), has_key: has_key, has_sword: has_sword, moves: moves});
    if (box >= 0) {
        boxes[box].cx += _dx;
        boxes[box].cy += _dy;
    }
    player_cx = nx;
    player_cy = ny;
    moves += 1;
    message = box >= 0 ? "Caja movida." : "Encuentra tu camino.";
    if (!has_sword && nx == sword_cx && ny == sword_cy) { has_sword = true; message = "Espada encontrada. ESPACIO para atacar."; }
    if (!has_key && nx == key_cx && ny == key_cy) {
        has_key = true;
        message = "Llave recogida.";
    }
    if (nx == exit_cx && ny == exit_cy) {
        if (has_key && !boss_alive && has_sword) {
            mode = "win";
            if (best[level_index] == 0 || moves < best[level_index]) {
                best[level_index] = moves;
                ini_open("orbita_progress.ini");
                ini_write_real("best", string(level_index), moves);
                ini_close();
            }
        } else {
            message = has_key ? "Antes de salir, recoge la espada azul." : "Necesitas la llave que esta detras de la reja.";
        }
    }
};
// Combat and hazards advance only while playing, never in menus or pause.
enemy_at = function(_cx, _cy) {
    for (var i = 0; i < array_length(enemies); i += 1) {
        if (enemies[i].hp > 0 && enemies[i].cx == _cx && enemies[i].cy == _cy) return i;
    }
    return -1;
};
actor_blocks = function(_cx, _cy) {
    return enemy_at(_cx, _cy) >= 0 || (boss_alive && boss_cx == _cx && boss_cy == _cy);
};
hurt_player = function(_amount) {
    if (invulnerable > 0 || mode != "play") return;
    hp = max(0, hp - _amount);
    invulnerable = 1.1;
    message = "Recibiste dano. Alejate del peligro.";
    if (hp <= 0) { mode = "dead"; message = "R para volver a intentar el nivel."; }
};
trap_danger = function(_kind) {
    return _kind == "S" || (_kind == "H" && (world_time mod 2.8) >= 2.0);
};
attack = function() {
    if (!has_sword) { message = "Necesitas encontrar la espada azul."; return; }
    if (attack_cooldown > 0) return;
    attack_cooldown = 0.38;
    slash_timer = 0.16;
    message = "Golpe de espada.";
    for (var i = 0; i < array_length(enemies); i += 1) {
        if (enemies[i].hp > 0 && abs(enemies[i].cx - player_cx) + abs(enemies[i].cy - player_cy) <= 1) {
            enemies[i].hp = max(0, enemies[i].hp - 1);
            if (enemies[i].hp == 0) message = "Vigilante derrotado.";
        }
    }
    if (boss_alive && abs(boss_cx - player_cx) + abs(boss_cy - player_cy) == 1) {
        if (boss_stage == "recover" && !boss_hit_in_window) {
            boss_hp = max(0, boss_hp - 10);
            boss_hit_in_window = true;
            message = "El escudo cede. Golpe al Custodio.";
            if (boss_hp == 0) {
                boss_alive = false;
                key_cx = boss_cx; key_cy = boss_cy;
                for (var i = 0; i < array_length(enemies); i += 1) enemies[i].hp = 0;
                message = "Custodio derrotado. Recoge su llave y busca la salida.";
            }
        } else message = "Escudo activo. Espera a que el jefe se recupere.";
    }
};
build_boss_cells = function() {
    boss_cells = [];
    if (boss_melee) {
        array_push(boss_cells, {cx: boss_aim_cx, cy: boss_aim_cy});
        return;
    }
    for (var cy = 1; cy < grid_height - 1; cy += 1) {
        for (var cx = 1; cx < grid_width - 1; cx += 1) {
            if (is_wall(cx, cy) || (cx == boss_cx && cy == boss_cy)) continue;
            var dist = abs(cx - boss_cx) + abs(cy - boss_cy);
            var marked = false;
            switch (boss_pattern) {
                case 0: marked = cx == boss_cx || cy == boss_cy; break;
                case 1: marked = dist == 2; break;
                case 2: marked = cx == boss_aim_cx; break;
                case 3: marked = cy == boss_aim_cy; break;
                case 4: marked = cx < boss_cx; break;
                case 5: marked = cx > boss_cx; break;
                case 6: marked = (cx + cy) mod 2 == boss_parity; break;
                case 7: marked = (cx == 2 && cy == 2) || (cx == grid_width - 3 && cy == grid_height - 3); break;
                case 8:
                    var radius = 1 + floor((boss_strike_duration - boss_timer) / (boss_strike_duration / 3));
                    marked = boss_stage == "warn" ? (dist >= 1 && dist <= 3) : dist == clamp(radius, 1, 3);
                    break;
                case 9: marked = abs(cx - boss_aim_cx) <= 1 && abs(cy - boss_aim_cy) <= 1; break;
            }
            if (marked) array_push(boss_cells, {cx: cx, cy: cy});
        }
    }
};
start_boss_warning = function() {
    boss_melee = false;
    boss_stage = "warn";
    boss_timer = boss_hp <= 40 ? boss_enraged_warn_duration : boss_warn_duration;
    boss_aim_cx = player_cx; boss_aim_cy = player_cy;
    boss_parity = (player_cx + player_cy) mod 2;
    boss_hit_in_window = false;
    build_boss_cells();
};
// Breadth-first pursuit routes around walls, boxes and living guards.
move_boss = function() {
    var queue = [{cx: boss_cx, cy: boss_cy, first_cx: boss_cx, first_cy: boss_cy}];
    var seen = array_create(grid_width * grid_height, false);
    seen[boss_cy * grid_width + boss_cx] = true;
    var directions = [{cx: 1, cy: 0}, {cx: -1, cy: 0}, {cx: 0, cy: 1}, {cx: 0, cy: -1}];
    for (var head = 0; head < array_length(queue); head += 1) {
        var node = queue[head];
        if (abs(node.cx - player_cx) + abs(node.cy - player_cy) == 1) {
            boss_cx = node.first_cx; boss_cy = node.first_cy;
            return;
        }
        for (var d = 0; d < 4; d += 1) {
            var nx = node.cx + directions[d].cx; var ny = node.cy + directions[d].cy;
            if (is_wall(nx, ny) || box_at(nx, ny) >= 0 || enemy_at(nx, ny) >= 0) continue;
            if (nx == player_cx && ny == player_cy) continue;
            var index = ny * grid_width + nx;
            if (seen[index]) continue;
            seen[index] = true;
            array_push(queue, {cx: nx, cy: ny,
                first_cx: head == 0 ? nx : node.first_cx,
                first_cy: head == 0 ? ny : node.first_cy});
        }
    }
};
start_boss_melee = function() {
    boss_melee = true; boss_stage = "warn";
    boss_timer = boss_melee_warn_duration;
    boss_aim_cx = player_cx; boss_aim_cy = player_cy;
    boss_hit_in_window = false;
    build_boss_cells();
    message = "Golpe cercano anunciado. Sal de la casilla amarilla.";
};
spawn_guard = function(_cx, _cy) {
    if (is_wall(_cx, _cy) || box_at(_cx, _cy) >= 0 || actor_blocks(_cx, _cy)) return;
    array_push(enemies, {cx: _cx, cy: _cy, hp: 2});
};
tick_combat = function(_dt) {
    if (mode != "play") return;
    world_time += _dt;
    invulnerable = max(0, invulnerable - _dt);
    attack_cooldown = max(0, attack_cooldown - _dt);
    slash_timer = max(0, slash_timer - _dt);
    enemy_timer -= _dt;
    if (enemy_timer <= 0) {
        enemy_timer = 0.6;
        enemy_axis = 1 - enemy_axis;
        for (var i = 0; i < array_length(enemies); i += 1) {
            if (enemies[i].hp <= 0) continue;
            var ex = enemies[i].cx; var ey = enemies[i].cy;
            var dx = sign(player_cx - ex); var dy = sign(player_cy - ey);
            for (var attempt = 0; attempt < 2; attempt += 1) {
                var use_x = attempt == 0 ? enemy_axis == 0 : enemy_axis != 0;
                var nx = ex + (use_x ? dx : 0); var ny = ey + (use_x ? 0 : dy);
                if (nx == ex && ny == ey) continue;
                if (!is_wall(nx, ny) && box_at(nx, ny) < 0 && !actor_blocks(nx, ny)) {
                    enemies[i].cx = nx; enemies[i].cy = ny; break;
                }
            }
        }
    }
    for (var i = 0; i < array_length(enemies); i += 1) {
        if (enemies[i].hp > 0 && enemies[i].cx == player_cx && enemies[i].cy == player_cy) hurt_player(1);
    }
    for (var i = 0; i < array_length(traps); i += 1) {
        if (traps[i].cx == player_cx && traps[i].cy == player_cy && trap_danger(traps[i].kind)) hurt_player(1);
    }
    if (!boss_alive || mode != "play") return;
    if (boss_stage == "chase") {
        boss_chase_timer -= _dt;
        boss_move_timer -= _dt;
        if (boss_move_timer <= 0) {
            move_boss();
            boss_move_timer = boss_move_interval;
        }
        if (abs(boss_cx - player_cx) + abs(boss_cy - player_cy) == 1) start_boss_melee();
        else if (boss_chase_timer <= 0) start_boss_warning();
        return;
    }
    boss_timer -= _dt;
    if (boss_timer <= 0) {
        if (boss_stage == "warn") {
            boss_stage = "strike";
            boss_timer = boss_strike_duration;
            if (!boss_melee && boss_pattern == 7) {
                var alive_guards = 0;
                for (var i = 0; i < array_length(enemies); i += 1) if (enemies[i].hp > 0) alive_guards += 1;
                if (alive_guards < 4) { spawn_guard(2, 2); spawn_guard(grid_width - 3, grid_height - 3); }
            }
        } else if (boss_stage == "strike") {
            boss_stage = "recover";
            boss_timer = boss_recover_duration;
            boss_cells = [];
            message = "Escudo apagado. Acercate y golpea al jefe.";
        } else {
            if (boss_melee) {
                start_boss_warning();
            } else {
                boss_pattern = (boss_pattern + 1) mod 10;
                boss_stage = "chase"; boss_melee = false;
                boss_cells = []; boss_move_timer = 0; boss_chase_timer = boss_chase_duration;
            }
        }
    }
    if (boss_stage != "recover") build_boss_cells();
    if (boss_stage == "strike") {
        for (var i = 0; i < array_length(boss_cells); i += 1) {
            if (boss_cells[i].cx == player_cx && boss_cells[i].cy == player_cy) hurt_player(1);
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
