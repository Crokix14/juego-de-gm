(function(root){
  'use strict';
  const levels = [
    {name:'El primer paso',tip:'Recoge la llave dorada antes de llegar a la puerta.',map:['#########','#.......#','#.P...K.#','#..###..#','#.....E.#','#########']},
    {name:'Un poco de presión',tip:'Empuja la caja hasta el círculo verde. Las cajas se empujan, nunca se arrastran.',map:['#########','#.......#','#.PB.T..#','#..###..#','#.K...E.#','#########']},
    {name:'Dos a la vez',tip:'Todos los interruptores deben tener una caja al mismo tiempo.',map:['##########','#........#','#.PB..T..#','#........#','#..B..T..#','#.K....E.#','##########']},
    {name:'Cambio de dirección',tip:'Busca espacio para ponerte detrás de la caja. Deshacer también recupera la llave.',map:['#########','#...K...#','#..T....#','#.......#','#..B.#..#','#.P..#.E#','#.......#','#########']},
    {name:'La última cámara',tip:'Planea las dos rutas. Si una caja llega a una esquina, puedes deshacer sin límite.',map:['###########','#....#....#','#.T..#..T.#','#.........#','#.B.....B.#','#....#....#','#.P.K#..E.#','#.........#','###########']}
  ];
  const pos=(x,y)=>`${x},${y}`;
  function create(index){const level=levels[index],walls=[],targets=[],boxes=[];let player,key,exit;level.map.forEach((row,y)=>[...row].forEach((c,x)=>{const p=pos(x,y);if(c==='#')walls.push(p);if(c==='T')targets.push(p);if(c==='B')boxes.push(p);if(c==='P')player={x,y};if(c==='K')key=p;if(c==='E')exit=p;}));return {index,width:level.map[0].length,height:level.map.length,walls,targets,boxes,player,key,exit,hasKey:false,moves:0,won:false};}
  function unlocked(s){return s.hasKey&&s.targets.every(t=>s.boxes.includes(t));}
  function move(s,dx,dy){if(s.won||Math.abs(dx)+Math.abs(dy)!==1)return {state:s,changed:false,message:''};const x=s.player.x+dx,y=s.player.y+dy,p=pos(x,y);if(x<0||y<0||x>=s.width||y>=s.height||s.walls.includes(p))return {state:s,changed:false,message:'Un muro. Busca otro camino.'};const boxes=[...s.boxes];const i=boxes.indexOf(p);if(i>=0){const next=pos(x+dx,y+dy);if(x+dx<0||y+dy<0||x+dx>=s.width||y+dy>=s.height||s.walls.includes(next)||boxes.includes(next))return {state:s,changed:false,message:'No hay espacio para empujar esa caja.'};boxes[i]=next;}const n={...s,boxes,player:{x,y},moves:s.moves+1,hasKey:s.hasKey||p===s.key};n.won=p===s.exit&&unlocked(n);let message=i>=0?'Caja movida.': 'Encuentra tu camino.';if(!s.hasKey&&n.hasKey)message='¡Llave recogida!';if(p===s.exit&&!n.won)message=n.hasKey?'Coloca una caja en cada interruptor para abrir la puerta.':'Necesitas la llave para abrir la puerta.';if(n.won)message='¡Cámara superada!';return {state:n,changed:true,message,pushed:i>=0,collected:!s.hasKey&&n.hasKey};}
  const api={levels,create,move,unlocked,pos};if(typeof module!=='undefined')module.exports=api;else root.Puzzle=api;
})(typeof window!=='undefined'?window:globalThis);
