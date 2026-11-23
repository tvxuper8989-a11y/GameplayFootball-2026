"use strict";
(function(){
var app=document.getElementById("app");
var teamList=[
  {name:"ATLÉTICO DEL PLATA",short:"ADP",mark:"A",color:"#eaf9ff",accent:"#25bdec",level:83},
  {name:"UNIÓN METROPOLITANA",short:"UM",mark:"U",color:"#14202b",accent:"#e5be5c",level:81},
  {name:"CLUB DEL LITORAL",short:"CDL",mark:"C",color:"#e9fcff",accent:"#1ad7a9",level:78},
  {name:"DEPORTIVO NORTE",short:"DN",mark:"N",color:"#dfeaf9",accent:"#4977e8",level:79}
];
var namesHome=["LEIVA","GIMÉNEZ","ROJAS","PÉREZ","ARCE","DUARTE","ACOSTA","FERREYRA","MOLINA","ÁLVAREZ","SUÁREZ"];
var namesAway=["BENÍTEZ","MORENO","SOTO","SILVA","RAMÍREZ","GÓMEZ","REYES","CABRERA","LOPEZ","CASTRO","RUIZ"];
var formOptions=["4-3-3","4-4-2","3-5-2"];
var state={screen:"home",home:0,away:1,formation:"4-3-3",quality:"media",fps:60,camera:"TV",sound:true,game:null,keys:{},joy:{x:0,y:0,id:null},sprint:false,raf:0,last:0,drawLast:0,acc:0,modal:"",toast:"",toastEnd:0,fpsMeasure:0,fpsFrames:0,fpsLast:0};
function team(idx){return teamList[idx];}
function esc(s){return String(s).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;");}
function top(title,back){return '<div class="top"><button class="back" onclick="mobileBack()">❮</button><span class="title">'+title+'</span><span class="spacer"></span><span class="logo">GAMEPLAYFOOTBALL · 26/27</span></div>';}
function nav(){return '<div class="navbottom"><span>INICIO</span><span>JUGAR</span><b>FÚTBOL 2026 / 27</b><span>PLAN DE JUEGO</span><span>AJUSTES</span></div>';}
function kitSvg(){return '<svg viewBox="0 0 450 340" role="img" aria-label="Ilustración original de fútbol"><defs><linearGradient id="shirt" x2="1" y2="1"><stop stop-color="#15a7d8"/><stop offset=".4" stop-color="#dbf8ff"/><stop offset="1" stop-color="#1987b0"/></linearGradient><linearGradient id="ball" x2="1" y2="1"><stop stop-color="#e8ffff"/><stop offset="1" stop-color="#449cba"/></linearGradient></defs><ellipse cx="225" cy="291" rx="180" ry="24" fill="#00d2ae" opacity=".16"/><path d="M125 110L182 81L209 110L238 110L268 81L329 111L387 162L336 228L293 199L293 310L160 310L160 199L117 229L63 162Z" fill="url(#shirt)" stroke="#8bfbed" stroke-width="6"/><path d="M172 119L217 155L262 119" fill="none" stroke="#08314c" stroke-width="11"/><path d="M201 162L201 300M250 162L250 300" stroke="#0c4f74" stroke-width="9" opacity=".35"/><circle cx="223" cy="211" r="35" fill="none" stroke="#053e53" stroke-width="7"/><text x="222" y="224" font-size="28" font-weight="900" fill="#053e53" text-anchor="middle">GF</text><circle cx="347" cy="257" r="48" fill="url(#ball)" stroke="#fff" stroke-width="4"/><path d="M346 229L365 245L358 272L334 272L322 249Z" fill="#07374f"/><path d="M346 229L337 214M365 245L389 240M358 272L371 293M334 272L325 295M322 249L304 237" stroke="#164963" stroke-width="5"/></svg>';}
function stopFrame(){if(state.raf) cancelAnimationFrame(state.raf);state.raf=0;state.game=null;state.keys={};state.joy={x:0,y:0,id:null};state.sprint=false;state.modal="";}
function go(name){if(name!=="match")stopFrame();state.screen=name;render();}
function home(){return '<div class="screen stadium">'+top("GAMEPLAYFOOTBALL 2026 / 27")+
'<div class="homehero"><div class="homeleft"><div class="eyebrow">FÚTBOL · TEMPORADA 2026/27</div><div class="huge">TU CANCHA.<br><em>TU PARTIDO.</em></div><div class="home-desc">Viví el fútbol en tu celular. Elegí equipo, armá tu estrategia y jugá un partido con controles táctiles.</div><div class="homebuttons"><button class="cta" onclick="go(\'modes\')">⚽ JUGAR AHORA</button><button class="cta ghost" onclick="go(\'formation\')">PLAN DE JUEGO</button><button class="cta ghost" onclick="go(\'settings\')">AJUSTES</button></div></div><div class="podium">'+kitSvg()+'<div class="floattag">NUEVA TEMPORADA</div></div></div>'+nav()+'</div>';}
function modes(){
 var list=[
  ["PARTIDO RÁPIDO","Empezá a jugar contra el equipo rival.","⚽",""],
  ["CARA A CARA","Duelo local contra la inteligencia artificial.","VS","cyan"],
  ["MODO ENTRENAMIENTO","Practicá controles y disparos.","★",""],
  ["PLANES DE JUEGO","Elegí la táctica y la formación.","▦","cyan"]
 ];
 var items=list.map(function(v,i){return '<button class="card" onclick="'+(i===3?"go('formation')":"go('teams')")+'"><header class="'+(i%2?"blue":"")+'">'+v[0]+'</header><div class="art"><div class="symbol '+v[3]+'">'+v[2]+'</div></div><div class="cardfoot">'+v[1]+'</div></button>';}).join("");
 return '<div class="screen stadium">'+top("JUGAR")+ '<div class="content"><div class="cards">'+items+'</div></div></div>';
}
function crest(idx){var t=team(idx);return '<div class="crest '+(idx%2?"gold":"blue")+'" style="color:'+t.accent+'">'+t.mark+'</div>';}
function teams(){
 return '<div class="screen stadium">'+top("SELECCIÓN DE EQUIPOS")+
 '<div class="teamselect"><div class="teamcard">'+crest(state.home)+'<h2>'+team(state.home).name+'</h2><p>LOCAL · NIVEL '+team(state.home).level+'</p><div class="team-actions"><button class="cta ghost" onclick="changeTeam(0,-1)">◀</button><button class="cta ghost" onclick="changeTeam(0,1)">▶</button></div></div>'+
 '<div class="vs">VS.</div><div class="teamcard">'+crest(state.away)+'<h2>'+team(state.away).name+'</h2><p>VISITANTE · NIVEL '+team(state.away).level+'</p><div class="team-actions"><button class="cta ghost" onclick="changeTeam(1,-1)">◀</button><button class="cta ghost" onclick="changeTeam(1,1)">▶</button></div></div></div>'+
 '<div class="bottomactions"><button class="cta" onclick="go(\'formation\')">CONTINUAR A LA ALINEACIÓN ❯</button></div></div>';
}
function changeTeam(side,dir){var id=side===0?"home":"away",other=side===0?"away":"home";var val=state[id];for(var i=0;i<teamList.length;i++){val=(val+dir+teamList.length)%teamList.length;if(val!==state[other])break;}state[id]=val;render();}
function formLocs(){
 if(state.formation==="4-4-2") return [[8,50],[25,13],[25,37],[25,63],[25,87],[52,13],[52,37],[52,63],[52,87],[79,34],[79,66]];
 if(state.formation==="3-5-2") return [[8,50],[25,25],[25,50],[25,75],[51,8],[51,29],[51,50],[51,71],[51,92],[79,34],[79,66]];
 return [[8,50],[25,13],[25,37],[25,63],[25,87],[53,22],[53,50],[53,78],[79,13],[79,50],[79,87]];
}
function formBtn(n){return '<button class="cta '+(state.formation===n?"":"ghost")+'" onclick="pickFormation(\''+n+'\')">'+n+'</button>';}
function formation(){
 var loc=formLocs(),html='';
 for(var i=0;i<loc.length;i++){
  html+='<div class="playercard" style="left:'+loc[i][0]+'%;top:'+loc[i][1]+'%"><strong>'+(i===0?"POR":i<5?"DEF":i<8?"MC":"DEL")+' '+(74+i%5*2)+'</strong><div class="face"></div><span>'+namesHome[i]+'</span></div>';
 }
 return '<div class="screen">'+top("PLAN DE JUEGO")+
 '<div class="content"><div class="prestage"><div class="formationboard"><div class="pitchdiagram">'+html+'</div></div><div class="sidepanel"><div class="eyebrow">ESQUEMA TÁCTICO</div><h2>'+state.formation+'</h2><p>Elegí cómo se distribuyen tus jugadores. Esta formación también se aplica al partido.</p><div class="team-actions">'+formOptions.map(formBtn).join("")+'</div><div class="statrow"><span>ATAQUE</span><div class="statbar"><i style="width:83%"></i></div></div><div class="statrow"><span>MEDIO</span><div class="statbar"><i style="width:78%"></i></div></div><div class="statrow"><span>DEFENSA</span><div class="statbar"><i style="width:81%"></i></div></div><button class="cta" onclick="go(\'intro\')">CONFIRMAR EQUIPO ❯</button></div></div></div></div>';
}
function pickFormation(n){state.formation=n;render();}
function intro(){
 return '<div class="screen stadium">'+top("CARA A CARA")+
 '<div class="introcenter"><div class="introteam"><div class="kitfigure"></div>'+crest(state.home)+'<h2>'+team(state.home).name+'</h2><p>LOCAL</p></div>'+
 '<div class="introdetails"><div class="eyebrow">ESTADIO METROPOLITANO</div><h1>VS.</h1><p>PARTIDO DE EXHIBICIÓN</p><div class="pill">'+state.formation+'</div><button class="cta" onclick="startMatch()">▶ COMENZAR PARTIDO</button></div>'+
 '<div class="introteam"><div class="kitfigure away"></div>'+crest(state.away)+'<h2>'+team(state.away).name+'</h2><p>VISITANTE</p></div></div></div>';
}
function settingRow(label,opts,selected,method){
 return '<div class="settingrow"><strong>'+label+'</strong><div class="team-actions">'+opts.map(function(n){return '<button class="'+(selected===n?"selected":"")+'" onclick="'+method+'(\''+n+'\')">'+n+'</button>';}).join("")+'</div></div>';
}
function settings(){
 return '<div class="screen">'+top("CONFIGURACIÓN")+
 '<div class="setup"><h2>RENDIMIENTO Y CONTROLES</h2><p>Los FPS son un límite solicitado: el rendimiento depende del teléfono.</p>'+
 settingRow("Límite de FPS",["30","60","120"],String(state.fps),"setFPS")+
 settingRow("Calidad de renderizado",["baja","media","alta"],state.quality,"setQuality")+
 settingRow("Cámara de partido",["TV","AMPLIA","DINÁMICA"],state.camera,"setCamera")+
 '<p class="advice">Controles táctiles: joystick izquierdo para moverse; PASE, REMATE, CAMBIAR y CORRER a la derecha. También compatible con flechas, S, D, Q y E.</p><button class="cta" onclick="go(\'home\')">GUARDAR Y VOLVER</button></div></div>';
}
function setFPS(v){state.fps=Number(v);persist();render();}
function setQuality(v){state.quality=v;persist();render();}
function setCamera(v){state.camera=v;persist();if(state.screen!=="match")render();}
function persist(){try{localStorage.setItem("gfmobile",JSON.stringify({fps:state.fps,quality:state.quality,camera:state.camera}));}catch(e){}}
function restore(){try{var v=JSON.parse(localStorage.getItem("gfmobile")||"{}");if([30,60,120].indexOf(v.fps)>=0)state.fps=v.fps;if(["baja","media","alta"].indexOf(v.quality)>=0)state.quality=v.quality;if(["TV","AMPLIA","DINÁMICA"].indexOf(v.camera)>=0)state.camera=v.camera;}catch(e){}}
function matchHTML(){
 return '<div id="matchscreen" class="screen"><canvas id="game"></canvas>'+
 '<div class="hud scoreboard"><div class="badge">'+team(state.home).short+'</div><div class="score"><span id="homeScore">0</span><span>:</span><span id="awayScore">0</span></div><div class="badge">'+team(state.away).short+'</div><div class="timer" id="clock">00:00</div></div>'+
 '<div class="hud hudright"><button id="fpstxt">FPS --</button><button onclick="cycleCamera()">CÁMARA</button><button onclick="openTactics()">'+state.formation+' ▾</button><button onclick="pauseGame()">☰</button></div>'+
 '<div class="pad" id="pad"><div class="padknob" id="knob"></div></div>'+
 '<div class="actions"><button class="action shoot" id="shootBtn" onclick="shootBall()">REMATE</button><button class="action pass" onclick="passBall()">PASE</button><button class="action switch" onclick="switchPlayer()">CAMBIAR</button><button class="action sprint" id="sprintBtn">CORRER</button></div>'+
 '<div id="toast" class="toast hide"></div><div id="overlay" class="overlay hide"></div></div>';
}
function render(){
 if(state.screen==="home")app.innerHTML=home();
 else if(state.screen==="modes")app.innerHTML=modes();
 else if(state.screen==="teams")app.innerHTML=teams();
 else if(state.screen==="formation")app.innerHTML=formation();
 else if(state.screen==="intro")app.innerHTML=intro();
 else if(state.screen==="settings")app.innerHTML=settings();
 else if(state.screen==="match")app.innerHTML=matchHTML();
 else if(state.screen==="result")app.innerHTML=results();
}
function results(){
 var g=state.result||{score:[0,0]};
 return '<div class="screen stadium">'+top("FINAL DEL PARTIDO")+
 '<div class="introcenter"><div class="introteam">'+crest(state.home)+'<h2>'+team(state.home).name+'</h2></div>'+
 '<div class="introdetails"><div class="eyebrow">RESULTADO FINAL</div><h1>'+g.score[0]+' - '+g.score[1]+'</h1><p>'+((g.score[0]===g.score[1])?"EMPATE":(g.score[0]>g.score[1]?"VICTORIA LOCAL":"VICTORIA VISITANTE"))+'</p><button class="cta" onclick="startMatch()">REVANCHA</button><button class="cta ghost" onclick="go(\'home\')">VOLVER AL INICIO</button></div>'+
 '<div class="introteam">'+crest(state.away)+'<h2>'+team(state.away).name+'</h2></div></div></div>';
}
function startMatch(){
 stopFrame();state.screen="match";state.acc=0;state.last=0;state.drawLast=0;state.fpsLast=0;state.fpsFrames=0;render();
 var g={players:[],ball:{x:-1,y:0,vx:0,vy:0,owner:-1},score:[0,0],clock:0,selected:9,paused:false,goalDelay:0,enemyDecision:0,finished:false};
 var homeX=[-49,-33,-33,-33,-33,-16,-16,-16,-3,-3,-3],homeY=[0,-24,-8,8,24,-19,0,19,-20,0,20];
 for(var t=0;t<2;t++){
  for(var i=0;i<11;i++){
   var x=t===0?homeX[i]:-homeX[i],y=t===0?homeY[i]:-homeY[i];
   g.players.push({team:t,i:i,x:x,y:y,homeX:x,homeY:y,vx:0,vy:0,hasBall:false});
  }
 }
 g.players[9].x=-3;g.players[9].y=0;g.ball.owner=9;
 state.game=g;setupInput();state.raf=requestAnimationFrame(frame);
}
function setupInput(){
 var pad=document.getElementById("pad"),knob=document.getElementById("knob"),sprint=document.getElementById("sprintBtn");
 function setJoy(e){
  var r=pad.getBoundingClientRect(),cx=r.left+r.width/2,cy=r.top+r.height/2;
  var dx=(e.clientX-cx)/(r.width*.30),dy=(e.clientY-cy)/(r.height*.30);
  var mag=Math.hypot(dx,dy);if(mag>1){dx/=mag;dy/=mag;}
  state.joy.x=dx;state.joy.y=dy;
  knob.style.transform="translate("+(dx*53)+"%, "+(dy*53)+"%)";
 }
 pad.addEventListener("pointerdown",function(e){e.preventDefault();if(state.joy.id!==null)return;state.joy.id=e.pointerId;pad.setPointerCapture(e.pointerId);setJoy(e);});
 pad.addEventListener("pointermove",function(e){if(state.joy.id===e.pointerId)setJoy(e);});
 function endJoy(e){if(state.joy.id===e.pointerId){state.joy.id=null;state.joy.x=0;state.joy.y=0;knob.style.transform="translate(0,0)";}}
 pad.addEventListener("pointerup",endJoy);pad.addEventListener("pointercancel",endJoy);pad.addEventListener("lostpointercapture",endJoy);
 sprint.addEventListener("pointerdown",function(e){e.preventDefault();state.sprint=true;sprint.setPointerCapture(e.pointerId);});
 function stopSprint(){state.sprint=false;}
 sprint.addEventListener("pointerup",stopSprint);sprint.addEventListener("pointercancel",stopSprint);sprint.addEventListener("lostpointercapture",stopSprint);
 resizeCanvas();
}
function resizeCanvas(){
 var c=document.getElementById("game");if(!c)return;
 var r=c.getBoundingClientRect(),factor=Math.min(1.5,window.devicePixelRatio||1);
 var w=Math.max(100,Math.round(r.width*factor)),h=Math.max(100,Math.round(r.height*factor));
 if(c.width!==w||c.height!==h){c.width=w;c.height=h;}
}
function frame(now){
 if(state.screen!=="match"||!state.game){state.raf=0;return;}
 if(!state.last)state.last=now;
 var dt=Math.max(0,Math.min(.04,(now-state.last)/1000));state.last=now;
 if(!state.game.paused){
  state.acc+=dt;var n=0;
  while(state.acc>=1/60&&n<5){step(1/60);state.acc-=1/60;n++;}
 }
 if(now-state.drawLast>=1000/Math.max(30,state.fps)-1){
  drawGame();state.drawLast=now;state.fpsFrames++;
 }
 if(!state.fpsLast)state.fpsLast=now;
 if(now-state.fpsLast>750){
  state.fpsMeasure=Math.round(state.fpsFrames*1000/(now-state.fpsLast));
  var p=document.getElementById("fpstxt");
  if(p)p.textContent="FPS "+state.fpsMeasure;
  state.fpsFrames=0;state.fpsLast=now;
 }
 if(state.game&&!state.game.finished)state.raf=requestAnimationFrame(frame);
 else state.raf=0;
}
function nearestPlayers(teamId,x,y,omit){
 var best=null,bd=Infinity,g=state.game;
 if(!g)return null;
 g.players.forEach(function(p){if(p.team!==teamId||p===omit)return;
  var dist=Math.hypot(p.x-x,p.y-y);
  if(dist<bd){bd=dist;best=p;}
 });
 return best;
}
function ownPlayer(){return state.game&&state.game.players[state.game.selected];}
function inputVec(){
 var k=state.keys,x=state.joy.x,y=state.joy.y;
 if(k.ArrowLeft)x-=1;if(k.ArrowRight)x+=1;
 if(k.ArrowUp)y-=1;if(k.ArrowDown)y+=1;
 var len=Math.hypot(x,y);if(len>1){x/=len;y/=len;}
 return {x:x,y:y};
}
function closeTo(p,b){return Math.hypot(p.x-b.x,p.y-b.y);}
function moveTo(p,x,y,dt,speed){
 var dx=x-p.x,dy=y-p.y,d=Math.hypot(dx,dy);
 if(d>.08){var dist=Math.min(d,speed*dt);p.x+=dx/d*dist;p.y+=dy/d*dist;}
 p.x=Math.max(-50,Math.min(50,p.x));p.y=Math.max(-32,Math.min(32,p.y));
}
function step(dt){
 var g=state.game;if(!g)return;
 if(g.goalDelay>0){g.goalDelay-=dt;if(g.goalDelay<=0){resetKickoff();}return;}
 g.clock+=dt*35;
 if(g.clock>=5400){g.clock=5400;finishGame();return;}
 var me=ownPlayer(),vec=inputVec(),spd=(state.sprint||state.keys.e||state.keys.Shift?13:8.6);
 me.x=Math.max(-50,Math.min(50,me.x+vec.x*spd*dt));
 me.y=Math.max(-32,Math.min(32,me.y+vec.y*spd*dt));
 var b=g.ball;
 if(b.owner>=0){
   var holder=g.players[b.owner];
   b.x=holder.x+(holder.team===0?1.4:-1.4);b.y=holder.y+.45;
 }
 var threat0=nearestPlayers(0,b.x,b.y,me);
 var threat1=nearestPlayers(1,b.x,b.y,null);
 for(var i=0;i<g.players.length;i++){
   var p=g.players[i];if(p===me)continue;
   var bx=p.homeX,by=p.homeY;
   if(p.team===0){
     if(p===threat0&&b.owner<0){bx=b.x;by=b.y;}
     else if(b.owner>=11&&p===threat0){bx=b.x;by=b.y;}
     else{bx+=Math.max(-12,Math.min(12,(b.x+12)*.18));by+=Math.max(-6,Math.min(6,b.y*.17));}
   }else{
     if(p===threat1&&(b.owner<0||b.owner<11)){bx=b.x;by=b.y;}
     else if(b.owner===i){bx=-48;by=b.y*.65;}
     else{bx+=Math.max(-13,Math.min(13,(b.x-12)*.21));by+=Math.max(-7,Math.min(7,b.y*.19));}
   }
   if(p.i===0){bx=p.team===0?-49:49;by=Math.max(-7,Math.min(7,b.y*.38));}
   moveTo(p,bx,by,dt,p===threat1?9.5:6.6);
 }
 if(b.owner<0){
   b.x+=b.vx*dt;b.y+=b.vy*dt;
   b.vx*=Math.pow(.987,dt*60);b.vy*=Math.pow(.987,dt*60);
   if(Math.abs(b.y)>33.7){b.y=Math.sign(b.y)*33.7;b.vy*=-.4;}
   if(Math.abs(b.x)>52.5){
      if(Math.abs(b.y)<7.5){scoreGoal(b.x>0?0:1);return;}
      b.x=Math.sign(b.x)*52;b.vx*=-.55;
   }
   if(Math.hypot(b.vx,b.vy)<.25){b.vx=0;b.vy=0;}
   var closest=null,dd=1.7;
   g.players.forEach(function(p){var d=closeTo(p,b);if(d<dd){dd=d;closest=p;}});
   if(closest){b.owner=g.players.indexOf(closest);g.enemyDecision=0;}
 }else{
   var holder=g.players[b.owner];
   if(holder.team===1){
    g.enemyDecision+=dt;
    if(holder.x< -28&&Math.abs(holder.y)<21&&g.enemyDecision>1.1){aiShoot(holder);g.enemyDecision=0;}
    else if(g.enemyDecision>2.5){aiPass(holder);g.enemyDecision=0;}
   }
   var nearestOpponent=nearestPlayers(holder.team===0?1:0,holder.x,holder.y,null);
   if(nearestOpponent&&Math.hypot(nearestOpponent.x-holder.x,nearestOpponent.y-holder.y)<1.15){
      if(Math.random()<dt*.8){b.owner=-1;b.vx=holder.team===0?-8:8;b.vy=(Math.random()-.5)*15;}
   }
 }
 var c=document.getElementById("clock");if(c)c.textContent=clockString(g.clock);
}
function aiShoot(holder){var b=state.game.ball;b.owner=-1;var v=43,dy=(0-holder.y)*.35+(Math.random()-.5)*8;var d=Math.hypot(-48,dy);b.vx=-48/d*v;b.vy=dy/d*v;}
function aiPass(holder){var b=state.game.ball,p=nearestPlayers(1,holder.x-8,holder.y,holder);if(!p){aiShoot(holder);return;}var dx=p.x-holder.x,dy=p.y-holder.y,d=Math.hypot(dx,dy)||1;b.owner=-1;b.vx=dx/d*25;b.vy=dy/d*25;}
function hasBall(){var g=state.game,p=ownPlayer();return g&&p&&(g.ball.owner===g.selected||g.ball.owner<0&&closeTo(p,g.ball)<2.5);}
function passBall(){
 var g=state.game;if(!g||g.paused||!hasBall())return;
 var p=ownPlayer(),b=g.ball,chosen=null,weight=1e9;
 g.players.forEach(function(t){if(t.team!==0||t===p)return;var dx=t.x-p.x,dy=t.y-p.y,d=Math.hypot(dx,dy);var w=d+(dx<0?16:0);if(w<weight){weight=w;chosen=t;}});
 if(!chosen)return;
 var dx=chosen.x-p.x,dy=chosen.y-p.y,dist=Math.hypot(dx,dy)||1;
 b.x=p.x+dx/dist*2;b.y=p.y+dy/dist*2;b.owner=-1;b.vx=dx/dist*29;b.vy=dy/dist*29;
 notice("PASE A "+namesHome[chosen.i]);
}
function shootBall(){
 var g=state.game;if(!g||g.paused||!hasBall())return;
 var p=ownPlayer(),b=g.ball;var dx=53-p.x,dy=-p.y*.72+(Math.random()-.5)*5.5,dist=Math.hypot(dx,dy)||1;
 b.x=p.x+1.5;b.y=p.y;b.owner=-1;b.vx=dx/dist*53;b.vy=dy/dist*53;notice("¡REMATE!");
}
function switchPlayer(){
 var g=state.game;if(!g||g.paused)return;
 var ball=g.ball,candidates=g.players.filter(function(p){return p.team===0&&p.i!==0&&g.players.indexOf(p)!==g.selected;});
 candidates.sort(function(a,b){return closeTo(a,ball)-closeTo(b,ball);});
 if(candidates.length){g.selected=g.players.indexOf(candidates[0]);notice(namesHome[candidates[0].i]);}
}
function clockString(s){s=Math.min(5400,Math.max(0,Math.floor(s)));var m=Math.floor(s/60);return (m<10?"0":"")+m+":"+(s%60<10?"0":"")+s%60;}
function scoreGoal(teamId){
 var g=state.game;g.score[teamId]++;g.goalDelay=1.6;g.ball.owner=-1;g.ball.vx=0;g.ball.vy=0;
 document.getElementById("homeScore").textContent=g.score[0];document.getElementById("awayScore").textContent=g.score[1];
 notice("¡GOOOL! "+team(teamId===0?state.home:state.away).short,1600);
}
function resetKickoff(){var g=state.game;g.players.forEach(function(p){p.x=p.homeX;p.y=p.homeY;});
 g.ball.x=-1;g.ball.y=0;g.ball.vx=0;g.ball.vy=0;g.ball.owner=9;g.goalDelay=0;g.selected=9;
}
function finishGame(){var g=state.game;if(!g||g.finished)return;g.finished=true;state.result={score:g.score.slice()};setTimeout(function(){if(state.screen==="match")go("result");},400);}
function notice(msg,ms){var el=document.getElementById("toast");if(!el)return;el.textContent=msg;el.classList.remove("hide");state.toastEnd=performance.now()+(ms||850);setTimeout(function(){if(performance.now()>=state.toastEnd-25&&el.parentNode)el.classList.add("hide");},ms||850);}
function cycleCamera(){var arr=["TV","AMPLIA","DINÁMICA"],n=(arr.indexOf(state.camera)+1)%arr.length;state.camera=arr[n];persist();notice("CÁMARA: "+state.camera);}
function pauseGame(){var g=state.game;if(!g)return;g.paused=true;state.modal="pause";var el=document.getElementById("overlay");el.classList.remove("hide");el.innerHTML='<div class="modal"><div class="eyebrow">PAUSA</div><h2>PARTIDO EN CURSO</h2><p>'+team(state.home).short+' '+g.score[0]+' - '+g.score[1]+' '+team(state.away).short+'</p><button class="cta" onclick="closeModal()">CONTINUAR</button><button class="cta ghost" onclick="openTactics()">TÁCTICA</button><button class="cta ghost" onclick="cycleCamera()">CAMBIAR CÁMARA</button><button class="cta danger" onclick="go(\'home\')">SALIR DEL PARTIDO</button></div>';}
function openTactics(){
 var g=state.game;if(!g)return;g.paused=true;state.modal="tactics";
 var el=document.getElementById("overlay");el.classList.remove("hide");
 el.innerHTML='<div class="modal"><div class="eyebrow">PLAN DE JUEGO</div><h2>FORMACIÓN '+state.formation+'</h2><p>Cambiá tu distribución. Los movimientos del equipo se ajustarán a la nueva táctica.</p><div class="team-actions" style="justify-content:center">'+formOptions.map(function(n){return '<button class="cta '+(state.formation===n?"":"ghost")+'" onclick="tacticInGame(\''+n+'\')">'+n+'</button>';}).join("")+'</div><br><button class="cta" onclick="closeModal()">VOLVER AL PARTIDO</button></div>';
}
function tacticInGame(n){
 state.formation=n;
 var g=state.game;if(g){var baseX=[-49,-33,-33,-33,-33,-16,-16,-16,-3,-3,-3],baseY=[0,-24,-8,8,24,-19,0,19,-20,0,20];
 if(n==="4-4-2"){baseX=[-49,-32,-32,-32,-32,-13,-13,-13,-13,-3,-3];baseY=[0,-24,-8,8,24,-24,-8,8,24,-10,10];}
 if(n==="3-5-2"){baseX=[-49,-31,-31,-31,-15,-15,-15,-15,-15,-3,-3];baseY=[0,-20,0,20,-26,-13,0,13,26,-10,10];}
 g.players.forEach(function(p){p.homeX=(p.team===0?1:-1)*baseX[p.i];p.homeY=(p.team===0?1:-1)*baseY[p.i];});}
 openTactics();
}
function closeModal(){var g=state.game;if(g)g.paused=false;state.modal="";var el=document.getElementById("overlay");if(el){el.classList.add("hide");el.innerHTML="";}}
function mobileBack(){
 if(state.screen==="match"){if(state.modal)closeModal();else pauseGame();return;}
 if(state.screen==="home")return;
 if(state.screen==="settings")go("home");
 else if(state.screen==="modes")go("home");
 else if(state.screen==="teams")go("modes");
 else if(state.screen==="formation")go("teams");
 else if(state.screen==="intro")go("formation");
 else go("home");
}
function rounded(ctx,x,y,w,h,r){
 ctx.beginPath();ctx.moveTo(x+r,y);ctx.lineTo(x+w-r,y);ctx.quadraticCurveTo(x+w,y,x+w,y+r);ctx.lineTo(x+w,y+h-r);
 ctx.quadraticCurveTo(x+w,y+h,x+w-r,y+h);ctx.lineTo(x+r,y+h);ctx.quadraticCurveTo(x,y+h,x,y+h-r);
 ctx.lineTo(x,y+r);ctx.quadraticCurveTo(x,y,x+r,y);ctx.closePath();
}
function drawGame(){
 var g=state.game,c=document.getElementById("game");if(!c||!g)return;
 var ctx=c.getContext("2d",{alpha:false});if(!ctx)return;
 var W=c.width,H=c.height,pix=Math.min(1.5,window.devicePixelRatio||1),cw=W/pix,ch=H/pix;
 ctx.setTransform(pix,0,0,pix,0,0);ctx.clearRect(0,0,cw,ch);
 var grad=ctx.createLinearGradient(0,0,0,ch);grad.addColorStop(0,"#142735");grad.addColorStop(.2,"#1d3c40");grad.addColorStop(1,"#13282c");ctx.fillStyle=grad;ctx.fillRect(0,0,cw,ch);
 // Stadium stands and soft lights outside the playing field.
 ctx.fillStyle="#233c42";ctx.fillRect(0,0,cw,ch*.07);ctx.fillRect(0,ch*.94,cw,ch*.06);
 var scale=Math.min(cw/114,ch/72)*(state.camera==="DINÁMICA"?1.22:state.camera==="TV"?1.1:1.0);
 var panX=state.camera==="DINÁMICA"?-g.ball.x*scale*.4:state.camera==="TV"?-g.ball.x*scale*.11:0;
 var panY=state.camera==="DINÁMICA"?-g.ball.y*scale*.25:0;
 var cx=cw/2+panX,cy=ch/2+panY;
 function X(x){return cx+x*scale;}function Y(y){return cy+y*scale;}
 ctx.save();ctx.beginPath();ctx.rect(0,0,cw,ch);ctx.clip();
 ctx.fillStyle="#1e713a";ctx.fillRect(X(-52.5),Y(-34),105*scale,68*scale);
 for(var k=0;k<14;k++){ctx.fillStyle=k%2?"rgba(114,208,92,.09)":"rgba(5,37,18,.12)";ctx.fillRect(X(-52.5+k*7.5),Y(-34),7.5*scale,68*scale);}
 var fieldLine=Math.max(1.2,scale*.12);
 ctx.strokeStyle="#daf8e5";ctx.lineWidth=fieldLine;
 ctx.strokeRect(X(-52.5),Y(-34),105*scale,68*scale);
 ctx.beginPath();ctx.moveTo(X(0),Y(-34));ctx.lineTo(X(0),Y(34));ctx.stroke();
 ctx.beginPath();ctx.arc(X(0),Y(0),9.15*scale,0,Math.PI*2);ctx.stroke();
 ctx.fillStyle="#ebffef";ctx.beginPath();ctx.arc(X(0),Y(0),.18*scale,0,Math.PI*2);ctx.fill();
 ctx.strokeRect(X(-52.5),Y(-20.16),16.5*scale,40.32*scale);
 ctx.strokeRect(X(36),Y(-20.16),16.5*scale,40.32*scale);
 ctx.strokeRect(X(-52.5),Y(-9.16),5.5*scale,18.32*scale);
 ctx.strokeRect(X(47),Y(-9.16),5.5*scale,18.32*scale);
 ctx.fillStyle="rgba(235,250,255,.8)";
 ctx.beginPath();ctx.arc(X(-41.5),Y(0),.22*scale,0,Math.PI*2);ctx.arc(X(41.5),Y(0),.22*scale,0,Math.PI*2);ctx.fill();
 ctx.strokeStyle="#e6fcff";ctx.strokeRect(X(-55),Y(-7.3),2.5*scale,14.6*scale);ctx.strokeRect(X(52.5),Y(-7.3),2.5*scale,14.6*scale);
 if(state.quality!=="baja"){ctx.strokeStyle="rgba(235,255,255,.20)";ctx.lineWidth=.7;for(var n=-7;n<=7;n+=2){ctx.beginPath();ctx.moveTo(X(-55),Y(n));ctx.lineTo(X(-52.5),Y(n));ctx.moveTo(X(52.5),Y(n));ctx.lineTo(X(55),Y(n));ctx.stroke();}}
 // Shadows and players
 g.players.forEach(function(p,idx){
  var x=X(p.x),y=Y(p.y),r=Math.max(3.5,scale*.84);
  ctx.fillStyle="rgba(0,0,0,.22)";ctx.beginPath();ctx.ellipse(x+2,y+r*.8,r*1.0,r*.38,0,0,Math.PI*2);ctx.fill();
  ctx.fillStyle=p.team===0?"#e6f9fc":"#101d28";ctx.strokeStyle=p.team===0?"#16b8df":"#dfb75d";ctx.lineWidth=Math.max(1.5,scale*.22);
  ctx.beginPath();ctx.arc(x,y,r,0,Math.PI*2);ctx.fill();ctx.stroke();
  ctx.fillStyle=p.team===0?"#13394d":"#f5dd91";ctx.textAlign="center";ctx.textBaseline="middle";ctx.font="bold "+Math.max(7,scale*.75)+"px Arial";ctx.fillText(String(p.i+1),x,y+.2);
  if(idx===g.selected){
   ctx.strokeStyle="#4cfff0";ctx.lineWidth=2;ctx.beginPath();ctx.arc(x,y,r*1.35,0,Math.PI*2);ctx.stroke();
   ctx.fillStyle="#66ffef";ctx.beginPath();ctx.moveTo(x,y-r*2.8);ctx.lineTo(x-r*.6,y-r*1.8);ctx.lineTo(x+r*.6,y-r*1.8);ctx.closePath();ctx.fill();
   ctx.font="bold "+Math.max(9,scale*.88)+"px Arial";ctx.fillStyle="#eaffff";
   ctx.shadowColor="#071827";ctx.shadowBlur=6;ctx.fillText(namesHome[p.i],x,y-r*3.5);ctx.shadowBlur=0;
  }
 });
 var b=g.ball,ballR=Math.max(3,scale*.37);
 ctx.fillStyle="#fff";ctx.strokeStyle="#1e3540";ctx.lineWidth=1;
 ctx.beginPath();ctx.arc(X(b.x),Y(b.y),ballR,0,Math.PI*2);ctx.fill();ctx.stroke();
 ctx.fillStyle="#192630";ctx.beginPath();ctx.arc(X(b.x)+ballR*.2,Y(b.y),ballR*.43,0,Math.PI*2);ctx.fill();
 ctx.restore();
 // Mini tactical radar in the lower center.
 var rw=Math.min(130,cw*.14),rh=rw*.55,rx=cw/2-rw/2,ry=ch-rh-14;
 ctx.fillStyle="rgba(2,19,29,.75)";rounded(ctx,rx,ry,rw,rh,7);ctx.fill();
 ctx.strokeStyle="rgba(191,240,236,.36)";ctx.strokeRect(rx+5,ry+5,rw-10,rh-10);
 g.players.forEach(function(p){ctx.beginPath();ctx.fillStyle=p.team===0?"#8dedff":"#f5c365";ctx.arc(rx+rw/2+p.x/105*(rw-10),ry+rh/2+p.y/68*(rh-10),2,0,Math.PI*2);ctx.fill();});
 ctx.fillStyle="#fff";ctx.beginPath();ctx.arc(rx+rw/2+b.x/105*(rw-10),ry+rh/2+b.y/68*(rh-10),2.4,0,Math.PI*2);ctx.fill();
}
window.go=go;window.changeTeam=changeTeam;window.pickFormation=pickFormation;
window.startMatch=startMatch;window.mobileBack=mobileBack;window.setFPS=setFPS;window.setQuality=setQuality;window.setCamera=setCamera;
window.shootBall=shootBall;window.passBall=passBall;window.switchPlayer=switchPlayer;window.cycleCamera=cycleCamera;
window.pauseGame=pauseGame;window.closeModal=closeModal;window.openTactics=openTactics;window.tacticInGame=tacticInGame;
window.addEventListener("keydown",function(e){
 if(["ArrowUp","ArrowDown","ArrowLeft","ArrowRight"," "].indexOf(e.key)>=0)e.preventDefault();
 state.keys[e.key]=true;
 if(state.screen!=="match")return;
 if(e.repeat)return;
 if(e.key==="s"||e.key==="S")passBall();
 if(e.key==="d"||e.key==="D"||e.key===" ")shootBall();
 if(e.key==="q"||e.key==="Q")switchPlayer();
 if(e.key==="Escape")mobileBack();
});
window.addEventListener("keyup",function(e){state.keys[e.key]=false;});
window.addEventListener("blur",function(){state.keys={};state.joy.x=0;state.joy.y=0;state.sprint=false;});
window.addEventListener("resize",resizeCanvas);
restore();render();
})();