const NUI=typeof window.GetParentResourceName==='function'||typeof window.invokeNative==='function';
const $=i=>document.getElementById(i);
const ico=(n,c)=>`<svg class="i ${c||''}"><use href="#${n}"/></svg>`;
const d3=(a,b)=>Math.hypot(a.x-b.x,a.y-b.y,(a.z||0)-(b.z||0));
const mmss=s=>{s=Math.max(0,Math.floor(s||0));return String(Math.floor(s/60)).padStart(2,'0')+':'+String(s%60).padStart(2,'0')};
const short=s=>{s=Math.max(0,Math.floor(s||0));const m=Math.floor(s/60);return m?m+'m '+String(s%60).padStart(2,'0')+'d':s+'d'};
const lerp=(a,b,t)=>({x:a.x+(b.x-a.x)*t,y:a.y+(b.y-a.y)*t,z:(a.z||0)+((b.z||0)-(a.z||0))*t});
const mB=(id,name,zone,routes,routeLabel,x,y,z,t)=>({id,code:'HLT-'+String(id).padStart(2,'0'),name,zone,routes,routeLabel,coords:{x,y,z},transfer:t||null});
const mS=(id,name,zone,x,y,z,t)=>({id,code:'STN-'+String(id).padStart(2,'0'),name,zone,coords:{x,y,z},transfer:t||null});
const mN=(id,stopId,name,x,y,z,wp)=>({id,stopId,name,coords:{x,y,z},isWaypoint:!!wp});

const INDO_NAMES=[
 "Budi Santoso","Agus Setiawan","Rian Hidayat","Eko Prasetyo","Bambang Pamungkas",
 "Dedi Kurniawan","Ahmad Fauzi","Rizky Ramadhan","Hendra Gunawan","Fajar Pratama",
 "Doni Saputra","Wahyu Nugroho","Indra Wijaya","Tri Handoko","Bayu Wicaksono",
 "Ilham Firmansyah","Asep Sunandar","Yanto Sukirno","Joko Susilo","Aris Munandar",
 "Dimas Anggara","Teguh Wibowo","Nanang Suherman","Surya Saputra","Ade Iskandar",
 "Gilang Ramadhan","Rudi Hartono","Mulyadi","Danang Priyanto","Taufik Hidayat",
 "Andi Permana","Cecep Supriatna","Ujang Suhendar","Iman Sulaeman","Guntur Pratama",
 "Bagus Setiadi","Yoga Pratama","Panji Kusuma","Galih Rakasiwi","Lukman Hakim",
 "Rahmat Hidayat","Samsul Bahri","Zulham Efendi","Herman Darmawan","Irfan Maulana",
 "Kurnia Sandi","Faisal Basri","Tomi Suwandi","Hadi Prayitno","Wawan Ridwan"
];

const st={
 screen:'app',filter:'halte',sort:'route',q:'',sel:{mode:'bus',id:2},activeCode:'',viewRoute:0,player:{x:268,y:-1195,z:29.5},sim:true,preset:0,
 surge:{active:false,multiplier:1.25,reason:'Cuaca Buruk / Jam Malam'},
 busCfg:{LineName:'Los Santos EcoBus Multi-Route',HeadwaySeconds:180,MaxBusesPerRoute:2,TotalMaxBuses:4,FarePrice:15,TicketItem:'bus_ticket',CruiseSpeed:10.0,CornerSpeed:7.5,DockingSpeed:3.5,WaitAtStopSeconds:12},
 subCfg:{LineName:'Los Santos Transit Metro Loop',HeadwaySeconds:240,MaxTrainsPerRoute:2,FarePrice:10,TicketItem:'metro_ticket',CruiseSpeed:20,WaitAtStationSeconds:15},
 services:{
  ecoluxe:{id:'ecoluxe',name:'EcoLuxe',model:'vivanite2',speedKmh:120,baseFare:30,pricePerKm:18,minFare:50,isAutonomous:true,maxPax:3},
  ecocab:{id:'ecocab',name:'EcoCab',model:'taxi',speedKmh:80,baseFare:25,pricePerKm:14,minFare:30,isAutonomous:false,maxPax:3},
  ecoride:{id:'ecoride',name:'EcoRide',model:'faggio',speedKmh:60,baseFare:0,pricePerKm:8,minFare:15,isAutonomous:false,maxPax:1}
 },
 selectedTier:'ecoluxe',
 cabTarget:{name:'Pillbox Hill Medical Center',coords:{x:308.20,y:-595.34,z:43.28}},
 activeEcoCab:null,
 savedPlaces:[
  {id:1,label:'Apartemen Strawberry',tag:'Rumah',coords:{x:268.0,y:-1195.0,z:29.5}},
  {id:2,label:'Kantor Pusat Legion',tag:'Kantor',coords:{x:195.4,y:-934.1,z:30.6}}
 ],
 ratingData:{stars:5,tip:0,driverName:'',serviceType:''},
 busRoutes:{
  "1":{id:1,shortName:'Rute 1',name:'Route 1 - Strawberry Loop',color:'#ff9f0a',headwaySeconds:180,maxBuses:2,nodes:[
   mN(1,1,'Bus Depot',261.86,-1217.64,29.43,false),
   mN(2,2,'Strawberry TOD',265.42,-1187.00,29.48,false),
   mN(3,3,'Vespucci Blvd',359.03,-1064.30,29.37,false),
   mN(4,4,'Crusade Rd',448.02,-1251.45,30.29,false)
  ]},
  "2":{id:2,shortName:'Rute 2',name:'Route 2 - Downtown & Legion Loop',color:'#30d158',headwaySeconds:180,maxBuses:2,nodes:[
   mN(1,1,'Bus Depot',261.86,-1217.64,29.43,false),
   mN(2,2,'Strawberry TOD',265.42,-1187.00,29.48,false),
   mN(3,3,'Vespucci Blvd',359.03,-1064.30,29.37,false),
   mN(4,null,'WP Perempatan Sinner',380.51,-1055.00,29.23,true),
   mN(5,null,'WP Masuk Sinner St',399.89,-1033.79,29.44,true),
   mN(6,5,'Sinner St / MRPD',403.40,-1005.87,29.31,false),
   mN(7,6,'Sinner St North',410.41,-774.57,29.19,false),
   mN(8,7,'Dashound Terminal',409.44,-698.27,29.20,false),
   mN(9,8,'Pillbox Hill East',307.47,-766.38,29.25,false),
   mN(10,9,'Legion Square North',236.56,-829.06,30.01,false),
   mN(11,10,'Legion Square West',132.44,-892.60,30.24,false),
   mN(12,null,'WP Perempatan Legion',108.05,-995.30,29.40,true),
   mN(13,null,'WP Masuk Legion',128.59,-1019.39,29.32,true),
   mN(14,11,'Vespucci & Elgin',145.65,-1026.22,29.27,false)
  ]}
 },
 busStops:[
  mB(1,'Bus Depot','Strawberry / Central Depot',[1,2],'Rute 1 & Rute 2',261.86,-1217.64,29.43,'Titik Transit Rute 1 (Strawberry) & Rute 2 (Downtown)'),
  mB(2,'Strawberry TOD','Strawberry Ave',[1,2],'Rute 1 & Rute 2',265.42,-1187.0,29.48,'Integrasi Stasiun Metro Strawberry (#4) + Rute 1 & 2'),
  mB(3,'Vespucci Blvd','Pillbox / Vespucci',[1,2],'Rute 1 & Rute 2',359.03,-1064.3,29.37,'Percabangan Rute 1 (Crusade) & Rute 2 (MRPD / Legion)'),
  mB(4,'Crusade Rd','Strawberry East / Crusade',[1],'Rute 1 - Strawberry Loop',448.02,-1251.45,30.29),
  mB(5,'Sinner St / MRPD','Mission Row Police Dept',[2],'Rute 2 - Downtown & Legion Loop',403.40,-1005.87,29.31),
  mB(6,'Sinner St North','Mission Row / Textile City',[2],'Rute 2 - Downtown & Legion Loop',410.41,-774.57,29.19),
  mB(7,'Dashound Terminal','Dashound Bus Center',[2],'Rute 2 - Downtown & Legion Loop',409.44,-698.27,29.20,'Terminal Bus Antarkota Dashound'),
  mB(8,'Pillbox Hill East','Pillbox Hill / Swiss St',[2],'Rute 2 - Downtown & Legion Loop',307.47,-766.38,29.25),
  mB(9,'Legion Square North','Legion Square / Elgin Ave',[2],'Rute 2 - Downtown & Legion Loop',236.56,-829.06,30.01),
  mB(10,'Legion Square West','Legion Square / Strawberry Ave',[2],'Rute 2 - Downtown & Legion Loop',132.44,-892.60,30.24),
  mB(11,'Vespucci & Elgin','Pillbox South / Vespucci Blvd',[2],'Rute 2 - Downtown & Legion Loop',145.65,-1026.22,29.27,'Dekat Stasiun Metro Pillbox South (#9)')
 ],
 stations:[
  mS(1,'LSIA Terminal 4','Los Santos International Airport',-1088.62,-2709.35,-7.41,'Akses Bandara Internasional LSIA'),
  mS(2,'LSIA Parking','LSIA Main Parking Plaza',-889.27,-2311.83,-11.73),
  mS(3,'Puerto Del Sol','La Puerta / Marina',-536.81,-1286.07,26.9),
  mS(4,'Strawberry Station','Strawberry Transit Hub',270.64,-1210.22,38.9,'Integrasi Halte EcoBus Strawberry TOD (#2)'),
  mS(5,'Burton Station','Burton / Rockford Plaza',-294.75,-326.9,10.06),
  mS(6,'Portola Drive','Rockford Hills',-816.71,-137.65,19.95),
  mS(7,'Del Perro Station','Del Perro Promenade',-1351.28,-467.89,15.05),
  mS(8,'Little Seoul Station','Little Seoul Central',-502.66,-673.41,11.81),
  mS(9,'Pillbox South','Downtown / Pillbox Hill',-213.48,-1031.59,30.14,'Dekat Halte EcoBus Vespucci & Elgin (#11)'),
  mS(10,'Davis Station','Davis South',112.31,-1724.63,30.11)
 ],
 ecoCabDestinations:[
  { id: 1,  name: 'Pillbox Hill Medical Center', coords: { x: 308.20, y: -595.34, z: 43.28 } },
  { id: 2,  name: 'Mission Row Police Station',  coords: { x: 426.97, y: -979.88, z: 30.71 } },
  { id: 3,  name: 'Legion Square Central',       coords: { x: 195.42, y: -934.12, z: 30.69 } },
  { id: 4,  name: 'Strawberry TOD Transit Hub',  coords: { x: 265.42, y: -1187.01, z: 29.48 } },
  { id: 5,  name: 'LSIA Terminal 4 Airport',     coords: { x: -1037.28, y: -2737.89, z: 20.17 } },
  { id: 6,  name: 'Del Perro Pier Entrance',     coords: { x: -1635.85, y: -1004.22, z: 13.02 } },
  { id: 7,  name: 'Vinewood Boulevard Cinema',   coords: { x: 302.91, y: 155.88, z: 103.85 } },
  { id: 8,  name: 'Diamond Casino & Resort',     coords: { x: 924.96, y: 47.12, z: 81.10 } },
  { id: 9,  name: 'Sandy Shores City Hall',      coords: { x: 1853.12, y: 3687.21, z: 34.27 } },
  { id: 10, name: 'Paleto Bay Bank & Square',    coords: { x: -110.82, y: 6467.45, z: 31.63 } }
 ],
 buses:[],trains:[],nextBus:45,nextBusByRoute:{"1":45,"2":60},nextTrain:80
};

const PRESETS=[
 {l:'Strawberry Hub',c:{x:268,y:-1195,z:29.5}},
 {l:'Legion Square',c:{x:195,y:-865,z:30.1}},
 {l:'Dashound Terminal',c:{x:409,y:-698,z:29.2}},
 {l:'Bandara LSIA',c:{x:-1085,y:-2705,z:-7.4}}
];

/* ---------- Algoritma Forecast Transit ---------- */
function calcBusRouteMetrics(routeNodes,fromNodeIdx,targetStopId,busPos,cfg){
 const n=routeNodes.length;
 const targetNodeIdx=routeNodes.findIndex(nd=>!nd.isWaypoint&&nd.stopId===targetStopId)+1;
 if(targetNodeIdx<=0)return null;
 const f=((fromNodeIdx||1)-1+n)%n+1;
 const ni=f%n+1;
 const cruiseSpd=(cfg.CruiseSpeed||10.0)*0.84;
 const cornerSpd=(cfg.CornerSpeed||7.5)*0.88;
 const dwell=cfg.WaitAtStopSeconds||12;
 const glideOverhead=4.0;
 const firstTarget=routeNodes[ni-1];
 const firstDist=d3(busPos||routeNodes[f-1].coords,firstTarget.coords)*1.18;
 let totalDist=firstDist;
 let totalTime=firstDist/(firstTarget.isWaypoint?cornerSpd:cruiseSpd);
 let realStopsBetween=0;
 let cursor=ni,guard=0;
 while(cursor!==targetNodeIdx&&guard++<n+2){
  const curNode=routeNodes[cursor-1];
  if(!curNode.isWaypoint){realStopsBetween++;totalTime+=dwell+glideOverhead;}
  const afterIdx=cursor%n+1;
  const nextNode=routeNodes[afterIdx-1];
  const segDist=d3(curNode.coords,nextNode.coords)*1.18;
  totalDist+=segDist;
  totalTime+=segDist/((curNode.isWaypoint||nextNode.isWaypoint)?cornerSpd:cruiseSpd);
  cursor=afterIdx;
 }
 totalTime+=glideOverhead;
 const totalRealStops=routeNodes.filter(x=>!x.isWaypoint).length;
 return{dist:totalDist,realStops:realStopsBetween+1,travelSec:totalTime,totalRealStops,targetNodeIdx};
}

function findNextRealStop(routeNodes,fromNodeIdx){
 const n=routeNodes.length;
 for(let i=1;i<=n;i++){
  const idx=((fromNodeIdx-1+i)%n);
  if(!routeNodes[idx].isWaypoint)return routeNodes[idx];
 }
 return routeNodes[0];
}

function loopMetricsSubway(nodes,from,to,pos,rf){
 const n=nodes.length,f=(from-1+n)%n+1,t=(to-1+n)%n+1,ni=f%n+1;
 let dist=d3(pos||nodes[f-1].coords,nodes[ni-1].coords)*rf,mid=0,c=ni,g=0;
 while(c!==t&&g++<n+2){mid++;const a=c%n+1;dist+=d3(nodes[c-1].coords,nodes[a-1].coords)*rf;c=a}
 return{dist,mid};
}

function sched(mode,id,onlyRouteId){
 if(mode==='bus'){
  const cfg=st.busCfg,dwell=cfg.WaitAtStopSeconds||12;
  const stopObj=st.busStops.find(s=>s.id===id)||st.busStops[0];
  const servedRoutes=onlyRouteId?[onlyRouteId]:(stopObj.routes||[1]);
  const relevantBuses=st.buses.filter(v=>servedRoutes.includes(Number(v.routeId||1)));
  const out=[];

  relevantBuses.forEach(v=>{
   const rId=String(v.routeId||1);
   const rObj=st.busRoutes[rId]||st.busRoutes["1"];
   const rNodes=rObj.nodes;
   const li=v.lastNodeIdx||1;
   const curNode=rNodes[li-1]||rNodes[0];
   const nextStopObj=findNextRealStop(rNodes,li);
   const nextStopName=nextStopObj.name;
   const status=v.status||'EN_ROUTE',el=v.elapsedInStatus||0;
   const halt=status==='STOPPED';
   const at=halt&&!curNode.isWaypoint&&curNode.stopId===id;

   let eta=0,etd=dwell,stops=0,dist=0,pct=100;
   if(at){
    etd=Math.max(1,dwell-el);
   }else{
    const m=calcBusRouteMetrics(rNodes,li,id,v.coords,cfg);
    if(!m)return;
    dist=m.dist;stops=m.realStops;
    const remWait=halt?Math.max(0,dwell-el):(status==='QUEUEING'?6:0);
    eta=Math.max(3,Math.round(m.travelSec+remWait));
    etd=eta+dwell;
    pct=Math.min(95,Math.max(12,Math.round(((m.totalRealStops-stops+1)/m.totalRealStops)*100)));
   }

   const liveKmh=halt?0:(typeof v.speed==='number'&&v.speed>0.2?Math.round(v.speed*3.6):Math.round((status==='CORNERING'?cfg.CornerSpeed:cfg.CruiseSpeed)*3.6));
   const badge=at?'Sedang di halte':halt?`Berhenti di ${curNode.name}`:status==='QUEUEING'?`Antre masuk ${nextStopName}`:status==='APPROACHING'?`Merapat ke ${nextStopName}`:status==='CORNERING'?`Manuver belok menuju ${nextStopName}`:`Melaju ke ${nextStopName}`;

   out.push({
    code:v.code,routeId:Number(rId),routeShort:rObj.shortName,routeName:rObj.name,
    status,at,lastName:curNode.isWaypoint?'Jalur Koridor':curNode.name,nextName:nextStopName,
    eta,etd,stops,dist:Math.round(dist),pct,kmh:liveKmh,badge
   });
  });

  out.sort((a,b)=>a.eta-b.eta);
  const firstRouteId=servedRoutes[0]||1;
  const rNodesForNext=(st.busRoutes[String(firstRouteId)]||st.busRoutes["1"]).nodes.filter(x=>!x.isWaypoint);
  const curIdxInR=rNodesForNext.findIndex(x=>x.stopId===id);
  const nextStopInR=rNodesForNext[(curIdxInR+1)%rNodesForNext.length]||st.busStops[0];

  let nextDisp=st.nextBus||45;
  if(st.nextBusByRoute){
   const cands=servedRoutes.map(r=>st.nextBusByRoute[r]??st.nextBusByRoute[String(r)]??999);
   const minC=Math.min(...cands);
   if(minC<999)nextDisp=minC;
  }
  return{mode:'bus',node:stopObj,next:nextStopInR,cfg,dwell,nextDispatch:nextDisp,fleet:out,best:out[0]||null,servedRoutes};
 }

 const nodes=st.stations,fl=st.trains,cfg=st.subCfg;
 const dwell=cfg.WaitAtStationSeconds||15,raw=cfg.CruiseSpeed||20,spd=raw*0.82,rf=1.18;
 const ti=Math.max(1,nodes.findIndex(n=>n.id===id)+1),node=nodes[ti-1],next=nodes[ti%nodes.length];
 const out=fl.map(v=>{
  const li=v.lastStationIdx||1,ln=nodes[li-1]||nodes[0],nn=nodes[li%nodes.length],status=v.status||'EN_ROUTE',el=v.elapsedInStatus||0;
  const halt=status==='STOPPED'||status==='CLOSING_DOORS',at=halt&&li===ti;
  let eta=0,etd,stops=0,dist=0,pct=100;
  if(at)etd=Math.max(1,dwell-el);
  else{
   const m=loopMetricsSubway(nodes,li,ti,v.coords,rf);
   dist=m.dist;stops=m.mid+1;
   eta=Math.round(dist/spd+m.mid*(dwell+6)+(halt?Math.max(0,dwell-el):0));
   etd=eta+dwell;
   pct=Math.min(95,Math.max(12,Math.round((nodes.length-stops)/nodes.length*100)));
  }
  const badge=at?(status==='CLOSING_DOORS'?'Pintu ditutup':'Sedang di peron'):halt?'Berhenti di '+ln.name:'Melaju ke '+nn.name;
  return{code:v.code,status,at,lastName:ln.name,nextName:nn.name,eta,etd,stops,dist:Math.round(dist),pct,kmh:halt?0:Math.round(raw*3.6),badge};
 }).sort((a,b)=>a.eta-b.eta);
 return{mode:'subway',node,next,cfg,dwell,nextDispatch:st.nextTrain,fleet:out,best:out[0]||null};
}

const xfer=(m,id)=>m==='bus'&&id===2?{mode:'subway',id:4}:m==='subway'&&id===4?{mode:'bus',id:2}:m==='bus'&&id===11?{mode:'subway',id:9}:m==='subway'&&id===9?{mode:'bus',id:11}:null;

function nodes(){
 const o=[];
 st.busStops.forEach(s=>o.push({mode:'bus',id:s.id,code:s.code,name:s.name,zone:s.zone||'',routes:s.routes||[1],routeLabel:s.routeLabel||'',coords:s.coords,dist:Math.round(d3(st.player,s.coords)),sch:sched('bus',s.id)}));
 st.stations.forEach(s=>o.push({mode:'subway',id:s.id,code:s.code,name:s.name,zone:s.zone||'',routes:[],routeLabel:'LST Metro',coords:s.coords,dist:Math.round(d3(st.player,s.coords)),sch:sched('subway',s.id)}));
 return o;
}
const etaTxt=(n,b)=>!b?'Depo':b.at?'Di '+(n==='bus'?'halte':'peron'):short(b.eta);

/* ---------- SIDEBAR ECOLINK ---------- */
function rSide(){
 const all=nodes();
 const nearHalte=all.filter(x=>x.mode==='bus').reduce((a,b)=>b.dist<a.dist?b:a,all[0]);
 const nearStasiun=all.filter(x=>x.mode==='subway').reduce((a,b)=>b.dist<a.dist?b:a,all[0]);
 const q=st.q.trim().toLowerCase();

 const isVehicleTab=(st.filter==='kereta'||st.filter==='bus');
 $('sortChips').classList.toggle('hide',isVehicleTab);

 if(st.filter==='halte'){
  let l=all.filter(n=>n.mode==='bus');
  if(q)l=l.filter(n=>(n.name+n.code+n.zone+n.routeLabel).toLowerCase().includes(q));
  if(st.sort==='near')l.sort((a,b)=>a.dist-b.dist);
  else if(st.sort==='fast')l.sort((a,b)=>(a.sch.best?a.sch.best.eta:1e5)-(b.sch.best?b.sch.best.eta:1e5));

  $('list').innerHTML=l.length?l.map(n=>{
   const b=n.sch.best,sel=st.sel.mode==='bus'&&st.sel.id===n.id;
   const r2Only=!n.routes.includes(1)&&n.routes.includes(2);
   const tags=n.routes.map(r=>`<span class="rtag${r===2?' r2':''}">R${r}</span>`).join('');
   return `<button class="row${sel?' sel':''}" onpointerdown="pick('bus',${n.id})"><span class="ico ${r2Only?'bus2':'bus'}">${ico('bus')}</span><span class="rt"><b>${n.name}${tags}</b><small>${n.code} · ${n.dist} m${n===nearHalte?' · Terdekat':''}</small></span><span class="eta${b&&b.at?' now':''}">${etaTxt('bus',b)}</span></button>`;
  }).join(''):'<div class="empty">Tidak ada halte yang cocok.</div>';

 }else if(st.filter==='stasiun'){
  let l=all.filter(n=>n.mode==='subway');
  if(q)l=l.filter(n=>(n.name+n.code+n.zone).toLowerCase().includes(q));
  if(st.sort==='near')l.sort((a,b)=>a.dist-b.dist);
  else if(st.sort==='fast')l.sort((a,b)=>(a.sch.best?a.sch.best.eta:1e5)-(b.sch.best?b.sch.best.eta:1e5));

  $('list').innerHTML=l.length?l.map(n=>{
   const b=n.sch.best,sel=st.sel.mode==='subway'&&st.sel.id===n.id;
   return `<button class="row${sel?' sel':''}" onpointerdown="pick('subway',${n.id})"><span class="ico sub">${ico('train')}</span><span class="rt"><b>${n.name}</b><small>${n.code} · ${n.dist} m${n===nearStasiun?' · Terdekat':''}</small></span><span class="eta${b&&b.at?' now':''}">${etaTxt('subway',b)}</span></button>`;
  }).join(''):'<div class="empty">Tidak ada stasiun yang cocok.</div>';

 }else if(st.filter==='kereta'){
  let trList=st.trains.map(t=>{
   const li=t.lastStationIdx||1;
   const curSt=st.stations[li-1]||st.stations[0];
   const nextSt=st.stations[li%st.stations.length]||st.stations[0];
   const halt=t.status==='STOPPED'||t.status==='CLOSING_DOORS';
   const targetSt=halt?curSt:nextSt;
   const sc=sched('subway',targetSt.id);
   const myInfo=sc.fleet.find(f=>f.code===t.code);
   const stateTxt=halt?(t.status==='CLOSING_DOORS'?`Pintu ditutup di ${curSt.name}`:`Berhenti di ${curSt.name}`):`Melaju ke ${nextSt.name}`;
   const etaVal=halt?'Di peron':(myInfo?short(myInfo.eta):'Aktif');
   return{code:t.code,halt,stateTxt,targetStId:targetSt.id,etaVal};
  });
  if(q)trList=trList.filter(t=>(t.code+t.stateTxt).toLowerCase().includes(q));

  $('list').innerHTML=trList.length?trList.map(t=>{
   const sel=st.activeCode===t.code||(st.sel.mode==='subway'&&st.sel.id===t.targetStId&&!st.activeCode);
   return `<button class="row${sel?' sel':''}" onpointerdown="pickVehicle('subway','${t.code}',${t.targetStId},0)"><span class="ico sub">${ico('train')}</span><span class="rt"><b>${t.code}<span class="rtag m">METRO</span></b><small>${t.stateTxt}</small></span><span class="eta${t.halt?' now':''}">${t.etaVal}</span></button>`;
  }).join(''):`<div class="empty">Belum ada kereta aktif. Keberangkatan depo dalam ${mmss(st.nextTrain)}.</div>`;

 }else if(st.filter==='bus'){
  let bList=st.buses.map(v=>{
   const rId=Number(v.routeId||1);
   const rObj=st.busRoutes[String(rId)]||st.busRoutes["1"];
   const rNodes=rObj.nodes;
   const li=v.lastNodeIdx||1;
   const curNode=rNodes[li-1]||rNodes[0];
   const nextReal=findNextRealStop(rNodes,li);
   const halt=v.status==='STOPPED'&&!curNode.isWaypoint;
   const targetStopId=halt?(curNode.stopId||1):(nextReal.stopId||1);
   const sc=sched('bus',targetStopId,rId);
   const myInfo=sc.fleet.find(f=>f.code===v.code);
   const stateTxt=halt?`Berhenti di ${curNode.name}`:v.status==='QUEUEING'?`Antre masuk ${nextReal.name}`:`Melaju ke ${nextReal.name}`;
   const etaVal=halt?'Di halte':(myInfo?short(myInfo.eta):'Aktif');
   return{code:v.code,routeId:rId,routeShort:rObj.shortName,halt,stateTxt,targetStopId,etaVal};
  });
  if(q)bList=bList.filter(b=>(b.code+b.routeShort+b.stateTxt).toLowerCase().includes(q));

  $('list').innerHTML=bList.length?bList.map(b=>{
   const sel=st.activeCode===b.code;
   return `<button class="row${sel?' sel':''}" onpointerdown="pickVehicle('bus','${b.code}',${b.targetStopId},${b.routeId})"><span class="ico ${b.routeId===2?'bus2':'bus'}">${ico('bus')}</span><span class="rt"><b>${b.code}<span class="rtag${b.routeId===2?' r2':''}">R${b.routeId}</span></b><small>${b.stateTxt}</small></span><span class="eta${b.halt?' now':''}">${b.etaVal}</span></button>`;
  }).join(''):`<div class="empty">Belum ada armada bus aktif. Keberangkatan depo dalam ${mmss(st.nextBus)}.</div>`;
 }

 const r1Count=st.buses.filter(x=>Number(x.routeId||1)===1).length;
 const r2Count=st.buses.filter(x=>Number(x.routeId||1)===2).length;
 $('live').textContent=`Bus R1: ${r1Count}/2 · Bus R2: ${r2Count}/2 · Kereta: ${st.trains.length}/2 aktif`;

 document.querySelectorAll('[data-f]').forEach(b=>b.classList.toggle('on',b.dataset.f===st.filter));
 document.querySelectorAll('[data-s]').forEach(b=>b.classList.toggle('on',b.dataset.s===st.sort));
 return all;
}

function getStoppedVehiclesAt(mode,stopOrStationId,routeIdFilter){
 if(mode==='bus'){
  return st.buses.filter(v=>{
   const rId=Number(v.routeId||1);
   if(routeIdFilter&&rId!==Number(routeIdFilter))return false;
   if(v.status!=='STOPPED')return false;
   const rObj=st.busRoutes[String(rId)]||st.busRoutes["1"];
   const curNode=rObj.nodes[(v.lastNodeIdx||1)-1];
   return curNode&&!curNode.isWaypoint&&curNode.stopId===stopOrStationId;
  });
 }else{
  return st.trains.filter(t=>{
   const halt=t.status==='STOPPED'||t.status==='CLOSING_DOORS';
   return halt&&(t.lastStationIdx||1)===stopOrStationId;
  });
 }
}

function rDetail(){
 const{mode,id}=st.sel,bus=mode==='bus';
 const stopNode=bus?(st.busStops.find(s=>s.id===id)||st.busStops[0]):(st.stations.find(s=>s.id===id)||st.stations[0]);
 const activeRouteView=bus?(st.viewRoute&&stopNode.routes.includes(st.viewRoute)?st.viewRoute:stopNode.routes[0]):0;

 const s=sched(mode,id),n=s.node,b=s.best,c=s.cfg,unit=bus?'halte':'peron';
 const isR2Hero=bus&&((b&&b.routeId===2)||(!b&&activeRouteView===2));
 let cls=bus?(isR2Hero?'h-bus2':'h-bus'):'h-sub',lab,big,sub,etd;

 if(!b){
  cls='h-wait';lab='Menunggu keberangkatan dari depo';big=mmss(s.nextDispatch+20);
  sub=bus?`Melayani ${n.routeLabel||'EcoBus'}`:'Armada berikutnya berangkat otomatis';etd=mmss(s.nextDispatch+20+s.dwell);
 }else if(b.at){
  const cl=b.status==='CLOSING_DOORS';cls='h-now';lab=`${b.code}${b.routeShort?' ('+b.routeShort+')':''} · ${cl?'Pintu menutup':'Pintu terbuka'}`;
  big=cl?'Segera':'Tiba';sub=`Berhenti di ${unit} ini, lanjut ke ${b.nextName||s.next.name}`;etd=mmss(b.etd);
 }else{
  lab=`${bus?'Bus':'Kereta'} berikutnya: ${b.code}${b.routeShort?' ('+b.routeShort+')':''}`;big=mmss(b.eta);sub=`${b.badge}`;etd=mmss(b.etd);
 }

 const tg=xfer(mode,id);
 const routeStopsList=bus?st.busStops.filter(x=>x.routes.includes(activeRouteView)):st.stations;
 const fleet=s.fleet.length?s.fleet.map((f,i)=>`<div class="card"><div class="ft"><span class="code${f.routeId===2?' r2':''}">${f.code}</span><div><b>${i?'Berikutnya #'+(i+1):'Terdekat'}${f.routeShort?' · '+f.routeShort:''}</b><small>${f.badge}</small></div><span class="kmh">${f.kmh} km/j</span></div><div class="pr"><i class="${f.routeId===2?'r2':''}" style="width:${f.pct}%"></i></div><div class="fs"><span>${f.at?'Sudah di titik ini':f.stops+' '+(bus?'halte':'stasiun')+' lagi · '+(f.dist/1000).toFixed(2)+' km'}</span><span>${f.pct}%</span></div><div class="fe"><div><small>Estimasi Tiba (ETA)</small><b>${f.at?'Di lokasi':mmss(f.eta)}</b></div><div><small>Keberangkatan (ETD)</small><b>${mmss(f.etd)}</b></div></div></div>`).join(''):`<div class="card empty">Belum ada armada aktif di koridor ini. Keberangkatan dari depo dalam ${mmss(s.nextDispatch)}.</div>`;

 const routeTabsHtml=(bus&&n.routes.length>1)?`<div class="rtabs">${n.routes.map(r=>`<button class="${activeRouteView===r?'on':''}" onclick="setRouteTab(${r})">Jalur Rute ${r}</button>`).join('')}</div>`:'';
 const lineColor=bus?(activeRouteView===2?'#30d158':'#ff9f0a'):'#0a84ff';
 const lineGlow=bus?(activeRouteView===2?'rgba(48,209,88,.32)':'rgba(255,159,10,.32)'):'rgba(10,132,255,.32)';

 const routeDiagramRows=routeStopsList.map(x=>{
  const q=bus?sched('bus',x.id,activeRouteView):sched('subway',x.id);
  const y=q.best;
  const stoppedHere=getStoppedVehiclesAt(mode,x.id,bus?activeRouteView:null);
  const isOccupied=stoppedHere.length>0;
  const occBadges=isOccupied?stoppedHere.map(v=>`<span class="rd-badge">${v.code} berhenti</span>`).join(''):'';
  const subLabel=isOccupied?`Armada sedang berhenti di ${unit} ini`:(y?`Berikutnya: ${y.code}${y.routeShort?' · '+y.routeShort:''}`:'Menunggu keberangkatan depo');

  return `<button class="rd-row${x.id===id?' cur':''}" style="--line-clr:${lineColor};--line-glow:${lineGlow}" onpointerdown="pick('${mode}',${x.id})">
   <span class="rd-rail"><span class="rd-dot${isOccupied?' occ':''}"></span></span>
   <span class="rt"><b>${x.name}${occBadges}</b><small>${x.code} · ${subLabel}</small></span>
   <span class="eta${isOccupied||(y&&y.at)?' now':''}">${isOccupied?'Di '+unit:(y?etaTxt(mode,y):short(q.nextDispatch+20))}</span>
  </button>`;
 }).join('');

 const maxCap=bus?(s.servedRoutes.length*(c.MaxBusesPerRoute||2)):c.MaxTrainsPerRoute;
 const m=$('main');
 m.className='mn '+(bus?(activeRouteView===2?'bus r2':'bus'):'sub');
 m.innerHTML=`<div class="top"><div><div class="eye">${bus?'Halte EcoBus':'Stasiun Metro'} · ${n.code}</div><h2>${n.name}</h2><p>${n.zone} · ${bus?(n.routeLabel||c.LineName):c.LineName}</p></div><button class="btn" onclick="gps()">${ico('pin')}Tandai GPS</button></div>
 <div class="hero ${cls}"><div><div class="lab">${lab}</div><div class="big">${big}</div><div class="hs">${sub}</div></div><div class="hr"><div class="lab">Berangkat dalam</div><div class="mid">${etd}</div><span class="pill">${Math.round(d3(st.player,n.coords))} m dari Anda</span><span class="pill">Tarif $${c.FarePrice}</span></div></div>
 ${n.transfer?`<div class="card xf">${ico('swap')}<div><b>Interkoneksi Transit</b><small>${n.transfer}</small></div>${tg?'<button class="lnk" onclick="jump()">Lihat jadwal</button>':''}</div>`:''}
 <div class="sec"><h3>Armada menuju ${n.name}</h3><span>Interval ${Math.round(c.HeadwaySeconds/60)} menit · ${s.fleet.length}/${maxCap} aktif</span></div><div class="grid">${fleet}</div>
 <div class="sec"><h3>Diagram Jalur ${bus?('Rute '+activeRouteView):'LST Metro'}</h3><span>${routeStopsList.length} ${bus?'halte':'stasiun'}, sirkuler</span></div>
 ${routeTabsHtml}
 <div class="rd-legend" style="--acc:${lineColor}">
  <span><i class="rd-ldot full"></i> Titik terisi = Armada sedang berhenti</span>
  <span><i class="rd-ldot"></i> Titik kosong = Tidak ada armada berhenti</span>
 </div>
 <div class="rdiag">${routeDiagramRows}</div>`;
}

/* ========================================================================= */
/* UBER-STYLE ECOCAB SCRIPT WITH SURGE PRICING & HOME/WORK SHORTCUTS         */
/* ========================================================================= */
function calcTierPrice(tierKey,destCoords){
 const cfg=st.services[tierKey]||st.services.ecocab;
 const distMeters=d3(st.player,destCoords);
 const distKm=distMeters/1000.0;
 let baseFare=cfg.baseFare+(distKm*cfg.pricePerKm);
 if(baseFare<cfg.minFare)baseFare=cfg.minFare;

 // Dynamic Surge Pricing Multiplier (1.25x saat cuaca buruk / jam malam)
 let isVip = st.userVip && st.userVip.active && st.userVip.remainingTrips > 0;
 let surgeMult = 1.0;
 if(st.surge && st.surge.active){
  surgeMult = isVip ? 1.05 : (st.surge.multiplier || 1.25);
 }
 let totalFare = baseFare * surgeMult;
 let discountAmount = 0;
 if(isVip){
  discountAmount = totalFare * 0.20;
  totalFare = totalFare - discountAmount;
 }
 let finalFare = Math.ceil(totalFare);

 const spdMs=(cfg.speedKmh||80)/3.6;
 const etaMin=Math.max(1,Math.ceil(distMeters/spdMs/60));
 return{fare:finalFare,baseFare:Math.ceil(baseFare),discount:Math.floor(discountAmount),isVip:isVip,km:distKm.toFixed(1),etaMin};
}

const esc=s=>String(s==null?'':s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const clockAt=m=>{const d=new Date(Date.now()+m*60000);return String(d.getHours()).padStart(2,'0')+':'+String(d.getMinutes()).padStart(2,'0')};

function updateHomeWorkSubtitles(){
 const homePlace=st.savedPlaces.find(p=>p.tag==='Rumah'||p.label.toLowerCase().includes('rumah'));
 const workPlace=st.savedPlaces.find(p=>p.tag==='Kantor'||p.label.toLowerCase().includes('kantor'));

 $('hwHomeSub').textContent=homePlace?homePlace.label:'Set alamat';
 $('hwWorkSub').textContent=workPlace?workPlace.label:'Set alamat';
}

function updateTierCards(){
 const dest=st.cabTarget;
 $('uDestInput').value=dest?dest.name:'';

 // Render Surge Banner
 const surgeBanner=$('uSurgeBanner');
 if(st.surge&&st.surge.active){
  surgeBanner.style.display='flex';
  $('uSurgeReasonTxt').textContent=st.surge.reason||'Tarif disesuaikan karena cuaca buruk / jam malam di Los Santos';
  $('uSurgeMultTag').textContent=`${(st.surge.multiplier||1.25)}x`;
 }else{
  surgeBanner.style.display='none';
 }

 updateHomeWorkSubtitles();

 if(!dest||!dest.coords)return;

 Object.keys(st.services).forEach(k=>{
  const est=calcTierPrice(k,dest.coords);
  $(`price-${k}`).textContent=`$${est.fare}`;
  $(`eta-${k}`).textContent=`${est.etaMin} mnt · ${est.km} km`;

  const badgeEl=$(`sbadge-${k}`);
  if(badgeEl){
   badgeEl.style.display=(st.surge&&st.surge.active)?'inline-flex':'none';
   badgeEl.innerHTML=`<svg class="i" style="font-size:11px"><use href="#bolt"/></svg>${(st.surge&&st.surge.multiplier)||1.25}x`;
  }
 });

 const ks=Object.keys(st.services),es=ks.map(k=>calcTierPrice(k,dest.coords));
 const mf=Math.min(...es.map(e=>e.fare)),mt=Math.min(...es.map(e=>e.etaMin)),tie=es.filter(e=>e.etaMin===mt).length===ks.length;
 ks.forEach((k,i)=>{const b=$(`bd-${k}`);if(b)b.textContent=es[i].fare===mf?'Hemat':(!tie&&es[i].etaMin===mt?'Tercepat':'')});

 const cur=st.services[st.selectedTier]||st.services.ecoluxe;
 const curEst=calcTierPrice(st.selectedTier,dest.coords);
 $('uConfirmBtn').innerHTML=`<span>Pesan ${esc(cur.name)}</span><b>$${curEst.fare}</b>`;
 drawMap();
}

function selectTier(k){
 st.selectedTier=k;
 document.querySelectorAll('.u-tier-card').forEach(c=>c.classList.remove('sel'));
 $(`card-${k}`).classList.add('sel');
 updateTierCards();
}

function setCabTab(tab){
 $('tabBook').classList.toggle('on',tab==='book');
 $('tabSaved').classList.toggle('on',tab==='saved');
 $('tabPopular').classList.toggle('on',tab==='popular');
 const tVip = $('tabVip'); if(tVip) tVip.classList.toggle('on',tab==='vip');
 const tHist = $('tabHistory'); if(tHist) tHist.classList.toggle('on',tab==='history');

 document.querySelector('.u-tier-list').style.display=tab==='book'?'flex':'none';
 $('uTierHead').style.display=tab==='book'?'block':'none';
 $('uFoot').style.display=tab==='book'?'block':'none';
 $('uSavedSubpanel').style.display=tab==='saved'?'flex':'none';
 $('uPopSubpanel').style.display=tab==='popular'?'flex':'none';
 const pVip = $('uVipSubpanel'); if(pVip) pVip.style.display=tab==='vip'?'flex':'none';
 const pHist = $('uHistorySubpanel'); if(pHist) pHist.style.display=tab==='history'?'flex':'none';

 if(tab==='saved')renderSavedPlaces();
 if(tab==='popular')renderPopularPlaces();
 if(tab==='vip')renderVipPanel();
 if(tab==='history')renderHistoryList();
}

function placeIcon(tag){return tag==='Rumah'?'house':tag==='Kantor'?'work':'pin'}

function renderSavedPlaces(){
 const list=$('spList');
 if(!st.savedPlaces||!st.savedPlaces.length){
  list.innerHTML='<div class="empty">Belum ada alamat tersimpan. Pilih tujuan, lalu ketuk "Simpan Alamat".</div>';
  return;
 }
 list.innerHTML=st.savedPlaces.map(p=>{
  const est=calcTierPrice(st.selectedTier,p.coords);
  return `<div class="u-li" onclick="selectSavedPlace(${p.id})">
   <span class="u-li-ic">${ico(placeIcon(p.tag))}</span>
   <span class="u-li-t"><b>${esc(p.label)}</b><small>${esc(p.tag||'Favorit')} · ${est.km} km · Est. $${est.fare}</small></span>
   <button class="u-li-del" title="Hapus alamat" onclick="event.stopPropagation();deleteSavedPlace(${p.id})">${ico('trash')}</button>
  </div>`;
 }).join('');
}

function renderPopularPlaces(){
 const list=$('popList');
 list.innerHTML=st.ecoCabDestinations.map(p=>{
  const est=calcTierPrice(st.selectedTier,p.coords);
  return `<div class="u-li" onclick="selectPopPlace(${p.id})">
   <span class="u-li-ic">${ico('pin')}</span>
   <span class="u-li-t"><b>${esc(p.name)}</b><small>${est.km} km dari Anda</small></span>
   <span class="u-li-p">$${est.fare}</span>
  </div>`;
 }).join('');
}

function selectSavedPlace(id){
 const p=st.savedPlaces.find(x=>x.id===id);
 if(!p)return;
 st.cabTarget={name:p.label,coords:p.coords};
 setCabTab('book');
 updateTierCards();
 toast(`Tujuan dipilih: ${p.label}`);
}

function selectPopPlace(id){
 const p=st.ecoCabDestinations.find(x=>x.id===id);
 if(!p)return;
 st.cabTarget={name:p.name,coords:p.coords};
 setCabTab('book');
 updateTierCards();
 toast(`Tujuan dipilih: ${p.name}`);
}


st.userVip = { active: false, remainingTrips: 0, daysLeft: 0 };
st.tripHistory = [];

function renderVipPanel(){
 const vip=st.userVip,badge=$('vipStatusBadge'),trips=$('vipTripsLeft'),days=$('vipDaysLeft'),btn=$('vipActionBtn'),bar=$('vipBar');
 if(!badge)return;
 const set=(t,c,tr,dy,lbl,pct)=>{badge.textContent=t;badge.style.background=c;badge.style.color=c==='#f59e0b'||c==='#22c55e'?'#000':'#fff';trips.textContent=tr;days.textContent=dy;btn.innerHTML=`<span>${lbl}</span><b>$350</b>`;bar.style.width=Math.max(0,Math.min(100,pct))+'%'};
 if(vip&&vip.active&&vip.remainingTrips>0)set('MEMBER AKTIF','#22c55e',`${vip.remainingTrips} / 30 Trip`,`Sisa ${vip.daysLeft} hari`,'Tambah / perpanjang',vip.remainingTrips/30*100);
 else if(vip&&vip.expired)set('KEDALUWARSA','#ef4444',`${vip.remainingTrips} Trip`,'Habis waktu','Perpanjang paket 10 hari',0);
 else if(vip&&vip.remainingTrips<=0&&vip.active)set('KUOTA HABIS','#f59e0b','0 / 30 Trip',`Sisa ${vip.daysLeft} hari`,'Isi ulang kuota 30 trip',0);
 else set('TIDAK AKTIF','rgba(255,255,255,.14)','0 Trip','-','Beli paket EcoVIP',0);
}

function renderHistoryList(){
 const container = $('historyList');
 if(!container) return;
 if(!st.tripHistory || !st.tripHistory.length){
  container.innerHTML = '<div class="empty">Belum ada riwayat perjalanan tercatat.</div>';
  return;
 }
 container.innerHTML = st.tripHistory.map(t=>{
  const isVipTrip = t.discount_applied > 0;
  return `
   <div class="u-hist-item">
    <div class="u-hist-head">
     <b>${esc(t.dest_name)}</b>
     <span>$${t.final_fare}</span>
    </div>
    <div class="u-hist-sub">
     <span>${esc(t.service_type.toUpperCase())} · Driver: ${esc(t.driver_name)}</span>
     <span>${t.trip_date || 'Baru saja'}</span>
    </div>
    <div style="display:flex;justify-content:space-between;align-items:center;margin-top:2px">
     <small style="color:var(--l2)">Jarak: ${t.distance_km} km</small>
     ${isVipTrip ? '<span class="u-hist-tag">Hemat 20% (EcoVIP)</span>' : ''}
    </div>
   </div>
  `;
 }).join('');
}

function buyOrRenewVip(){
 if(NUI){
  fetch(`https://${GetParentResourceName()}/buyEcoVIP`, { method: 'POST' }).then(()=>{
   toast('Memproses transaksi EcoVIP...');
  }).catch(()=>{});
 } else {
  st.userVip = { active: true, remainingTrips: (st.userVip.remainingTrips||0) + 30, daysLeft: 10 };
  renderVipPanel();
  updateTierCards();
  toast('Paket EcoVIP 30x Trip (10 Hari) aktif (Simulasi)!');
 }
}

/* Custom Save Place Modal & Home/Work Shortcuts (NUI Sandbox Safe) */
let pendingSaveTarget = null;
let currentSelectedTag = 'Favorit';

function setPlaceTag(tag){
 currentSelectedTag = tag;
 const f=$('spTagFav'), h=$('spTagHome'), w=$('spTagWork');
 if(f) f.classList.toggle('on', tag === 'Favorit');
 if(h) h.classList.toggle('on', tag === 'Rumah');
 if(w) w.classList.toggle('on', tag === 'Kantor');
}

function openSavePlaceModal(defaultLabel, defaultTag, targetObj){
 pendingSaveTarget = targetObj || st.cabTarget;
 const inp = $('spInputLabel');
 if(inp) inp.value = defaultLabel || '';
 setPlaceTag(defaultTag || 'Favorit');
 const m = $('savePlaceModal');
 if(m) m.classList.add('on');
 setTimeout(() => { if(inp) inp.focus(); }, 120);
}

function closeSavePlaceModal(){
 const m = $('savePlaceModal');
 if(m) m.classList.remove('on');
 pendingSaveTarget = null;
}

function confirmSavePlace(){
 const inp = $('spInputLabel');
 const label = inp ? inp.value.trim() : '';
 if(!label){
  toast('Harap masukkan nama/label alamat!');
  return;
 }
 if(!pendingSaveTarget || !pendingSaveTarget.coords){
  toast('Titik lokasi koordinat tidak valid!');
  closeSavePlaceModal();
  return;
 }

 const coords = pendingSaveTarget.coords;
 const tag = currentSelectedTag;

 if(NUI){
  fetch(`https://${GetParentResourceName()}/saveCustomPlace`,{
   method:'POST',
   headers:{'Content-Type':'application/json'},
   body:JSON.stringify({ label: label, tag: tag, coords: coords })
  }).then(r => r.json()).then(() => {
   toast(`Alamat "${label}" berhasil disimpan!`);
  }).catch(() => {});
 } else {
  st.savedPlaces.push({ id: Date.now(), label: label, tag: tag, coords: coords });
  toast(`Alamat "${label}" disimpan (Simulasi)!`);
  updateTierCards();
  if($('tabSaved').classList.contains('on')) renderSavedPlaces();
 }

 st.cabTarget = { name: label, coords: coords };
 updateTierCards();
 closeSavePlaceModal();
}

function clickHomeShortcut(){
 const homePlace=st.savedPlaces.find(p=>p.tag==='Rumah'||p.label.toLowerCase().includes('rumah'));
 if(homePlace){
  st.cabTarget={name:homePlace.label,coords:homePlace.coords};
  setCabTab('book');
  updateTierCards();
  toast(`Tujuan diarahkan ke Rumah: ${homePlace.label}`);
 }else{
  openSavePlaceModal('Apartemen Strawberry', 'Rumah', { coords: st.player || { x: 268.0, y: -1195.0, z: 29.5 } });
 }
}

function clickWorkShortcut(){
 const workPlace=st.savedPlaces.find(p=>p.tag==='Kantor'||p.label.toLowerCase().includes('kantor'));
 if(workPlace){
  st.cabTarget={name:workPlace.label,coords:workPlace.coords};
  setCabTab('book');
  updateTierCards();
  toast(`Tujuan diarahkan ke Kantor: ${workPlace.label}`);
 }else{
  openSavePlaceModal('Kantor Pusat Legion', 'Kantor', { coords: { x: 195.4, y: -934.1, z: 30.6 } });
 }
}

function takeWaypoint(){
 if(NUI){
  fetch(`https://${GetParentResourceName()}/getMapWaypoint`,{method:'POST'}).then(r=>r.json()).then(d=>{
   if(d&&d.ok){
    st.cabTarget={name:'Titik Waypoint Peta GPS',coords:{x:d.x,y:d.y,z:d.z}};
    updateTierCards();
    toast('Berhasil mengambil koordinat Waypoint Peta!');
   }else{
    toast(d.error||'Tandai Waypoint di Pause Menu Peta terlebih dahulu!');
   }
  }).catch(()=>toast('Gagal membaca waypoint peta.'));
 }else{
  st.cabTarget={name:'Waypoint Peta (Simulasi)',coords:{x:356.0,y:-1068.0,z:29.4}};
  updateTierCards();
  toast('Waypoint diset ke Vespucci Blvd (Simulasi)');
 }
}

function saveCurrentDestModal(){
 if(!st.cabTarget||!st.cabTarget.coords)return toast('Tentukan tujuan terlebih dahulu!');
 let tag='Favorit';
 const nameLower=(st.cabTarget.name||'').toLowerCase();
 if(nameLower.includes('rumah'))tag='Rumah';
 else if(nameLower.includes('kantor')||nameLower.includes('kerja'))tag='Kantor';
 openSavePlaceModal(st.cabTarget.name, tag, st.cabTarget);
}

function deleteSavedPlace(id){
 if(NUI){
  fetch(`https://${GetParentResourceName()}/deleteCustomPlace`,{
   method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({id:id})
  }).then(r=>r.json()).then(()=>{
   st.savedPlaces=st.savedPlaces.filter(p=>p.id!==id);
   renderSavedPlaces();
   updateHomeWorkSubtitles();
  }).catch(()=>{});
 }else{
  st.savedPlaces=st.savedPlaces.filter(p=>p.id!==id);
  renderSavedPlaces();
  updateHomeWorkSubtitles();
 }
 toast('Alamat dihapus.');
}

function submitCabOrder(){
 if(st.activeEcoCab||st.cabSearching){
  return toast('Anda sudah memiliki pesanan armada yang sedang aktif!');
 }
 const tier=st.selectedTier||'ecoluxe';
 const cfg=st.services[tier];
 const dest=st.cabTarget;
 const est=calcTierPrice(tier,dest.coords);

 let randDriver=null;
 if(!cfg.isAutonomous){
  randDriver=INDO_NAMES[Math.floor(Math.random()*INDO_NAMES.length)];
 }

 if(NUI){
  fetch(`https://${GetParentResourceName()}/requestEcoCabRide`,{
   method:'POST',
   headers:{'Content-Type':'application/json'},
   body:JSON.stringify({
    serviceType:tier,
    name:dest.name,
    x:dest.coords.x,
    y:dest.coords.y,
    z:dest.coords.z,
    surge:st.surge&&st.surge.active,
    usedVip:est.isVip,
    discountApplied:est.discount,
    estimatedFare:est.fare,
    baseFare:est.baseFare
   })
  }).then(r=>r.json()).then(d=>{
   if(!d.ok){st.cabSearching=false;clearTimeout(st._srch);render();toast(d.error||'Gagal memesan taksi.')}
  }).catch(()=>{st.cabSearching=false;clearTimeout(st._srch);render();toast('Gagal terhubung ke server EcoCab.')});
  st.cabSearching=true;clearTimeout(st._srch);st._srch=setTimeout(()=>{if(st.cabSearching&&!st.activeEcoCab){st.cabSearching=false;render()}},15000);
  render();
 }else{
  st.cabSearching=true;clearTimeout(st._srch);
  st._srch=setTimeout(()=>{if(!st.cabSearching)return;st.cabSearching=false;st.activeEcoCab={
   status:'DISPATCHED',
   serviceType:tier,
   serviceName:cfg.name,
   destName:dest.name,
   driverName:cfg.isAutonomous?"EcoLuxe Autonomous AI (Driverless)":randDriver,
   isAutonomous:cfg.isAutonomous,
   estimatedFare:est.fare,
   distKm:est.km,
   etaMin:est.etaMin,
   gasStop:false
  };render()},2200);
  render();
 }
 toast(`Memesan ${cfg.name} menuju ${dest.name}...`);
}

function cancelCabOrder(){
 st.cabSearching=false;clearTimeout(st._srch);
 if(NUI){
  fetch(`https://${GetParentResourceName()}/cancelEcoCabRide`,{method:'POST'}).catch(()=>{});
 }else{
  st.activeEcoCab=null;
  render();
 }
 toast('Pesanan EcoCab berhasil dibatalkan.');
}

/* Simulation Surge Toggle */
function toggleSurgeSim(){
 st.surge.active=!st.surge.active;
 $('bSurge').textContent=st.surge.active?'⚡ Surge: ON (1.25x)':'⚡ Surge: OFF';
 $('bSurge').classList.toggle('act',st.surge.active);
 updateTierCards();
 toast(st.surge.active?'⚡ Dynamic Surge Pricing 1.25x Aktif!':'Surge Pricing dinonaktifkan.');
}

/* ---------- Map Drawing (SVG) ---------- */
function roundPath(p,r){
 let d=`M${p[0][0]} ${p[0][1]}`;
 for(let i=1;i<p.length-1;i++){
  const a=p[i-1],b=p[i],c=p[i+1];
  const l1=Math.hypot(b[0]-a[0],b[1]-a[1]),l2=Math.hypot(c[0]-b[0],c[1]-b[1]),rr=Math.min(r,l1/2,l2/2);
  d+=` L${b[0]+(a[0]-b[0])/l1*rr} ${b[1]+(a[1]-b[1])/l1*rr} Q${b[0]} ${b[1]} ${b[0]+(c[0]-b[0])/l2*rr} ${b[1]+(c[1]-b[1])/l2*rr}`;
 }
 const e=p[p.length-1];return d+` L${e[0]} ${e[1]}`;
}

function drawMap(){
 const el=$('uMap');if(!el)return;
 let w=el.clientWidth,h=el.clientHeight;if(w<300||h<300){w=1156;h=776}
 const dest=st.cabTarget,cab=st.activeEcoCab;
 const GX=112,GY=100,OX=24,OY=44,X0=480,X1=w-100,Y0=130,Y1=h-110;
 const sx=x=>Math.round((x-OX)/GX)*GX+OX,sy=y=>Math.round((y-OY)/GY)*GY+OY;
 const cl=(v,a,b)=>Math.min(Math.max(v,a),b);

 const a=st.player||{x:0,y:0},b=(dest&&dest.coords)||a;
 const dx=Math.max(Math.abs(b.x-a.x),80),dy=Math.max(Math.abs(b.y-a.y),80);
 const s=Math.min((X1-X0)/dx,(Y1-Y0)/dy,1.6),mx=(a.x+b.x)/2,my=(a.y+b.y)/2,cx=(X0+X1)/2,cy=(Y0+Y1)/2;
 const P=[sx(cl(cx+(a.x-mx)*s,X0,X1)),sy(cl(cy-(a.y-my)*s,Y0,Y1))];
 let D=[sx(cl(cx+(b.x-mx)*s,X0,X1)),sy(cl(cy-(b.y-my)*s,Y0,Y1))];
 if(P[0]===D[0]&&P[1]===D[1])D=[D[0]+(D[0]+GX<=X1+20?GX:-GX),D[1]];

 const xm=sx((P[0]+D[0])/2);
 const pts=[P,[xm,P[1]],[xm,D[1]],D].filter((p,i,r)=>!i||p[0]!==r[i-1][0]||p[1]!==r[i-1][1]);
 const v0=[Math.sign(pts[1][0]-P[0]),Math.sign(pts[1][1]-P[1])];
 const q=pts[pts.length-2],u=[Math.sign(D[0]-q[0]),Math.sign(D[1]-q[1])];

 let A=null,Ao='t';
 if(cab){
  const k=cl(Math.round((cab.etaMin||2)/2),1,3);
  if(v0[0]!==0){const ay=P[1]+GY*k;A=ay<=h-70?[P[0],ay]:[P[0],P[1]-GY*k];Ao=A[1]>P[1]?'b':'t'}
  else{const ax=P[0]+GX*k;A=ax<=w-60?[ax,P[1]]:[P[0]-GX*k,P[1]];Ao=A[0]>P[0]?'r':'l'}
 }

 const tierKey=cab?(cab.serviceType||st.selectedTier):st.selectedTier;
 const est=dest&&dest.coords?calcTierPrice(tierKey,dest.coords):null;
 const destName=cab?cab.destName:(dest&&dest.name)||'Tujuan';
 const carTxt=cab?`${cab.serviceName||'EcoCab'} · ${cab.etaMin||2} mnt`:'';
 const key=JSON.stringify([w,h,P,D,xm,A,carTxt,destName,est&&est.km,!!cab,st.surge&&st.surge.active]);
 if(el._k===key)return;el._k=key;

 const tw=t=>Math.min(250,40+7*String(t).length);
 const place=(pt,pref,t)=>{
  for(const o of [pref,'t','b']){
   if(o==='r'&&pt[0]+24+tw(t)<=w-12)return o;
   if(o==='l'&&pt[0]-24-tw(t)>=436)return o;
   if(o==='t'||o==='b')return o;
  }return 't';
 };
 const css=(pt,o,t)=>{
  if(o==='r')return`left:${pt[0]+24}px;top:${pt[1]}px`;
  if(o==='l')return`left:${pt[0]-24}px;top:${pt[1]}px`;
  const lx=cl(pt[0],436+tw(t)/2,w-12-tw(t)/2);
  return o==='t'?`left:${lx}px;top:${pt[1]-24}px`:`left:${lx}px;top:${pt[1]+24}px`;
 };
 const tag=(pt,pref,html,plain)=>{const o=place(pt,pref,plain);return`<div class="mp-tag t-${o}" style="${css(pt,o,plain)}">${html}</div>`};

 let g=`<svg class="map" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}" aria-hidden="true"><rect class="mp-land" width="${w}" height="${h}"/>`;
 g+=`<path class="mp-river" d="M${w*.66} -30 C${w*.78} ${h*.28} ${w*.58} ${h*.58} ${w*.84} ${h+30}"/>`;
 [[5,1],[8,4],[4,5],[9,1],[6,6],[7,0]].forEach(([i,j])=>{const x=OX+GX*i+8,y=OY+GY*j+8;if(x+GX<w&&y+GY<h)g+=`<rect class="mp-park" x="${x}" y="${y}" width="${GX-16}" height="${GY-16}" rx="10"/>`});
 for(let x=OX,i=0;x<w+GX;x+=GX,i++)g+=`<path class="${i%3===0?'mp-main':'mp-road'}" d="M${x} -10V${h+10}"/>`;
 for(let y=OY,j=0;y<h+GY;y+=GY,j++)g+=`<path class="${j%3===0?'mp-main':'mp-road'}" d="M-10 ${y}H${w+10}"/>`;
 g+=`<path class="mp-main" d="M-20 ${h*.9} L${w*.6} -20"/>`;
 const L=(t,x,y,rot)=>{if(x>0&&x<w&&y>0&&y<h)g+=`<text class="mp-lbl" x="${x}" y="${y}" ${rot?`transform="rotate(-90 ${x} ${y})"`:''}>${t}</text>`};
 L('Vespucci Blvd',OX+GX*4+16,OY+GY*3+4);L('Strawberry Ave',OX+GX*7+16,OY+GY*6+4);L('Sinner St',OX+GX*6+4,OY+GY*2+60,1);L('Alta St',OX+GX*9+4,OY+GY*5+60,1);

 const d=roundPath(pts,16);
 g+=`<path class="mp-case" d="${d}"/><path class="mp-route" d="${d}"/>`;
 if(A)g+=`<path class="mp-appr" d="M${A[0]} ${A[1]}L${P[0]} ${P[1]}"/>`;

 g+=`<circle class="mp-halo" cx="${P[0]}" cy="${P[1]}" r="26"/><circle class="mp-pin" cx="${P[0]}" cy="${P[1]}" r="10"/><circle class="mp-pin-in" cx="${P[0]}" cy="${P[1]}" r="3.5"/>`;
 g+=`<rect class="mp-pin" x="${D[0]-9}" y="${D[1]-9}" width="18" height="18" rx="4"/><rect class="mp-pin-in" x="${D[0]-3.5}" y="${D[1]-3.5}" width="7" height="7" rx="1.5"/>`;
 if(A)g+=`<circle class="mp-pin" cx="${A[0]}" cy="${A[1]}" r="18"/><use class="mp-car" href="#${cab.serviceType==='ecoride'?'motor':'taxi'}" x="${A[0]-11}" y="${A[1]-11}" width="22" height="22"/>`;
 g+='</svg>';

 const pPref=A?(v0[0]!==0?(Ao==='b'?'t':'b'):(v0[1]>0?'t':'b')):(v0[0]!==0?'t':(v0[1]>0?'t':'b'));
 const dPref=u[0]>0?'r':u[0]<0?'l':u[1]>0?'b':'t';
 g+=tag(P,pPref,'<b>Lokasi Anda</b>','Lokasi Anda');
 g+=tag(D,dPref,`<b>${esc(destName)}</b>${est?`<em>${est.km} km</em>`:''}`,destName+(est?' '+est.km+' km':''));
 if(A)g+=tag(A,Ao,`<b>${esc(carTxt)}</b>`,carTxt);
 el.innerHTML=g;
}

function rEcoCabView(){
 const disp=$('uActiveRideDisplay'),book=$('uBook'),cab=st.activeEcoCab;
 if(cab)st.cabSearching=false;
 $('vCab').classList.toggle('riding',!!cab||!!st.cabSearching);

 if(!cab&&!st.cabSearching){
  disp.style.display='none';
  book.style.display='flex';
  updateTierCards();
  return;
 }

 book.style.display='none';
 disp.style.display='flex';

 if(!cab){
  const sv=st.services[st.selectedTier]||{};
  const h=`<div class="rd-hero"><div class="rd-bar"><i></i></div><h3 style="margin-top:20px">Mencari driver untuk Anda</h3><p class="rd-arr">Menghubungi ${esc(sv.name||'EcoCab')} terdekat…</p></div>
  <div class="rd-body"><div class="rd-card"><div class="rd-trip"><div class="rd-rail"><span class="u-dot"></span><i></i><span class="u-sq"></span></div><div class="rd-stops"><div><small>Jemput</small><b>Lokasi Anda</b></div><div><small>Tujuan</small><b>${esc(st.cabTarget.name)}</b></div></div></div></div></div>
  <div class="u-foot"><button class="u-cancel" onclick="cancelCabOrder()">Batalkan pencarian</button></div>`;
  if(disp._h!==h){disp.innerHTML=h;disp._h=h}
  drawMap();return;
 }

 const isAI=cab.isAutonomous;
 const initial=isAI?ico('sparkle'):esc(cab.driverName?cab.driverName.charAt(0):'D');
 const eta=cab.etaMin||2;
 const html=`<div class="rd-hero">
  <span class="rd-badge">${esc(cab.serviceName||'EcoCab')}</span>
  <h3>Driver is on the way</h3>
  <div class="rd-eta"><b>${eta}</b><span>mnt</span></div>
  <p class="rd-arr">Perkiraan tiba sekitar ${clockAt(eta)}</p>
 </div>

 <div class="rd-body">
  ${cab.gasStop?`<div class="rd-alert">${ico('motor')}<span><b>Driver mampir isi bensin.</b> Sedang berhenti sebentar di SPBU terdekat sebelum melanjutkan perjalanan.</span></div>`:''}

  <div class="rd-card rd-driver">
   <div class="rd-avatar ${isAI?'ai':''}">${initial}</div>
   <div style="min-width:0">
    <h4>${esc(cab.driverName||'Driver')}</h4>
    <p>${isAI?'Armada listrik otonom vivanite2':'Driver resmi bersertifikasi'}</p>
   </div>
   <span class="rd-plate">${isAI?'LST-AI':'B 1945 ECO'}</span>
  </div>

  <div class="rd-card">
   <div class="rd-trip">
    <div class="rd-rail"><span class="u-dot"></span><i></i><span class="u-sq"></span></div>
    <div class="rd-stops">
     <div><small>Jemput</small><b>Lokasi Anda</b></div>
     <div><small>Tujuan pengantaran</small><b>${esc(cab.destName)}</b></div>
    </div>
   </div>
   <div class="rd-kv"><span>Jarak menuju tujuan</span><b>${cab.distKm||1.5} km</b></div>
   <div class="rd-kv"><span>Estimasi waktu tempuh</span><b>~${cab.etaMin||2} Menit</b></div>
   <div class="rd-kv"><span>Estimasi tarif</span><b>$${cab.estimatedFare||30}</b></div>
  </div>
 </div>

 <div class="u-foot"><button class="u-cancel" onclick="cancelCabOrder()">Batalkan pesanan</button></div>`;
 if(disp._h!==html){disp.innerHTML=html;disp._h=html}
 drawMap();
}

/* ---------- RATING MODAL (PASCA-TRIP) ---------- */
function setStar(n){
 st.ratingData.stars=n;
 document.querySelectorAll('.star').forEach((el,idx)=>{
  el.classList.toggle('dim',idx>=n);
 });
}
function setTip(amt){
 st.ratingData.tip=amt;
 document.querySelectorAll('.tip-chip').forEach(c=>{
  c.classList.toggle('on',c.textContent===`$${amt}`);
 });
}
function submitRatingDone(){
 $('rateModal').classList.remove('on');
 st.activeEcoCab = null;
 render();
 if(NUI){
  fetch(`https://${GetParentResourceName()}/submitRating`,{
   method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(st.ratingData)
  }).catch(()=>{});
 }
 toast(`Terima kasih atas ulasan ${st.ratingData.stars} bintang Anda!`);
}
function simTripComplete(){
 st.ratingData={stars:5,tip:0,driverName:st.activeEcoCab?st.activeEcoCab.driverName:'Agus Setiawan',serviceType:st.selectedTier};
 st.activeEcoCab=null;
 render();
 $('rateSubTitle').textContent=`Pengemudi: ${st.ratingData.driverName}`;
 $('rateModal').classList.add('on');
}

function rHome(all){
 all=all||nodes();
 const near=all.reduce((a,b)=>b.dist<a.dist?b:a),a=sched('bus',2),b=sched('subway',4);
 const r=(s,c,i)=>`<div class="wr"><span class="ico ${c}">${ico(i)}</span><span class="rt"><b>${s.node.name}</b><small>${s.best?(s.best.code+(s.best.routeShort?' · '+s.best.routeShort:'')):'Menunggu depo'}</small></span><span class="eta">${!s.best?'Depo':s.best.at?'Tiba':short(s.best.eta)}</span></div>`;
 $('wd1').innerHTML=`<h4>${ico('loop')}EcoLink · Kedatangan</h4>${r(a,'bus','bus')}${r(b,'sub','train')}`;
 
 if(st.activeEcoCab){
  const c=st.activeEcoCab;
  $('wd2').innerHTML=`<h4>${ico('taxi')}EcoCab · Pesanan aktif</h4><div class="nb" style="font-size:21px;line-height:1.15">${esc(c.destName)}</div><small>Driver: ${esc(c.driverName)}</small><div class="wd2-chips"><span>Tiba ${c.etaMin||2} mnt</span><span>Kelola pesanan</span></div>`;
 }else{
  const surgeTxt=(st.surge&&st.surge.active)?'⚡ Surge 1.25x Aktif':'Tarif mulai $15';
  $('wd2').innerHTML=`<h4>${ico('taxi')}EcoCab</h4><div class="wd2-search"><i></i>Mau ke mana?</div><div class="wd2-chips"><span>EcoLuxe</span><span>EcoCab</span><span>EcoRide</span><span style="color:var(--surge)">${surgeTxt}</span></div>`;
 }
}

function render(){
 const all=rSide();
 rDetail();
 rEcoCabView();
 rHome(all);
}

function clock(){
 const d=new Date(),D=['Min','Sen','Sel','Rab','Kam','Jum','Sab'],M=['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
 $('clk').textContent=String(d.getHours()).padStart(2,'0')+':'+String(d.getMinutes()).padStart(2,'0');
 $('dt').textContent=`${D[d.getDay()]} ${d.getDate()} ${M[d.getMonth()]}`;
}
let tt;function toast(m){$('toastT').textContent=m;$('toast').classList.add('on');clearTimeout(tt);tt=setTimeout(()=>$('toast').classList.remove('on'),2800)}

/* ---------- Navigasi Screen ---------- */
function pick(m,i){st.activeCode='';st.sel={mode:m,id:+i};render();$('main').scrollTop=0}
function pickVehicle(mode,code,targetId,routeId){
 st.activeCode=code;
 if(routeId)st.viewRoute=routeId;
 st.sel={mode,id:+targetId};
 render();
 $('main').scrollTop=0;
}
function setRouteTab(r){st.viewRoute=+r;rDetail()}
function setFilter(f){
 st.filter=f;
 st.activeCode='';
 if(f==='halte'&&st.sel.mode!=='bus')st.sel={mode:'bus',id:2};
 if(f==='stasiun'&&st.sel.mode!=='subway')st.sel={mode:'subway',id:4};
 if(f==='kereta'){
  st.sel.mode='subway';
  if(st.trains.length){st.activeCode=st.trains[0].code;st.sel={mode:'subway',id:st.trains[0].lastStationIdx||4};}
 }
 if(f==='bus'){
  st.sel.mode='bus';
  if(st.buses.length){st.activeCode=st.buses[0].code;st.viewRoute=Number(st.buses[0].routeId||1);st.sel={mode:'bus',id:st.buses[0].lastStopId||1};}
 }
 render();
}
function setSort(s){st.sort=s;rSide()}
function setQ(v){st.q=v||'';rSide()}

function setScreen(s){
 st.screen=s;
 $('vApp').classList.toggle('off',s!=='app');
 $('vHome').classList.toggle('off',s!=='home');
 $('vCab').classList.toggle('off',s!=='cab');
 $('scr').classList.toggle('onhome',s==='home');
 render();
}
function goHome(){setScreen('home')}
function toggleHome(){setScreen(st.screen==='home'?'app':'home')}
function openApp(f){setFilter(f||'halte');setScreen('app')}
function openEcoCabApp(){setScreen('cab');updateTierCards()}
function openNearest(){const a=nodes().sort((x,y)=>x.dist-y.dist)[0];st.filter=a.mode==='bus'?'halte':'stasiun';st.sel={mode:a.mode,id:a.id};setScreen('app');toast(`Titik terdekat: ${a.name} (${a.dist} m)`)}
function jump(){const t=xfer(st.sel.mode,st.sel.id);if(!t)return;st.sel=t;st.filter=t.mode==='bus'?'halte':'stasiun';render();toast('Beralih ke titik interkoneksi')}
function toggleTheme(){const l=document.documentElement.classList.toggle('light');toast(l?'Tampilan terang':'Tampilan gelap')}

function gps(){
 const l=st.sel.mode==='bus'?st.busStops:st.stations,n=l.find(x=>x.id===st.sel.id)||l[0];
 toast(`GPS diarahkan ke ${n.name}`);
 if(NUI)fetch(`https://${GetParentResourceName()}/setWaypoint`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({name:n.name,x:n.coords.x,y:n.coords.y})}).catch(()=>{});
}
function closeEcoTablet(){
 if(NUI)fetch(`https://${GetParentResourceName()}/closeTablet`,{method:'POST'}).catch(()=>{});
 else{goHome();toast('Di FiveM, tombol ini menutup iPad.')}
}

/* ---------- Simulasi Fleet (Pratinjau Browser) ---------- */
function initSim(){
 const R1=st.busRoutes["1"].nodes,R2=st.busRoutes["2"].nodes,S=st.stations,mid=(a,b)=>({...lerp(a.coords,b.coords,.5)});
 st.buses=[
  {netId:101,routeId:1,code:'R1-B01',lastNodeIdx:2,lastStopId:2,status:'STOPPED',elapsedInStatus:3,simProgress:0,coords:{...R1[1].coords}},
  {netId:102,routeId:1,code:'R1-B02',lastNodeIdx:4,lastStopId:4,status:'EN_ROUTE',elapsedInStatus:7,simProgress:.45,coords:mid(R1[3],R1[0])},
  {netId:103,routeId:2,code:'R2-B01',lastNodeIdx:6,lastStopId:5,status:'EN_ROUTE',elapsedInStatus:5,simProgress:.5,coords:mid(R2[5],R2[6])},
  {netId:104,routeId:2,code:'R2-B02',lastNodeIdx:10,lastStopId:9,status:'STOPPED',elapsedInStatus:4,simProgress:0,coords:{...R2[9].coords}}
 ];
 st.trains=[
  {netId:201,code:'LST-01',lastStationIdx:4,status:'STOPPED',elapsedInStatus:4,simProgress:0,coords:{...S[3].coords}},
  {netId:202,code:'LST-02',lastStationIdx:8,status:'EN_ROUTE',elapsedInStatus:12,simProgress:.48,coords:mid(S[7],S[8])}
 ];
}

function stepBusesSim(dt){
 const cfg=st.busCfg,dwell=cfg.WaitAtStopSeconds||12;
 st.buses.forEach(v=>{
  const rObj=st.busRoutes[String(v.routeId||1)]||st.busRoutes["1"];
  const ns=rObj.nodes;
  v.elapsedInStatus=(v.elapsedInStatus||0)+dt;
  const cur=ns[(v.lastNodeIdx-1)%ns.length],ni=v.lastNodeIdx%ns.length+1,nx=ns[ni-1];
  if(v.status==='STOPPED'){
   v.coords={...cur.coords};
   if(v.elapsedInStatus>=dwell){v.status='EN_ROUTE';v.elapsedInStatus=0;v.simProgress=.05;}
  }else{
   const spd=nx.isWaypoint?(cfg.CornerSpeed||7.5):(cfg.CruiseSpeed||10.0);
   const seg=Math.max(30,d3(cur.coords,nx.coords)*1.18);
   v.simProgress=Math.min(1,(v.simProgress||0)+dt/(seg/spd));
   v.coords=lerp(cur.coords,nx.coords,v.simProgress);
   v.status=nx.isWaypoint?'CORNERING':(v.simProgress>0.8?'APPROACHING':'EN_ROUTE');
   if(v.simProgress>=1){
    v.lastNodeIdx=ni;v.simProgress=0;v.elapsedInStatus=0;v.coords={...nx.coords};
    if(nx.isWaypoint)v.status='CORNERING';else{v.lastStopId=nx.stopId;v.status='STOPPED';}
   }
  }
 });
}

function stepTrainsSim(dt){
 const ns=st.stations,dwell=st.subCfg.WaitAtStationSeconds||15,spd=st.subCfg.CruiseSpeed||20;
 st.trains.forEach(v=>{
  v.elapsedInStatus=(v.elapsedInStatus||0)+dt;
  const cur=ns[(v.lastStationIdx-1)%ns.length],ni=v.lastStationIdx%ns.length+1,nx=ns[ni-1];
  if(v.status==='STOPPED'||v.status==='CLOSING_DOORS'){
   v.coords={...cur.coords};
   if(v.elapsedInStatus>=dwell){v.status='EN_ROUTE';v.elapsedInStatus=0;v.simProgress=.05;}
   else if(v.elapsedInStatus>=dwell-3)v.status='CLOSING_DOORS';
  }else{
   const seg=Math.max(180,d3(cur.coords,nx.coords)*1.15);
   v.simProgress=Math.min(1,(v.simProgress||0)+dt/(seg/spd));
   v.coords=lerp(cur.coords,nx.coords,v.simProgress);
   if(v.simProgress>=1){v.lastStationIdx=ni;v.status='STOPPED';v.elapsedInStatus=0;v.simProgress=0;v.coords={...nx.coords};}
  }
 });
}

function step(dt){if(NUI)return;stepBusesSim(dt);stepTrainsSim(dt);render()}
function toggleSim(){st.sim=!st.sim;$('bSim').textContent=st.sim?'Jeda simulasi':'Lanjutkan simulasi'}
function advance(s){step(s);toast(`Simulasi maju ${s} detik`)}
function spawn(m,rId){
 if(m==='bus'){
  rId=rId||1;
  const rNodes=st.busRoutes[String(rId)].nodes;
  const countInR=st.buses.filter(x=>x.routeId===rId).length+1;
  const code=`R${rId}-B0${countInR}`;
  st.buses.push({netId:100+st.buses.length+1,routeId:rId,code,lastNodeIdx:1,lastStopId:1,status:'STOPPED',elapsedInStatus:0,simProgress:0,coords:{...rNodes[0].coords}});
  render();toast(`${code} diberangkatkan di ${rNodes[0].name}`);
 }else{
  const ns=st.stations,n=st.trains.length+1,i=(n*3)%ns.length+1;
  st.trains.push({netId:200+n,code:'LST-0'+n,lastStationIdx:i,status:'STOPPED',elapsedInStatus:0,simProgress:0,coords:{...ns[i-1].coords}});
  render();toast(`LST-0${n} diberangkatkan di ${ns[i-1].name}`);
 }
}
function cyclePlayer(){st.preset=(st.preset+1)%PRESETS.length;st.player={...PRESETS[st.preset].c};render();toast('Lokasi pemain: '+PRESETS[st.preset].l)}

/* ---------- FiveM NUI Integration ---------- */
window.addEventListener('message',e=>{
 const d=e.data;if(!d||!d.action)return;
 if(d.action==='openTablet'){document.body.style.display='flex';$('ipad').style.display='';setScreen('home')}
 else if(d.action==='closeTablet'){$('ipad').style.display='none';if(NUI)document.body.style.display='none'}
 else if(d.action==='ecoCabUpdate'){st.activeEcoCab=d.activeRide||null;render()}
 else if(d.action==='updateSavedPlaces'){st.savedPlaces=d.savedPlaces||[];renderSavedPlaces();updateHomeWorkSubtitles();}
 else if(d.action==='updateSurgePricing'){
  st.surge={active:!!d.active,multiplier:Number(d.multiplier)||1.25,reason:d.reason||'Cuaca Buruk / Jam Malam'};
  updateTierCards();
 }
 else if(d.action==='updateEcoCabUserData'){
  st.userVip = d.vip || st.userVip;
  st.tripHistory = d.trips || [];
  renderVipPanel();
  renderHistoryList();
  updateTierCards();
 }
 else if(d.action==='showRatingModal'){
  const ride=d.ride||{};
  st.ratingData={stars:5,tip:0,driverName:ride.driverName||'Driver',serviceType:ride.serviceType||'ecocab'};
  // Pastikan state aktif dibersihkan agar status kembali selesai
  st.activeEcoCab = null;
  render();
  $('rateSubTitle').textContent=`Pengemudi: ${st.ratingData.driverName} (${ride.destName||'Tujuan'})`;
  setStar(5);setTip(0);
  $('rateModal').classList.add('on');
 }
 else if(d.action==='updateTelemetry'){
  if(d.playerCoords)st.player=d.playerCoords;
  if(d.busTransit)st.busCfg=d.busTransit;
  if(d.busRoutes)st.busRoutes=d.busRoutes;
  if(d.subwayTransit)st.subCfg=d.subwayTransit;
  if(d.surge)st.surge=d.surge;
  if(Array.isArray(d.busStops)&&d.busStops.length)st.busStops=d.busStops;
  if(Array.isArray(d.metroStations)&&d.metroStations.length)st.stations=d.metroStations;
  if(Array.isArray(d.ecoCabDestinations)&&d.ecoCabDestinations.length)st.ecoCabDestinations=d.ecoCabDestinations;
  if(Array.isArray(d.savedPlaces))st.savedPlaces=d.savedPlaces;
  if(d.activeEcoCab!==undefined)st.activeEcoCab=d.activeEcoCab;
  if(d.services)st.services=d.services;
  if(Array.isArray(d.buses))st.buses=d.buses;
  if(Array.isArray(d.trains))st.trains=d.trains;
  if(typeof d.nextBusDispatchIn==='number')st.nextBus=d.nextBusDispatchIn;
  if(d.nextBusDispatchByRoute)st.nextBusByRoute=d.nextBusDispatchByRoute;
  if(typeof d.nextTrainDispatchIn==='number')st.nextTrain=d.nextTrainDispatchIn;
  render();
 }
});
window.addEventListener('keydown',e=>{if(e.key==='Escape')closeEcoTablet();if((e.key==='Enter'||e.key===' ')&&e.target.classList&&e.target.classList.contains('u-tier-card')){e.preventDefault();e.target.click()}});
window.addEventListener('resize',()=>{if(st.screen==='cab')drawMap()});
window.onload=()=>{
 clock();setInterval(clock,15000);
 if(NUI){document.body.className='nui';$('dev').style.display='none';$('ipad').style.display='none';document.body.style.display='none'}
 else{initSim();render();setInterval(()=>{if(st.sim)step(1)},1000)}
};
