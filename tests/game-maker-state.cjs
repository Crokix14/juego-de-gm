// Runs the JS-compatible GML state methods; does not compile or render GML.
const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const root = require('node:path').resolve(__dirname, '../PUZLE IDEA') + '/';
const c = {
  array_length: a => a.length, array_push: (a, v) => a.push(v), array_pop: a => a.pop(),
  clamp: (v, lo, hi) => Math.min(hi, Math.max(lo, v)), string_length: s => s.length,
  string_char_at: (s, i) => s[i - 1], string: String,
  ini_open() {}, ini_close() {}, ini_write_real() {}
};
vm.createContext(c);
vm.runInContext(fs.readFileSync(root + 'scripts/orbita_levels/orbita_levels.gml', 'utf8'), c);
c.levels = c.orbita_levels(); c.best = Array(c.levels.length).fill(0);
let code = fs.readFileSync(root + 'objects/Obj_orbita/Create_0.gml', 'utf8');
vm.runInContext(code.slice(code.indexOf('box_at ='), code.indexOf('// Draw existing sprites')), c);
const snapshot = () => ({cx:c.player_cx, cy:c.player_cy, boxes:c.boxes.map(b=>({...b})), key:c.has_key});
const restore = s => {c.player_cx=s.cx; c.player_cy=s.cy; c.boxes=s.boxes.map(b=>({...b})); c.has_key=s.key; c.moves=0; c.mode='play'; c.history=[];};
const hash = s => JSON.stringify([s.cx,s.cy,s.key,s.boxes.map(b=>`${b.cx},${b.cy}`).sort()]);
for (let level=0; level<c.levels.length; level++) {
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
console.log('PASS: X opens bars, undo closes bars, closed bars block boxes, door needs key. GML compilation remains unverified.');
