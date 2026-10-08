draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_clear(make_color_rgb(16, 23, 25));
draw_set_font(font_title);
draw_set_colour(mint);
draw_text(48, 38, "ORBITA");
draw_set_font(font_small);
draw_set_colour(muted);
draw_text(50, 82, "LABORATORIO DE PUZLES");
draw_line(48, 116, 1052, 116);
draw_set_font(font_title);
draw_set_colour(c_white);
draw_text(48, 185, "Abre tu propia");
draw_set_colour(mint);
draw_text(48, 230, "salida.");
draw_set_font(font_body);
draw_set_colour(muted);
draw_text_ext(48, 305, "Coloca las cajas en las X para abrir las rejas. Busca la llave y llega a la puerta.", 25, 330);
draw_set_colour(mint);
draw_text(48, 420, "CAMARA " + string(level_index + 1) + " / 5");
draw_set_colour(c_white);
draw_text(48, 453, levels[level_index].name);
draw_set_font(font_small);
draw_set_colour(muted);
draw_text_ext(48, 505, levels[level_index].tip, 21, 325);
draw_set_colour(c_white);
draw_set_font(font_body);
draw_text(440, 145, "Movimientos: " + string(moves));
draw_set_colour(muted);
draw_text(710, 145, "Mejor: " + (best[level_index] > 0 ? string(best[level_index]) : "--"));

for (var cy = 0; cy < grid_height; cy += 1) {
    for (var cx = 0; cx < grid_width; cx += 1) {
        var px = board_left + cx * tile_size;
        var py = board_top + cy * tile_size;
        var cell = string_char_at(levels[level_index].map[cy], cx + 1);
        draw_set_colour(cell == "#" ? make_color_rgb(52, 69, 67) : make_color_rgb(29, 43, 42));
        draw_roundrect(px + 2, py + 2, px + 50, py + 50, false);
        if (cell == "#" && original_art) draw_asset(Spr_pared, 0, px + 2, py + 2, 48, c_white);
    }
}
for (var i = 0; i < array_length(targets); i += 1) {
    var px = board_left + targets[i].cx * tile_size;
    var py = board_top + targets[i].cy * tile_size;
    var active = box_at(targets[i].cx, targets[i].cy) >= 0;
    draw_set_colour(active ? mint : muted);
    draw_circle(px + 26, py + 26, 16, true);
    draw_line_width(px + 16, py + 16, px + 36, py + 36, 3);
    draw_line_width(px + 36, py + 16, px + 16, py + 36, 3);

}
// Closed bars block movement; open bars leave a visible frame.
var gate_open = count_active() == array_length(targets);
for (var gy = 0; gy < grid_height; gy += 1) {
    for (var gx = 0; gx < grid_width; gx += 1) {
        if (string_char_at(levels[level_index].map[gy], gx + 1) != "G") continue;
        var px = board_left + gx * tile_size;
        var py = board_top + gy * tile_size;
        draw_set_colour(gate_open ? mint : muted);
        draw_rectangle(px + 3, py + 3, px + 49, py + 49, true);
        if (!gate_open) {
            if (original_art) draw_asset(Spr_reja, 0, px + 2, py + 2, 48, c_white);
            else for (var bar = 12; bar <= 42; bar += 10) draw_line_width(px + bar, py + 5, px + bar, py + 47, 3);
        }
    }
}
var ready = has_key;
var door_px = board_left + exit_cx * tile_size;
var door_py = board_top + exit_cy * tile_size;
draw_set_colour(ready ? mint : muted);
draw_roundrect(door_px + 9, door_py + 5, door_px + 43, door_py + 48, false);
draw_set_colour(make_color_rgb(21, 43, 39));
draw_rectangle(door_px + 17, door_py + 15, door_px + 35, door_py + 48, false);
if (original_art) draw_asset(Spr_door, 0, door_px + 2, door_py + 2, 48, ready ? mint : c_white);
if (!has_key) {
    var px = board_left + key_cx * tile_size;
    var py = board_top + key_cy * tile_size;
    draw_set_colour(make_color_rgb(239, 204, 113));
    draw_circle(px + 20, py + 20, 7, true);
    draw_line_width(px + 24, py + 24, px + 36, py + 36, 3);
    draw_line_width(px + 36, py + 36, px + 42, py + 30, 3);
    if (original_art) draw_asset(spr_key, 0, px + 5, py + 5, 42, c_white);
}
for (var i = 0; i < array_length(boxes); i += 1) {
    var px = board_left + boxes[i].cx * tile_size;
    var py = board_top + boxes[i].cy * tile_size;
    var active = false;
    for (var j = 0; j < array_length(targets); j += 1) {
        if (targets[j].cx == boxes[i].cx && targets[j].cy == boxes[i].cy) active = true;
    }
    draw_set_colour(active ? mint : make_color_rgb(174, 128, 86));
    draw_roundrect(px + 6, py + 6, px + 46, py + 46, false);
    draw_set_colour(make_color_rgb(63, 61, 42));
    draw_rectangle(px + 12, py + 12, px + 40, py + 40, true);
    draw_line(px + 12, py + 12, px + 40, py + 40);
    draw_line(px + 40, py + 12, px + 12, py + 40);
    if (original_art) draw_asset(Spr_caja, 0, px + 5, py + 5, 42, active ? mint : c_white);
}
var player_px = board_left + render_cx * tile_size;
var player_py = board_top + render_cy * tile_size;
if (original_art) draw_asset(Spr_player, floor(current_time / 160) mod sprite_get_number(Spr_player), player_px + 5, player_py + 5, 42, c_white);
else {
    draw_set_colour(mint);
    draw_roundrect(player_px + 10, player_py + 8, player_px + 42, player_py + 43, false);
    draw_set_colour(make_color_rgb(36, 61, 48));
    draw_roundrect(player_px + 14, player_py + 17, player_px + 38, player_py + 29, false);
    draw_set_colour(c_white);
    draw_rectangle(player_px + 19, player_py + 20, player_px + 22, player_py + 25, false);
    draw_rectangle(player_px + 30, player_py + 20, player_px + 33, player_py + 25, false);
}
draw_set_font(font_small);
draw_set_colour(muted);
draw_text(48, 686, "LLAVE: " + (has_key ? "SI" : "NO") + "    X ACTIVAS: " + string(count_active()) + "/" + string(array_length(targets)));
draw_set_font(font_body);
draw_set_colour(c_white);
draw_text(48, 719, message);
draw_set_font(font_small);
draw_set_colour(muted);
draw_text(48, 774, "Flechas / WASD: mover    Z: deshacer    R: reiniciar    ESC: pausa    T: cambiar graficos");
if (mode != "play") {
    draw_set_alpha(0.93);
    draw_set_colour(make_color_rgb(16, 23, 25));
    draw_rectangle(0, 0, 1100, 820, false);
    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_font(font_title);
    draw_set_colour(mint);
    var heading = "ORBITA";
    if (mode == "pause") heading = "PAUSA";
    if (mode == "win") heading = level_index == 4 ? "LABORATORIO COMPLETADO" : "CAMARA SUPERADA";
    draw_text(550, 200, heading);
    draw_set_font(font_body);
    draw_set_colour(c_white);
    if (mode == "menu") {
        draw_text(550, 270, "Cinco camaras. Una llave. Tu ingenio.");
        draw_text(550, 330, "Selecciona con 1-5 o flechas izquierda / derecha");
        for (var i = 0; i < array_length(levels); i += 1) {
            draw_set_colour(i == level_index ? mint : muted);
            draw_text(550, 385 + i * 37, string(i + 1) + ". " + levels[i].name + (best[i] > 0 ? "   [" + string(best[i]) + " movimientos]" : ""));
        }
        draw_set_colour(mint);
        draw_text(550, 615, "ENTER o ESPACIO para jugar");
    } else if (mode == "pause") {
        draw_text(550, 320, "ENTER / ESC: continuar    M: menu");
    } else {
        draw_text(550, 310, "Salida encontrada en " + string(moves) + " movimientos.");
        draw_text(550, 360, "Mejor marca: " + string(best[level_index]));
        draw_set_colour(mint);
        draw_text(550, 430, level_index == 4 ? "ENTER: volver al menu" : "ENTER: siguiente camara");
        draw_set_colour(muted);
        draw_text(550, 485, "Z: deshacer    R: volver a intentar    ESC: menu");
    }
    draw_set_halign(fa_left);
}
draw_set_colour(c_white);
draw_set_font(-1);
