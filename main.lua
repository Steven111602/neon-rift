local R = require("rules")
local p, enemies, shots, particles, state, wave, score, spawned, spawnClock, fireClock
local dash, dashCD, hurt, time, best, upgrades
local function reset()
 p={x=R.width/2,y=R.height/2,hp=R.startingHealth,speed=R.playerSpeed,damage=1,delay=R.fireDelay}
 enemies={}; shots={}; particles={}; wave=1; score=0; spawned=0; spawnClock=0; fireClock=0
 dash=0; dashCD=0; hurt=0; time=0; upgrades=0; state="playing"
end
local function burst(x,y)
 for i=1,14 do local a=love.math.random()*math.pi*2
  table.insert(particles,{x=x,y=y,vx=math.cos(a)*180,vy=math.sin(a)*180,life=0.5}) end
end
local function upgrade(n)
 if state~="upgrade" then return end
 if n==1 then p.delay=math.max(.055,p.delay*.82)
 elseif n==2 then p.damage=p.damage+1
 elseif n==3 then p.hp=math.min(R.startingHealth,p.hp+2); p.speed=p.speed+20 else return end
 wave=wave+1; spawned=0; spawnClock=0; state="playing"; upgrades=upgrades+1
end
function love.load()
 love.graphics.setFont(love.graphics.newFont(18))
 best=tonumber(love.filesystem.read("best.txt")) or 0
 state="title"; reset(); state="title"
end
function love.keypressed(k)
 if k=="escape" and state=="playing" then state="paused"
 elseif k=="escape" and state=="paused" then state="playing"
 elseif (k=="return" or k=="r") and (state=="title" or state=="dead") then reset()
 elseif state=="upgrade" then upgrade(tonumber(k)) end
end
function love.update(dt)
 if state~="playing" then return end
 dt=math.min(dt,.04); time=time+dt; hurt=math.max(0,hurt-dt); dashCD=math.max(0,dashCD-dt); dash=math.max(0,dash-dt)
 local x,y=0,0; local down=love.keyboard.isDown
 if down("w","z","up") then y=y-1 end; if down("s","down") then y=y+1 end
 if down("a","q","left") then x=x-1 end; if down("d","right") then x=x+1 end
 local len=math.sqrt(x*x+y*y)
 if len>0 then
  if down("space") and dashCD==0 then dash=R.dashDuration; dashCD=R.dashCooldown end
  local speed=dash>0 and R.dashSpeed or p.speed
  p.x=math.max(18,math.min(R.width-18,p.x+x/len*speed*dt)); p.y=math.max(75,math.min(R.height-18,p.y+y/len*speed*dt))
 end
 local sw,sh=love.graphics.getDimensions(); local scale=math.min(sw/R.width,sh/R.height)
 local mx,my=love.mouse.getPosition(); mx=(mx-(sw-R.width*scale)/2)/scale; my=(my-(sh-R.height*scale)/2)/scale
 fireClock=fireClock-dt
 if love.mouse.isDown(1) and fireClock<=0 then
  local a=math.atan(my-p.y,mx-p.x); table.insert(shots,{x=p.x,y=p.y,vx=math.cos(a)*R.bulletSpeed,vy=math.sin(a)*R.bulletSpeed,life=1.8}); fireClock=p.delay
 end
 spawnClock=spawnClock-dt
 local total=R.waveBase+wave*R.waveGrowth
 if spawned<total and spawnClock<=0 then
  local side=love.math.random(4); local ex=love.math.random(20,R.width-20); local ey=love.math.random(80,R.height-20)
  if side==1 then ex=-20 elseif side==2 then ex=R.width+20 elseif side==3 then ey=60 else ey=R.height+20 end
  table.insert(enemies,{x=ex,y=ey,hp=1+math.floor(wave/3),r=13+math.min(wave,10),speed=R.enemySpeed+wave*9}); spawned=spawned+1; spawnClock=.55
 end
 for i=#shots,1,-1 do local b=shots[i]; b.x=b.x+b.vx*dt; b.y=b.y+b.vy*dt; b.life=b.life-dt
  for j=#enemies,1,-1 do local e=enemies[j]
   if (b.x-e.x)^2+(b.y-e.y)^2<(e.r+4)^2 then
    e.hp=e.hp-p.damage; b.life=0
    if e.hp<=0 then burst(e.x,e.y); table.remove(enemies,j); score=score+R.killScore*wave end
    break
   end
  end
  if b.life<=0 then table.remove(shots,i) end
 end
 for _,e in ipairs(enemies) do
  local dx,dy=p.x-e.x,p.y-e.y; local l=math.max(.001,math.sqrt(dx*dx+dy*dy)); e.x=e.x+dx/l*e.speed*dt; e.y=e.y+dy/l*e.speed*dt
  if l<e.r+13 and hurt==0 and dash==0 then
   p.hp=p.hp-1; hurt=1; burst(p.x,p.y)
   if p.hp<=0 then state="dead"; best=math.max(best,score); love.filesystem.write("best.txt",tostring(best)); return end
  end
 end
 for i=#particles,1,-1 do local b=particles[i]; b.x=b.x+b.vx*dt; b.y=b.y+b.vy*dt; b.life=b.life-dt; if b.life<=0 then table.remove(particles,i) end end
 if spawned==total and #enemies==0 then shots={}; state="upgrade" end
end
local function label(s,y,size)
 love.graphics.setFont(love.graphics.newFont(size or 22)); love.graphics.printf(s,0,y,R.width,"center")
end
function love.draw()
 local g=love.graphics; local w,h=g.getDimensions(); local sc=math.min(w/R.width,h/R.height)
 g.clear(.025,.035,.075); g.push(); g.translate((w-R.width*sc)/2,(h-R.height*sc)/2); g.scale(sc)
 g.setColor(.06,.11,.17); for x=0,R.width,40 do g.line(x,64,x,R.height) end; for y=64,R.height,40 do g.line(0,y,R.width,y) end
 g.setColor(.18,.95,.85); g.rectangle("line",1,64,R.width-2,R.height-65)
 for _,b in ipairs(particles) do g.setColor(1,.35,.65,b.life*2); g.circle("fill",b.x,b.y,3) end
 for _,e in ipairs(enemies) do g.setColor(1,.23,.48); g.circle("line",e.x,e.y,e.r); g.circle("fill",e.x,e.y,5) end
 g.setColor(.9,1,.6); for _,b in ipairs(shots) do g.circle("fill",b.x,b.y,4) end
 g.setColor(.2,1,.85,hurt>0 and .5 or 1); g.circle("fill",p.x,p.y,13); g.circle("line",p.x,p.y,20)
 g.setFont(g.newFont(18)); g.setColor(.85,.93,1); g.print("NEON RIFT   /   VAGUE "..wave,20,20); g.print("SCORE "..score,440,20); g.print("VIE "..p.hp.."   DASH "..(dashCD==0 and "OK" or string.format("%.1f",dashCD)),800,20)
 if state~="playing" then
  g.setColor(.015,.025,.06,.93); g.rectangle("fill",140,170,820,390,20); g.setColor(.2,1,.85)
  if state=="title" then label("NEON RIFT",220,58); label("SURVIS. EVOLUE. RECOMMENCE.",300); label("ZQSD / WASD : bouger | Souris : viser et tirer",365); label("Espace : dash | Echap : pause",405); label("ENTREE POUR JOUER",485)
  elseif state=="upgrade" then label("VAGUE TERMINEE",225,40); label("Choisis une amelioration",295); label("1 / Cadence +22%",355); label("2 / Degats +1",400); label("3 / Soin +2 et vitesse +20",445)
  elseif state=="paused" then label("PAUSE",270,48); label("Echap pour reprendre",375)
  else label("SIGNAL PERDU",240,48); label("Score : "..score.."  |  Record : "..best,340); label("Entree pour recommencer",430) end
 end
 g.pop()
end
