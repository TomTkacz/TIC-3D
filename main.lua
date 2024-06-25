-- title: 3D
-- author:  Tom Tkacz, github.com/TomTkacz
-- desc:    3D rendering
-- site:    https://www.thomastkacz.com
-- license: MIT License
-- script:  lua

include "class.Pos3D"
include "class.Pos2D"
include "class.Rot3D"
include "class.Size2D"
include "class.Ray"
include "class.Matrix"
include "include.Pickle"
include "class.Object3D"

-- GLOBAL VALUES --

camera={
	pos=Pos3D(0,0,0),
	rot=Rot3D(0,0,1)
}

screen={
	size=Size2D(50,50),
	pixels={}
}

viewport={
	size=Size2D(150,150),
	focalDist=150,
	points={}
}

sphere=Object3D("sphere",Pos3D(0,0,15),5)

light={
	pos=Pos3D(-5,6,5)
}

gmouse={
	sensitivity=30,
}

scene={
	lights={},
	objects={},
}

-- INITIALIZATION METHODS --

function initScreenPixels()
	for y=1,screen.size.h do
		screen.pixels[y]={}
		for x=1,screen.size.w do
			screen.pixels[y][x]=0
		end
	end
end

-- CONVERSION METHODS --

function screenSpaceToViewportSpace(screenX,screenY)
	local xOffset = screenX*(viewport.size.w/screen.size.w)
	local yOffset = (screenY*(viewport.size.h/screen.size.h))
	local position = translate3D(viewport.base,viewport.horizontalVector,xOffset)
	return translate3D(position,viewport.verticalVector,-yOffset)
end

-- METHODS --

function updateViewportVectors()
	viewport.center = translate3D(camera.pos,camera.rot,viewport.focalDist)
	viewport.horizontalVector = Rot3D(camera.rot.x,camera.rot.y,camera.rot.z)
	viewport.verticalVector = Rot3D(camera.rot.x,camera.rot.y,camera.rot.z)
	viewport.horizontalVector:rotate(0,-math.pi/2,0)
	viewport.verticalVector:rotateAboutVector(viewport.horizontalVector,math.pi/2)
	viewport.base = translate3D(viewport.center,viewport.horizontalVector,-viewport.size.w/2)
	viewport.base = translate3D(viewport.base,viewport.verticalVector,viewport.size.h/2)
end

function translate3D(pos,dir,dist)
	local newX = pos.x+(dir.x*dist)
	local newY = pos.y+(dir.y*dist)
	local newZ = pos.z+(dir.z*dist)
	return Pos3D(newX,newY,newZ)
end

function distBetween3DPoints(p1,p2)
	local delta = p1-p2
	return math.sqrt(delta:dot(delta))
end

function round(n,d)
	return math.floor(n*math.pow(10,d))/math.pow(10,d)
end

function dirBetween3DPoints(p1,p2)
	local dist = distBetween3DPoints(p1,p2)
	local dx = p2.x-p1.x
	local dy = p2.y-p1.y
	local dz = p2.z-p1.z
	return Rot3D(round(dx/dist,4),round(dy/dist,4),round(dz/dist,4))
end

function drawPixels()
	for y=1,screen.size.h do
		for x=1,screen.size.w do
			pix(x+95,y+40,screen.pixels[y][x])
		end
	end
	rectb(95,40,52,52,12)
end

function renderPixel(x,y)
	targetpos=screenSpaceToViewportSpace(x,y)
	r=Ray.fromPoints(camera.pos,targetpos)

	hit=sphere:getHitPoint(r)

	if not hit or hit < 0 then
		screen.pixels[y][x]=0
	elseif sphere.hasCustomRenderRoutine then
		screen.pixels[y][x]=sphere:renderColor(r,hit)
	elseif hit>=0 then
		-- checker pattern for missing render routine
		screen.pixels[y][x]=12+((y%2)+(x%2))%2
	end
end

function updateMouseInfo()
	if gmouse.x==nil then gmouse.x=0 end
	if gmouse.y==nil then gmouse.y=0 end
	if gmouse.previous==nil then gmouse.previous={} end
	gmouse.previous.x=gmouse.x
	gmouse.previous.y=gmouse.y
	gmouse.previous.down=mouseDown
	gmouse.x,gmouse.y,gmouse.down=mouse()
	gmouse.deltaX=gmouse.x-gmouse.previous.x
	gmouse.deltaY=gmouse.previous.y-gmouse.y
end

-- OBJECTS --

t=0

function TIC()

	updateMouseInfo()
	if t==0 then
		initScreenPixels()
	end
	if btn(0) then camera.pos=translate3D(camera.pos,camera.rot,0.5) end
	if btn(1) then camera.pos=translate3D(camera.pos,camera.rot,-0.5) end
	if btn(2) then camera.pos=translate3D(camera.pos,viewport.horizontalVector,-0.5) end
	if btn(3) then camera.pos=translate3D(camera.pos,viewport.horizontalVector,0.5) end
	cls(0)

	if gmouse.down then
		physicalSpace = (gmouse.deltaX/screen.size.w)*viewport.size.w*(gmouse.sensitivity/100)
		camera.rot:rotate(0,-(2*math.pi)*(physicalSpace/viewport.size.w),0)
	end

	light.pos.x=10*math.sin(t/100)
	light.pos.z=10*math.cos(t/100)+15
	light.pos.y=3*math.sin(t/180)

	updateViewportVectors()
	for y=1,screen.size.h do
		for x=1,screen.size.w do
			renderPixel(x,y)
		end
	end
	drawPixels()
	
	rectb(150,0,41,41,12)
	pix(math.floor(light.pos.x/2+0.5)+170,20-math.floor(light.pos.z/2+0.5),12)
	circ(170+math.floor(sphere.pos.x/2+0.5),20-math.floor(sphere.pos.z/2+0.5),sphere.r/2,5)
	circ(170+math.floor(camera.pos.x/2+0.5),20-math.floor(camera.pos.z/2+0.5),0.5,8)
		
	t=t+1
end