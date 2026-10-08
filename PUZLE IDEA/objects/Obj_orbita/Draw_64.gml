draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_clear(make_color_rgb(16, 23, 25));
draw_set_font(font_title);
draw_set_colour(mint);
draw_text(48, 38, "ORBITA");
draw_set_font(font_small);
draw_set_colour(muted);
draw_text(50, 82, "LAS VEINTE CAMARAS DEL CUSTODIO");
draw_line(48, 116, 1052, 116);
draw_set_font(font_title);
draw_set_colour(c_white);
draw_text(48, 182, "Acero, llaves");
draw_set_colour(mint);
draw_text(48, 228, "y secretos.");
draw_set_font(font_body);
draw_set_colour(muted);
draw_text_ext(48, 300, "Caja en la X. Reja abierta. Busca la llave, evita las trampas y encuentra la salida.", 24, 330);
draw_set_colour(mint);
draw_text(48, 409, "CAMARA " + string(level_index + 1) + " / " + string(array_length(levels)));
draw_set_colour(c_white);
draw_text(48, 442, levels[level_index].name);
draw_set_font(font_small);
draw_set_colour(muted);
draw_text_ext(48, 488, levels[level_index].tip, 22, 325);
draw_set_font(font_body);
draw_set_colour(c_white);
draw_text(440, 144, "Movimientos: " + string(moves));
draw_set_colour(muted);
draw_text(730, 144, "Mejor: " + (best[level_index] > 0 ? string(best[level_index]) : "--"));
for (var i = 0; i < 5; i += 1) {
    draw_set_colour(i < hp ? make_color_rgb(238, 112, 118) : make_color_rgb(60, 65, 65));
    draw_circle(63 + i * 32, 595, 9, false);
}
draw_set_font(font_small);
draw_set_colour(has_sword ? make_color_rgb(115, 203, 250) : muted);
draw_text(48, 624, has_sword ? "ESPADA LISTA - ESPACIO PARA ATACAR" : "ESPADA: A PARTIR DE LA CAMARA 15");

var ts = tile_size;
for (var cy = 0; cy < grid_height; cy += 1) {
    for (var cx = 0; cx < grid_width; cx += 1) {
        var px = board_left + cx * ts; var py = board_top + cy * ts;
        var cell = string_char_at(levels[level_index].map[cy], cx + 1);
        draw_set_colour(cell == "#" ? make_color_rgb(52, 69, 67) : make_color_rgb(29, 43, 42));
        draw_roundrect(px + 2, py + 2, px + ts - 2, py + ts - 2, false);
        if (cell == "#" && original_art) draw_asset(Spr_pared, 0, px + 2, py + 2, ts - 4, c_white);
    }
}
for (var i = 0; i < array_length(traps); i += 1) {
    var px = board_left + traps[i].cx * ts; var py = board_top + traps[i].cy * ts;
    var danger = trap_danger(traps[i].kind);
    var warning = traps[i].kind == "H" && (world_time mod 2.8) >= 1.5 && !danger;
    var trap_colour = make_color_rgb(91, 116, 119);
    if (danger) {
        trap_colour = make_color_rgb(235, 91, 104);
    } else if (warning) {
        trap_colour = make_color_rgb(239, 204, 113);
    }
    draw_set_colour(trap_colour);
    for (var tooth = 0; tooth < 3; tooth += 1) {
        var tx = px + ts * (0.18 + tooth * 0.24);
        draw_triangle(tx, py + ts * 0.75, tx + ts * 0.1, py + ts * 0.28, tx + ts * 0.2, py + ts * 0.75, !danger);
    }
}
for (var i = 0; i < array_length(targets); i += 1) {
    var px = board_left + targets[i].cx * ts; var py = board_top + targets[i].cy * ts;
    draw_set_colour(box_at(targets[i].cx, targets[i].cy) >= 0 ? mint : muted);
    draw_circle(px + ts * 0.5, py + ts * 0.5, ts * 0.31, true);
    draw_line_width(px + ts * 0.3, py + ts * 0.3, px + ts * 0.7, py + ts * 0.7, 3);
    draw_line_width(px + ts * 0.7, py + ts * 0.3, px + ts * 0.3, py + ts * 0.7, 3);
}
var gate_open = count_active() == array_length(targets);
for (var cy = 0; cy < grid_height; cy += 1) {
    for (var cx = 0; cx < grid_width; cx += 1) {
        if (string_char_at(levels[level_index].map[cy], cx + 1) != "G") continue;
        var px = board_left + cx * ts; var py = board_top + cy * ts;
        draw_set_colour(gate_open ? mint : muted);
        draw_rectangle(px + 3, py + 3, px + ts - 3, py + ts - 3, true);
        if (!gate_open) {
            if (original_art) draw_asset(Spr_reja, 0, px + 2, py + 2, ts - 4, c_white);
            else for (var bar = 1; bar <= 4; bar += 1) draw_line_width(px + ts * bar / 5, py + 5, px + ts * bar / 5, py + ts - 5, 3);
        }
    }
}
var door_px = board_left + exit_cx * ts; var door_py = board_top + exit_cy * ts;
draw_set_colour(has_key ? mint : muted);
draw_roundrect(door_px + ts * 0.17, door_py + 5, door_px + ts * 0.83, door_py + ts - 4, false);
draw_set_colour(make_color_rgb(21, 43, 39));
draw_rectangle(door_px + ts * 0.33, door_py + ts * 0.29, door_px + ts * 0.67, door_py + ts - 4, false);
if (original_art) draw_asset(Spr_door, 0, door_px + 2, door_py + 2, ts - 4, has_key ? mint : c_white);
if (!has_key && key_cx >= 0) {
    var px = board_left + key_cx * ts; var py = board_top + key_cy * ts;
    draw_set_colour(make_color_rgb(239, 204, 113));
    draw_circle(px + ts * 0.38, py + ts * 0.38, ts * 0.14, true);
    draw_line_width(px + ts * 0.46, py + ts * 0.46, px + ts * 0.69, py + ts * 0.69, 3);
    draw_line_width(px + ts * 0.69, py + ts * 0.69, px + ts * 0.81, py + ts * 0.58, 3);
    if (original_art) draw_asset(spr_key, 0, px + 5, py + 5, ts - 10, c_white);
}
if (!has_sword && sword_cx >= 0) {
    var px = board_left + sword_cx * ts; var py = board_top + sword_cy * ts;
    draw_set_colour(make_color_rgb(115, 203, 250));
    draw_line_width(px + ts * 0.3, py + ts * 0.75, px + ts * 0.7, py + ts * 0.2, 5);
    draw_set_colour(make_color_rgb(239, 204, 113));
    draw_line_width(px + ts * 0.2, py + ts * 0.47, px + ts * 0.58, py + ts * 0.74, 4);
}
for (var i = 0; i < array_length(boxes); i += 1) {
    var px = board_left + boxes[i].cx * ts; var py = board_top + boxes[i].cy * ts;
    var active = false;
    for (var j = 0; j < array_length(targets); j += 1) if (targets[j].cx == boxes[i].cx && targets[j].cy == boxes[i].cy) active = true;
    draw_set_colour(active ? mint : make_color_rgb(174, 128, 86));
    draw_roundrect(px + 5, py + 5, px + ts - 5, py + ts - 5, false);
    draw_set_colour(make_color_rgb(63, 61, 42));
    draw_rectangle(px + 10, py + 10, px + ts - 10, py + ts - 10, true);
    draw_line(px + 10, py + 10, px + ts - 10, py + ts - 10);
    draw_line(px + ts - 10, py + 10, px + 10, py + ts - 10);
    if (original_art) draw_asset(Spr_caja, 0, px + 5, py + 5, ts - 10, active ? mint : c_white);
}
if (boss_alive && boss_stage != "recover") {
    draw_set_colour(boss_stage == "strike" ? make_color_rgb(238, 80, 99) : make_color_rgb(239, 204, 113));
    for (var i = 0; i < array_length(boss_cells); i += 1) {
        var px = board_left + boss_cells[i].cx * ts; var py = board_top + boss_cells[i].cy * ts;
        draw_set_alpha(boss_stage == "strike" ? 0.55 : 0.28);
        draw_rectangle(px + 3, py + 3, px + ts - 3, py + ts - 3, false);
        draw_set_alpha(1);
        draw_rectangle(px + 4, py + 4, px + ts - 4, py + ts - 4, true);
    }
}
for (var i = 0; i < array_length(enemies); i += 1) {
    if (enemies[i].hp <= 0) continue;
    var px = board_left + enemies[i].cx * ts; var py = board_top + enemies[i].cy * ts;
    draw_set_colour(make_color_rgb(222, 101, 116));
    draw_roundrect(px + ts * 0.18, py + ts * 0.18, px + ts * 0.82, py + ts * 0.85, false);
    draw_set_colour(make_color_rgb(49, 27, 35));
    draw_rectangle(px + ts * 0.26, py + ts * 0.34, px + ts * 0.74, py + ts * 0.52, false);
    draw_set_colour(c_white);
    draw_line(px + ts * 0.32, py + ts * 0.42, px + ts * 0.43, py + ts * 0.42);
    draw_line(px + ts * 0.57, py + ts * 0.42, px + ts * 0.68, py + ts * 0.42);
    draw_set_colour(make_color_rgb(239, 204, 113));
    for (var hit = 0; hit < enemies[i].hp; hit += 1) draw_rectangle(px + 8 + hit * 11, py + 2, px + 16 + hit * 11, py + 5, false);
}
if (boss_alive) {
    var px = board_left + (boss_cx + 0.5) * ts; var py = board_top + (boss_cy + 0.5) * ts;
    draw_set_colour(boss_stage == "recover" ? mint : make_color_rgb(187, 130, 246));
    draw_circle(px, py, ts * 0.42, false);
    draw_set_colour(make_color_rgb(46, 27, 59));
    draw_triangle(px - ts * 0.25, py - ts * 0.18, px + ts * 0.25, py - ts * 0.18, px, py + ts * 0.3, false);
    draw_set_colour(c_white);
    draw_line_width(px - ts * 0.12, py - ts * 0.07, px + ts * 0.12, py - ts * 0.07, 3);
    draw_set_colour(make_color_rgb(53, 39, 67));
    draw_rectangle(440, 177, 1000, 186, false);
    draw_set_colour(make_color_rgb(187, 130, 246));
    draw_rectangle(440, 177, 440 + 560 * boss_hp / 100, 186, false);
    draw_set_font(font_small);
    draw_set_colour(boss_stage == "recover" ? mint : c_white);
    draw_text(48, 652, "JEFE " + string(boss_hp) + "/100 - " + boss_names[boss_pattern]);
}
var player_px = board_left + render_cx * ts; var player_py = board_top + render_cy * ts;
var player_colour = invulnerable > 0 ? make_color_rgb(255, 160, 170) : c_white;
if (original_art) draw_asset(Spr_player, floor(current_time / 160) mod sprite_get_number(Spr_player), player_px + 5, player_py + 5, ts - 10, player_colour);
else {
    draw_set_colour(invulnerable > 0 ? player_colour : mint);
    draw_roundrect(player_px + ts * 0.2, player_py + ts * 0.15, player_px + ts * 0.8, player_py + ts * 0.83, false);
    draw_set_colour(make_color_rgb(36, 61, 48));
    draw_roundrect(player_px + ts * 0.27, player_py + ts * 0.33, player_px + ts * 0.73, player_py + ts * 0.55, false);
}
if (slash_timer > 0) {
    draw_set_colour(make_color_rgb(115, 203, 250));
    draw_circle(player_px + ts * 0.5, player_py + ts * 0.5, ts * 0.85, true);
    draw_circle(player_px + ts * 0.5, player_py + ts * 0.5, ts * 0.75, true);
}
draw_set_font(font_small);
draw_set_colour(muted);
draw_text(48, 693, "LLAVE: " + (has_key ? "SI" : "NO") + "    X ACTIVAS: " + string(count_active()) + "/" + string(array_length(targets)));
draw_set_font(font_body);
draw_set_colour(c_white);
draw_text(48, 723, message);
draw_set_font(font_small);
draw_set_colour(muted);
draw_text(48, 780, "WASD / flechas: mover    ESPACIO: espada    Z: deshacer    R: reiniciar    ESC: pausa    T: graficos");
if (mode != "play") {
    draw_set_alpha(0.95);
    draw_set_colour(make_color_rgb(16, 23, 25));
    draw_rectangle(0, 0, 1100, 820, false);
    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_font(font_title);
    draw_set_colour(mint);
    var heading = "ORBITA - 20 CAMARAS";
    if (mode == "pause") heading = "PAUSA";
    if (mode == "dead") heading = "INTENTALO OTRA VEZ";
    if (mode == "win") heading = level_index == array_length(levels) - 1 ? "CUSTODIO DERROTADO" : "CAMARA SUPERADA";
    draw_text(550, mode == "menu" ? 95 : 210, heading);
    draw_set_font(font_body);
    draw_set_colour(c_white);
    if (mode == "menu") {
        draw_text(550, 158, "Flechas izquierda / derecha: elegir    ENTER: jugar    1-9: acceso rapido");
        for (var i = 0; i < array_length(levels); i += 1) {
            var col = floor(i / 10); var row = i mod 10;
            draw_set_colour(i == level_index ? mint : muted);
            draw_text(295 + col * 510, 230 + row * 43, string(i + 1) + ". " + levels[i].name + (best[i] > 0 ? " [" + string(best[i]) + "]" : ""));
        }
        draw_set_colour(mint);
        draw_text(550, 720, "Camara 15: la espada. Camara 20: el Custodio y sus diez ataques.");
    } else if (mode == "pause") {
        draw_text(550, 330, "ENTER / ESC: continuar    M: menu");
        draw_text(550, 385, "Trampas y enemigos permanecen congelados durante la pausa.");
    } else if (mode == "dead") {
        draw_text(550, 330, "Te has quedado sin vida. Puedes reintentar sin perder tus marcas.");
        draw_set_colour(mint);
        draw_text(550, 430, "R: reiniciar nivel    ESC: menu");
    } else {
        draw_text(550, 320, "Salida encontrada en " + string(moves) + " movimientos.");
        draw_text(550, 370, "Mejor marca: " + string(best[level_index]));
        draw_set_colour(mint);
        draw_text(550, 450, level_index == array_length(levels) - 1 ? "ENTER: volver al menu" : "ENTER: siguiente camara");
        draw_set_colour(muted);
        draw_text(550, 510, "Z: deshacer    R: volver a intentar    ESC: menu");
    }
    draw_set_halign(fa_left);
}
draw_set_alpha(1);
draw_set_colour(c_white);
draw_set_font(-1);
