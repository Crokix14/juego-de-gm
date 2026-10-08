// Runs the JS-compatible GML state methods; does not compile or render GML.
const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const root = require('node:path').resolve(__dirname, '../PUZLE IDEA') + '/';
const c = {
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
vm.runInContext(code.slice(code.indexOf('box_at ='), code.indexOf('// Draw existing sprites')).replace(/\bmod\b/g, '%'), c);
const snapshot = () => ({cx:c.player_cx, cy:c.player_cy, boxes:c.boxes.map(b=>({...b})), key:c.has_key,sword:c.has_sword});
const restore = s => {c.player_cx=s.cx; c.player_cy=s.cy; c.boxes=s.boxes.map(b=>({...b})); c.has_key=s.key; c.has_sword=s.sword; c.moves=0; c.mode='play'; c.history=[];};
const hash = s => JSON.stringify([s.cx,s.cy,s.key,s.sword,s.boxes.map(b=>`${b.cx},${b.cy}`).sort()]);
for (let level=0; level<c.levels.length-1; level++) {
  c.load_level(level); c.mode='play';
  // Without activated X marks there is no route from spawn to the key.
  const queue=[[c.player_cx,c.player_cy]], reachable=new Set(queue.map(p=>p.join(',')));
  for(let i=0;i<queue.length;i++) for(const [dx,dy] of [[1,0],[-1,0],[0,1],[0,-1]]) {
    const [x,y]=queue[i], nx=x+dx, ny=y+dy, key=`${nx},${ny}`;
    if(!reachable.has(key) && !c.is_wall(nx,ny)){reachable.add(key);queue.push([nx,ny]);}
  }
  assert(!reachable.has(`${c.key_cx},${c.key_cy}`), 'key must be behind closed bars');
  const states=[{s:snapshot(),path:[]}], seen=new Set([hash(states[0].s)]); let solution;
  for(let i=0; i<states.length && !solution; i++) {
    const {s,path}=states[i];
    for(const d of [[1,0],[-1,0],[0,1],[0,-1]]) {
      restore(s); c.try_move(...d); if(c.moves===0) continue;
      const next=snapshot(), nextPath=[...path,d];
      if(c.mode==='win'){solution=nextPath;break;}
      const key=hash(next); if(seen.has(key))continue;seen.add(key);states.push({s:next,path:nextPath});
    }
    assert(states.length<200000,'solver state limit');
  }
  assert(solution,`chamber ${level+1} has a solution`);
  c.load_level(level); c.mode='play';
  for(const d of solution)c.try_move(...d);
  assert.equal(c.mode,'win');assert(c.has_key);assert.equal(c.moves,solution.length);
  c.undo_move();assert.equal(c.mode,'play');assert.equal(c.moves,solution.length-1);
  console.log(`PASS chamber ${level+1}: key behind bars, solution (${solution.length} moves), victory and undo`);
}
c.load_level(0);c.mode='play';
assert(c.is_wall(6,3)); c.try_move(1,0);c.try_move(1,0);
assert.equal(c.count_active(),1);assert(!c.is_wall(6,3));
c.undo_move();assert(c.is_wall(6,3));assert.equal(c.boxes[0].cx,4);
c.undo_move();assert.equal(c.boxes[0].cx,3);
// A box cannot be pushed into a wall or through a closed gate.
c.boxes=[{cx:5,cy:3}];c.player_cx=4;c.player_cy=3;c.moves=0;c.try_move(1,0);assert.equal(c.moves,0);
// Door depends on possession of the key, even if the bars later close.
c.load_level(0);c.player_cx=c.exit_cx-1;c.player_cy=c.exit_cy;c.mode='play';c.try_move(1,0);assert.equal(c.mode,'play');
c.player_cx=c.exit_cx-1;c.has_key=true;c.try_move(1,0);assert.equal(c.mode,'win');
console.log('PASS: 19 puzzle geometries, gates and undo. Live encounters tested separately; GML compilation remains unverified.');
// Damage, immunity, pause, death and resets.
c.load_level(5); c.mode='play';
const trap=c.traps.find(t=>t.kind==='H');c.player_cx=trap.cx;c.player_cy=trap.cy;
c.world_time=0;c.tick_combat(0.1);assert.equal(c.hp,5);
c.world_time=2.05;c.tick_combat(0.1);assert.equal(c.hp,4);
c.tick_combat(0.1);assert.equal(c.hp,4,'invulnerability prevents every-frame damage');
const time=c.world_time;c.mode='pause';c.tick_combat(1);assert.equal(c.world_time,time);
c.mode='play';c.hp=1;c.invulnerable=0;c.hurt_player(1);assert.equal(c.mode,'dead');c.undo_move();assert.equal(c.mode,'dead');
c.load_level(5);assert.equal(c.hp,5);assert.equal(c.world_time,0);
c.load_level(6);c.mode='play';const spike=c.traps.find(t=>t.kind==='S');c.player_cx=spike.cx;c.player_cy=spike.cy;c.tick_combat(0.1);assert.equal(c.hp,4);
// Patrol pursuit, player contact and boxing in an enemy.
c.load_level(7);c.mode='play';c.player_cx=9;c.player_cy=3;c.enemy_timer=0;c.tick_combat(0.1);assert.equal(c.enemies[0].cy,3);assert.equal(c.hp,4);
c.load_level(7);c.mode='play';const guard=c.enemies[0];c.boxes=[{cx:guard.cx-1,cy:guard.cy},{cx:guard.cx+1,cy:guard.cy},{cx:guard.cx,cy:guard.cy-1},{cx:guard.cx,cy:guard.cy+1}];c.enemy_timer=0;c.tick_combat(0.1);assert.equal(guard.cx,9);assert.equal(guard.cy,4);
// Sword pickup, no ranged hits, two hits per enemy and cooldown.
c.load_level(14);c.mode='play';assert(!c.has_sword);c.player_cx=c.sword_cx-1;c.player_cy=c.sword_cy;c.try_move(1,0);assert(c.has_sword);c.undo_move();assert(!c.has_sword);c.try_move(1,0);
c.player_cx=c.enemies[0].cx-1;c.player_cy=c.enemies[0].cy;c.attack();assert.equal(c.enemies[0].hp,1);c.attack();assert.equal(c.enemies[0].hp,1);c.attack_cooldown=0;c.attack();assert.equal(c.enemies[0].hp,0);
console.log('PASS: traps, immunity, death, pause, NPC pursuit and collision, sword pickup, undo, damage and cooldown');
// All ten boss patterns have safe tiles. Recoveries are the only damage windows.
c.load_level(19);c.mode='play';assert(c.boss_alive);assert.equal(c.key_cx,-1);
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
  c.boss_timer=0.85;c.build_boss_cells();
  const impact=c.boss_cells[0];c.player_cx=impact.cx;c.player_cy=impact.cy;c.hp=5;c.invulnerable=0;
  c.tick_combat(0.01);assert.equal(c.hp,4,`pattern ${pattern+1} deals damage on its marked tile`);
  c.player_cx=safe[0][0];c.player_cy=safe[0][1];
  if(pattern===8){c.boss_timer=0.8;c.build_boss_cells();assert(c.boss_cells.every(p=>Math.abs(p.cx-c.boss_cx)+Math.abs(p.cy-c.boss_cy)===1));c.boss_timer=0.2;c.build_boss_cells();assert(c.boss_cells.every(p=>Math.abs(p.cx-c.boss_cx)+Math.abs(p.cy-c.boss_cy)===3));}
  c.boss_timer=0;c.tick_combat(0.01);assert.equal(c.boss_stage,'recover');assert.equal(c.boss_cells.length,0);
  c.player_cx=c.boss_cx;c.player_cy=c.boss_cy+1;c.attack_cooldown=0;c.attack();assert.equal(c.boss_hp,90-pattern*10);
  c.attack_cooldown=0;c.attack();assert.equal(c.boss_hp,90-pattern*10,'only one hit per recovery');
  if(pattern<9){c.boss_timer=0;c.tick_combat(0.01);assert.equal(c.boss_pattern,pattern+1);assert.equal(c.boss_stage,'warn');}
}
assert.equal(signatures.size,10,'distinct boss danger patterns');assert(!c.boss_alive);assert.equal(c.key_cx,c.boss_cx);assert.equal(c.boss_hp,0);
c.try_move(0,-1);assert(c.has_key);c.player_cx=c.exit_cx;c.player_cy=c.exit_cy+1;c.try_move(0,-1);assert.equal(c.mode,'win');
console.log('PASS: 10 distinct telegraphs, safe cells, shields, summon, expanding wave, timed recovery, 100 HP, dropped key and campaign victory');
// Step/Draw syntax and menu/pause controls in this JS-compatible simulation.
const stepCode=fs.readFileSync(root+'objects/Obj_orbita/Step_0.gml','utf8').replace(/\bmod\b/g,'%').replace(/\bexit;/g,'return;');
const drawCode=fs.readFileSync(root+'objects/Obj_orbita/Draw_64.gml','utf8').replace(/\bmod\b/g,'%');new vm.Script('(function(){'+drawCode+'})');
c.delta_time=16667;c.lerp=(a,b,t)=>a+(b-a)*t;c.ord=s=>s.charCodeAt(0);c.vk_left=37;c.vk_up=38;c.vk_right=39;c.vk_down=40;c.vk_enter=13;c.vk_space=32;c.vk_escape=27;
let pressed=new Set();c.keyboard_check_pressed=k=>pressed.has(k);c.keyboard_check=k=>pressed.has(k);
const step=vm.runInContext('(function(){'+stepCode+'})',c);
c.load_level(19);c.mode='menu';pressed=new Set([37]);step();assert.equal(c.level_index,18);pressed=new Set([13]);step();assert.equal(c.mode,'play');pressed=new Set([27]);step();assert.equal(c.mode,'pause');const before=c.world_time;pressed=new Set();step();assert.equal(c.world_time,before);pressed=new Set([27]);step();assert.equal(c.mode,'play');
console.log('PASS: 20-level menu navigation, play/pause control flow and JS-compatible draw syntax. GameMaker compiler and visuals still require PC verification.');
