"use strict";
const fs = require("node:fs");
const vm = require("node:vm");
const assert = require("node:assert/strict");
const src = fs.readFileSync("android/app/src/main/assets/game.js", "utf8");
new vm.Script(src);
const app = { innerHTML: "" }, els = { app };
const gradient = { addColorStop(){} };
const ctx = {};
for (const name of ["setTransform","clearRect","fillRect","strokeRect","beginPath","rect",
 "moveTo","lineTo","quadraticCurveTo","arc","ellipse","closePath","stroke","fill",
 "clip","save","restore","fillText"]) ctx[name] = ()=>{};
ctx.createLinearGradient=()=>gradient;
function element(id){
  if (els[id]) return els[id];
  return els[id] = {textContent:"",innerHTML:"",style:{},parentNode:true,
   classList:{add(){},remove(){}},
   getBoundingClientRect(){return {left:0,top:0,width:1280,height:720};},
   addEventListener(){},setPointerCapture(){},getContext(){return ctx;},
   width:1280,height:720};
}
let next = null, id = 0;
const win={devicePixelRatio:1,addEventListener(){}};
const storage={getItem(){return null},setItem(){}};
const sandbox={window:win,document:{getElementById:element},localStorage:storage,
  requestAnimationFrame(fn){next=fn;return ++id;},
  cancelAnimationFrame(){},performance:{now(){return 1000;}},
  setTimeout(){return 1;},console,Math,Date};
vm.runInNewContext(src,sandbox,{timeout:1000});
for(const [page,marker] of [
 ["home","JUGAR AHORA"],["modes","PARTIDO RÁPIDO"],["teams","SELECCIÓN DE EQUIPOS"],
 ["formation","PLAN DE JUEGO"],["intro","COMENZAR PARTIDO"],["settings","RENDIMIENTO"]]){
  win.go(page);assert.ok(app.innerHTML.includes(marker),page+" marker absent");
}
win.startMatch();
assert.ok(app.innerHTML.includes("id=\"game\""));
assert.ok(next,"animation frame missing");
next(1000);next(1016);next(1032);
win.passBall();win.switchPlayer();win.shootBall();
win.pauseGame();assert.ok(element("overlay").innerHTML.includes("PAUSA"));
win.openTactics();win.tacticInGame("4-4-2");win.closeModal();
win.mobileBack();win.mobileBack();
assert.ok(app.innerHTML.includes("JUGAR AHORA") || app.innerHTML.includes("CONTINUAR"));
console.log("OK: pantallas, render Canvas, controles, pausa, táctica y navegación");
