var dt = min(delta_time / 1000000, 0.1);
repeat_timer = max(0, repeat_timer - dt);
render_cx = lerp(render_cx, player_cx, min(1, dt * 22));
render_cy = lerp(render_cy, player_cy, min(1, dt * 22));
if (keyboard_check_pressed(ord("T"))) original_art = !original_art;

if (mode == "menu") {
    for (var i = 0; i < min(9, array_length(levels)); i += 1) {
        if (keyboard_check_pressed(ord("1") + i)) load_level(i);
    }
    if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) load_level((level_index + array_length(levels) - 1) mod array_length(levels));
    if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) load_level((level_index + 1) mod array_length(levels));
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) mode = "play";
    exit;
}
if (keyboard_check_pressed(vk_escape)) {
    if (mode == "pause") mode = "play";
    else if (mode == "play") mode = "pause";
    else mode = "menu";
    exit;
}
if (mode == "pause") {
    if (keyboard_check_pressed(vk_enter)) mode = "play";
    if (keyboard_check_pressed(ord("M"))) mode = "menu";
    exit;
}
if (keyboard_check_pressed(ord("Z"))) { undo_move(); exit; }
if (keyboard_check_pressed(ord("R"))) { load_level(level_index); mode = "play"; exit; }
if (mode == "dead") exit;
if (mode == "win") {
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
        if (level_index < array_length(levels) - 1) { load_level(level_index + 1); mode = "play"; }
        else { load_level(0); mode = "menu"; }
    }
    exit;
}
var dx = 0;
var dy = 0;
var pressed = keyboard_check_pressed(vk_left) || keyboard_check_pressed(vk_right)
    || keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_down)
    || keyboard_check_pressed(ord("A")) || keyboard_check_pressed(ord("D"))
    || keyboard_check_pressed(ord("W")) || keyboard_check_pressed(ord("S"));
if (pressed || repeat_timer <= 0) {
    if (keyboard_check(vk_left) || keyboard_check(ord("A"))) dx = -1;
    else if (keyboard_check(vk_right) || keyboard_check(ord("D"))) dx = 1;
    else if (keyboard_check(vk_up) || keyboard_check(ord("W"))) dy = -1;
    else if (keyboard_check(vk_down) || keyboard_check(ord("S"))) dy = 1;
    if (dx != 0 || dy != 0) {
        try_move(dx, dy);
        repeat_timer = pressed ? 0.2 : 0.12;
    }
}

if (mode == "play") {
    if (keyboard_check_pressed(vk_space)) attack();
    tick_combat(dt);
}
