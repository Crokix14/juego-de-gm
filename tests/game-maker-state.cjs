// Runs the JS-compatible GML state methods; does not compile or render GML.
const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const root = require('node:path').resolve(__dirname, '../PUZLE IDEA') + '/';
const c = {
  array_create: (n,v) => Array(n).fill(v),
  array_length: a => a.length, array_push: (a, v) => a.push(v), array_pop: a => a.pop(),
  clamp: (v, lo, hi) => Math.min(hi, Math.max(lo, v)), string_length: s => s.length,
  string_char_at: (s, i) => s[i - 1], string: String,
  min:Math.min, max:Math.max, abs:Math.abs, floor:Math.floor, sign:Math.sign,
  ini_open() {}, ini_close() {}, ini_write_real() {}
};
vm.createContext(c);
vm.runInContext(fs.readFileSync(root + 'scripts/orbita_levels/orbita_levels.gml', 'utf8'), c);
c.levels = c.orbita_levels(); c.best = Array(c.levels.length).fill(0);
let code = fs.readFileSync(root + 'objects/Obj_orbita/Create_0.gml', 'utf8');
vm.runInContext(code.slice(code.indexOf('// Tiempos en segundos:'), code.indexOf('// Draw existing sprites')).replace(/\bmod\b/g, '%'), c);
assert.equal(c.levels.length, 1, 'only the boss arena remains');
c.load_level(0); c.mode='play';
assert(c.has_sword, 'sword equipped from spawn');
assert(c.boss_alive); assert.equal(c.boss_stage,'chase');
c.start_boss_warning(); assert.equal(c.boss_timer,0.75);
c.player_cx=1; c.player_cy=1;
c.tick_combat(0.74); assert.equal(c.boss_stage,'warn');
c.tick_combat(0.02); assert.equal(c.boss_stage,'strike');
assert.equal(c.boss_timer,0.45);
c.tick_combat(0.46); assert.equal(c.boss_stage,'recover');
assert.equal(c.boss_timer,1.0);
c.tick_combat(1.01); assert.equal(c.boss_stage,'chase');
assert.equal(c.boss_pattern,1);
c.boss_hp=40; c.start_boss_warning(); assert.equal(c.boss_timer,0.5);
const time=c.world_time; c.mode='pause'; c.tick_combat(1); assert.equal(c.world_time,time);
c.load_level(0); assert.equal(c.hp,5); assert.equal(c.boss_hp,100); assert.equal(c.boss_pattern,0);
console.log('PASS: boss-only arena, equipped sword, faster stage timing, enraged warning, pause and reset');
// All ten boss patterns have safe tiles. Recoveries are the only damage windows.
c.load_level(0);c.mode='play';assert(c.boss_alive);assert.equal(c.key_cx,-1);
c.player_cx=c.boss_cx;c.player_cy=c.boss_cy+1;c.attack();assert.equal(c.boss_hp,100,'shield rejects attacks');
const signatures=new Set();
for(let pattern=0;pattern<10;pattern++){
  c.boss_pattern=pattern;c.player_cx=6;c.player_cy=8;c.start_boss_warning();
  const marked=new Set(c.boss_cells.map(p=>`${p.cx},${p.cy}`));assert(marked.size>0);
  signatures.add([...marked].sort().join(';'));
  const safe=[];for(let y=1;y<c.grid_height-1;y++)for(let x=1;x<c.grid_width-1;x++)if(!c.is_wall(x,y)&&!marked.has(`${x},${y}`)&&!(x===c.boss_cx&&y===c.boss_cy))safe.push([x,y]);
  assert(safe.length>0,`safe location for pattern ${pattern+1}`);
  c.player_cx=safe[0][0];c.player_cy=safe[0][1];c.boss_timer=0;c.tick_combat(0.01);assert.equal(c.boss_stage,'strike');
  if(pattern===7)assert(c.enemies.filter(e=>e.hp>0).length>=2,'summons guards');
  // Avoid testing NPC contact here; separately tested above.
  c.enemies=[];
  c.boss_timer=c.boss_strike_duration-0.01;c.build_boss_cells();
  const impact=c.boss_cells[0];c.player_cx=impact.cx;c.player_cy=impact.cy;c.hp=5;c.invulnerable=0;
  c.tick_combat(0.01);assert.equal(c.hp,4,`pattern ${pattern+1} deals damage on its marked tile`);
  c.player_cx=safe[0][0];c.player_cy=safe[0][1];
  if(pattern===8){c.boss_timer=c.boss_strike_duration*0.9;c.build_boss_cells();assert(c.boss_cells.every(p=>Math.abs(p.cx-c.boss_cx)+Math.abs(p.cy-c.boss_cy)===1));c.boss_timer=c.boss_strike_duration*0.2;c.build_boss_cells();assert(c.boss_cells.every(p=>Math.abs(p.cx-c.boss_cx)+Math.abs(p.cy-c.boss_cy)===3));}
  c.boss_timer=0;c.tick_combat(0.01);assert.equal(c.boss_stage,'recover');assert.equal(c.boss_cells.length,0);
  c.player_cx=c.boss_cx;c.player_cy=c.boss_cy+1;c.attack_cooldown=0;c.attack();assert.equal(c.boss_hp,90-pattern*10);
  c.attack_cooldown=0;c.attack();assert.equal(c.boss_hp,90-pattern*10,'only one hit per recovery');
  if(pattern<9){c.boss_timer=0;c.tick_combat(0.01);assert.equal(c.boss_pattern,pattern+1);assert.equal(c.boss_stage,'chase');}
}
assert.equal(signatures.size,10,'distinct boss danger patterns');assert(!c.boss_alive);assert.equal(c.key_cx,c.boss_cx);assert.equal(c.boss_hp,0);
c.try_move(0,-1);assert(c.has_key);c.player_cx=c.exit_cx;c.player_cy=c.exit_cy+1;c.try_move(0,-1);assert.equal(c.mode,'win');
console.log('PASS: 10 distinct telegraphs, safe cells, shields, summon, expanding wave, timed recovery, 100 HP, dropped key and arena victory');
// Step/Draw syntax and menu/pause controls in this JS-compatible simulation.
const stepCode=fs.readFileSync(root+'objects/Obj_orbita/Step_0.gml','utf8').replace(/\bmod\b/g,'%').replace(/\bexit;/g,'return;');
const drawCode=fs.readFileSync(root+'objects/Obj_orbita/Draw_64.gml','utf8').replace(/\bmod\b/g,'%');new vm.Script('(function(){'+drawCode+'})');
c.delta_time=16667;c.lerp=(a,b,t)=>a+(b-a)*t;c.ord=s=>s.charCodeAt(0);c.vk_left=37;c.vk_up=38;c.vk_right=39;c.vk_down=40;c.vk_enter=13;c.vk_space=32;c.vk_escape=27;
let pressed=new Set();c.keyboard_check_pressed=k=>pressed.has(k);c.keyboard_check=k=>pressed.has(k);
const step=vm.runInContext('(function(){'+stepCode+'})',c);
c.load_level(0);c.mode='menu';pressed=new Set([37]);step();assert.equal(c.level_index,0);pressed=new Set([13]);step();assert.equal(c.mode,'play');pressed=new Set([27]);step();assert.equal(c.mode,'pause');const before=c.world_time;pressed=new Set();step();assert.equal(c.world_time,before);pressed=new Set([27]);step();assert.equal(c.mode,'play');
console.log('PASS: single-arena menu navigation, play/pause control flow and JS-compatible draw syntax. GameMaker compiler and visuals still require PC verification.');

// Pursuit, obstacle routing, fixed melee warning, hit and dodge.
c.load_level(0);c.mode='play';
c.boss_cx=3;c.boss_cy=5;c.player_cx=3;c.player_cy=7;
c.move_boss();assert.notEqual(`${c.boss_cx},${c.boss_cy}`,'3,6','routes around wall');
assert(!c.is_wall(c.boss_cx,c.boss_cy));
c.boss_cx=6;c.boss_cy=4;c.player_cx=6;c.player_cy=6;
c.boss_move_timer=0;c.tick_combat(0.01);
assert.equal(c.boss_cy,5);assert.equal(c.boss_stage,'warn');assert(c.boss_melee);
const locked=JSON.stringify(c.boss_cells), bx=c.boss_cx, by=c.boss_cy;
c.try_move(1,0);c.tick_combat(0.2);
assert.equal(JSON.stringify(c.boss_cells),locked,'warning stays fixed');
assert.equal(c.boss_cx,bx);assert.equal(c.boss_cy,by,'boss stops while warning');
c.tick_combat(0.21);assert.equal(c.boss_stage,'strike');assert.equal(c.hp,5,'dodge avoids damage');
c.player_cx=6;c.player_cy=6;c.tick_combat(0.01);assert.equal(c.hp,4,'melee deals damage');
c.tick_combat(0.5);assert.equal(c.boss_stage,'recover');
c.tick_combat(1.01);assert.equal(c.boss_stage,'warn');assert(!c.boss_melee,'special follows melee');
c.load_level(0);c.mode='pause';const bossPosition=[c.boss_cx,c.boss_cy];c.tick_combat(1);
assert.deepEqual([c.boss_cx,c.boss_cy],bossPosition);
assert.equal(c.iso_x(1,0)-c.iso_x(0,0),24);
assert.equal(c.iso_x(0,1)-c.iso_x(0,0),-24);
assert.equal(c.iso_y(1,0)-c.iso_y(0,0),12);
console.log('PASS: isometric projection, wall routing, pursuit, fixed melee telegraph, dodge, damage, special transition and pause');
// Exercise the Draw event with recorded primitives to catch missing state/NaN coordinates.
Object.assign(c,{c_white:0xffffff,fa_left:0,fa_top:0,fa_center:1,font_title:1,font_body:2,font_small:3,mint:0xb7f278,muted:0x8dabA4,current_time:0,original_art:false});
c.boss_names=['Cross','Ring','Column','Row','Left','Right','Parity','Summon','Wave','Aim'];
c.make_color_rgb=(r,g,b)=>(r<<16)|(g<<8)|b;
for(const name of ['draw_set_alpha','draw_set_halign','draw_set_valign','draw_clear','draw_set_font','draw_set_colour','draw_text','draw_text_ext'])c[name]=()=>{};
let primitives=0;
for(const name of ['draw_line','draw_line_width','draw_circle','draw_triangle','draw_rectangle','draw_roundrect','draw_ellipse'])c[name]=(...args)=>{
  assert(args.every(v=>typeof v==='boolean'||Number.isFinite(v)),`${name} has invalid coordinates`);primitives++;
};
const draw=vm.runInContext('(function(){'+drawCode+'})',c);
c.load_level(0);c.mode='play';draw();
c.start_boss_melee();draw();c.boss_stage='strike';draw();c.boss_stage='recover';draw();
c.mode='pause';draw();assert(primitives>500);
console.log('PASS: Draw event executes for chase, melee warning, strike, recovery and pause with finite coordinates (simulated renderer)');
