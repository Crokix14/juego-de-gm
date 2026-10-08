draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_clear(make_color_rgb(16, 23, 25));
draw_set_font(font_title);
draw_set_colour(mint);
draw_text(48, 38, "ORBITA");
draw_set_font(font_small);
draw_set_colour(muted);
draw_text(50, 82, "ARENA ISOMETRICA DEL CUSTODIO");
draw_line(48, 116, 1052, 116);
draw_set_font(font_title);
draw_set_colour(c_white);
draw_text(48, 182, "Acero, llaves");
draw_set_colour(mint);
draw_text(48, 228, "y secretos.");
draw_set_font(font_body);
draw_set_colour(muted);
draw_text_ext(48, 300, "Esquiva los avisos amarillos. El Custodio te persigue. Golpealo cuando su escudo se apague.", 24, 330);
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
draw_text(48, 624, has_sword ? "ESPADA LISTA - ESPACIO PARA ATACAR" : "BUSCA LA ESPADA AZUL");

// Ground first; upright objects are painted back to front by grid diagonal.
for (var cy = 0; cy < grid_height; cy += 1) {
    for (var cx = 0; cx < grid_width; cx += 1) {
        var px = iso_x(cx, cy); var py = iso_y(cx, cy);
        draw_set_colour(make_color_rgb(29, 43, 42));
        iso_tile(px, py, 0, false);
        draw_set_colour(make_color_rgb(52, 69, 67));
        iso_tile(px, py, 0, true);
        if (boss_alive && (boss_stage == "warn" || boss_stage == "strike")) {
            for (var i = 0; i < array_length(boss_cells); i += 1) {
                if (boss_cells[i].cx != cx || boss_cells[i].cy != cy) continue;
                draw_set_colour(boss_stage == "strike" ? make_color_rgb(238,80,99) : make_color_rgb(239,204,113));
                draw_set_alpha(boss_stage == "strike" ? 0.8 : 0.6);
                iso_tile(px, py, 1, false);
                draw_set_alpha(1);
            }
        }
    }
}
for (var diagonal = 0; diagonal < grid_width + grid_height - 1; diagonal += 1) {
    for (var cx = 0; cx < grid_width; cx += 1) {
        var cy = diagonal - cx;
        if (cy < 0 || cy >= grid_height) continue;
        var px = iso_x(cx, cy); var py = iso_y(cx, cy);
        var cell = string_char_at(levels[level_index].map[cy], cx + 1);
        if (cell == "#") {
            // Low raised walls keep actors and danger tiles visible.
            draw_set_colour(make_color_rgb(39, 55, 55));
            draw_triangle(px-24,py,px-24,py-12,px,py+12,false);
            draw_triangle(px-24,py-12,px,py,px,py+12,false);
            draw_set_colour(make_color_rgb(48, 65, 64));
            draw_triangle(px,py+12,px,py,px+24,py-12,false);
            draw_triangle(px,py+12,px+24,py-12,px+24,py,false);
            draw_set_colour(make_color_rgb(77, 96, 91));
            iso_tile(px,py,12,false);
        }
        if (cx == exit_cx && cy == exit_cy) {
            draw_set_colour(has_key ? mint : muted);
            draw_roundrect(px-12,py-35,px+12,py,false);
            draw_set_colour(make_color_rgb(21,43,39));
            draw_rectangle(px-7,py-27,px+7,py,false);
        }
        if (!has_key && cx == key_cx && cy == key_cy) {
            draw_set_colour(make_color_rgb(239,204,113));
            draw_circle(px-4,py-13,5,true);
            draw_line_width(px,py-10,px+8,py-3,3);
        }
        for (var i = 0; i < array_length(enemies); i += 1) {
            if (enemies[i].hp <= 0 || enemies[i].cx != cx || enemies[i].cy != cy) continue;
            draw_set_colour(make_color_rgb(222,101,116));
            draw_roundrect(px-10,py-29,px+10,py,false);
            draw_set_colour(c_white);
            draw_line(px-5,py-20,px+5,py-20);
        }
        if (boss_alive && boss_cx == cx && boss_cy == cy) {
            draw_set_colour(make_color_rgb(12,17,20));
            draw_ellipse(px-17,py-5,px+17,py+5,false);
            draw_set_colour(boss_stage == "recover" ? mint : make_color_rgb(187,130,246));
            draw_circle(px,py-23,19,false);
            draw_set_colour(make_color_rgb(46,27,59));
            draw_triangle(px-11,py-33,px+11,py-33,px,py-12,false);
            draw_set_colour(c_white);
            draw_line_width(px-5,py-27,px+5,py-27,3);
        }
        if (floor(render_cx + render_cy + 0.5) == diagonal && floor(render_cx + 0.5) == cx) {
            var player_px = iso_x(render_cx,render_cy);
            var player_py = iso_y(render_cx,render_cy);
            draw_set_colour(make_color_rgb(12,17,20));
            draw_ellipse(player_px-12,player_py-4,player_px+12,player_py+4,false);
            var colour = invulnerable > 0 ? make_color_rgb(255,160,170) : c_white;
            if (original_art) draw_asset(Spr_player, floor(current_time/160) mod sprite_get_number(Spr_player), player_px-16,player_py-32,32,colour);
            else {
                draw_set_colour(invulnerable > 0 ? colour : mint);
                draw_roundrect(player_px-10,player_py-29,player_px+10,player_py,false);
                draw_set_colour(make_color_rgb(36,61,48));
                draw_rectangle(player_px-7,player_py-22,player_px+7,player_py-15,false);
            }
            if (slash_timer > 0) {
                draw_set_colour(make_color_rgb(115,203,250));
                draw_ellipse(player_px-28,player_py-23,player_px+28,player_py+5,true);
            }
        }
    }
}
if (boss_alive) {
    draw_set_colour(make_color_rgb(53,39,67));
    draw_rectangle(440,177,1000,186,false);
    draw_set_colour(make_color_rgb(187,130,246));
    draw_rectangle(440,177,440+560*boss_hp/100,186,false);
    draw_set_font(font_small);
    draw_set_colour(boss_stage == "recover" ? mint : c_white);
    var attack_name = boss_names[boss_pattern];
    if (boss_stage == "chase") attack_name = "Persecucion";
    else if (boss_melee) attack_name = "Golpe cercano";
    draw_text(48,652,"JEFE " + string(boss_hp) + "/100 - " + attack_name);
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
    var heading = "ORBITA - LABORATORIO DEL CUSTODIO";
    if (mode == "pause") heading = "PAUSA";
    if (mode == "dead") heading = "INTENTALO OTRA VEZ";
    if (mode == "win") heading = level_index == array_length(levels) - 1 ? "CUSTODIO DERROTADO" : "CAMARA SUPERADA";
    draw_text(550, mode == "menu" ? 95 : 210, heading);
    draw_set_font(font_body);
    draw_set_colour(c_white);
    if (mode == "menu") {
        draw_text(550, 158, "ENTER: combatir    ESPACIO: atacar    R: reiniciar");
        for (var i = 0; i < array_length(levels); i += 1) {
            var col = floor(i / 10); var row = i mod 10;
            draw_set_colour(i == level_index ? mint : muted);
            draw_text(295 + col * 510, 230 + row * 43, string(i + 1) + ". " + levels[i].name + (best[i] > 0 ? " [" + string(best[i]) + "]" : ""));
        }
        draw_set_colour(mint);
        draw_text(550, 720, "Una arena. Diez ataques. Espada equipada desde el inicio.");
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
