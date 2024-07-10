-- title: 3D
-- author:  Tom Tkacz, github.com/TomTkacz
-- desc:    3D rendering
-- site:    https://www.thomastkacz.com
-- license: MIT License
-- script:  lua

include "include.Utils"
include "include.LoadObjects"
include "class.Pos3D"
include "class.Pos2D"
include "class.Rot3D"
include "class.Dir3D"
include "class.Size2D"
include "class.Ray"
include "class.Matrix"
include "class.Object3D"

-- GLOBAL VALUES --

SCREEN_WIDTH=240
SCREEN_HEIGHT=136
MAP_BASE_ADDRESS=0x8000
MAP_SIZE_BYTES=32640

-- SCENE COMPONENTS --

camera={
	pos=Pos3D(0,0,0),
	rot=Rot3D(0,0,0),
	dir=Dir3D(0,0,1),
}
function camera:rotate(x,y,z)
	self.rot=self.rot+Rot3D(x,y,z)
	self.dir = Dir3D(0,0,1)
	self.dir:rotate(self.rot.x,-self.rot.y,self.rot.z)
end
camera.dir:rotate(camera.rot.x,camera.rot.y,camera.rot.z)

viewport={
	size=Size2D(SCREEN_WIDTH,SCREEN_HEIGHT),
	fov=90,
	points={}
}
function viewport:updateFocalDist()
	self.focalDist = self.size.w / ( 2*math.tan(self.fov/2) )
end
viewport:updateFocalDist()

light={
	pos=Pos3D(-5,6,5)
}

gmouse={
	sensitivity=30,
}

scene={
	lights={},
	loadedObjects={},
	activeObjects={},
	get = function(id)
		return scene.activeObjects[id]
	end
}

-- CONVERSION METHODS --

function worldSpaceToViewportSpace(pos)
	local x,y,z = pos.x,pos.y,pos.z
	local vpX = (x*viewport.focalDist)/z
	local vpY = (y*viewport.focalDist)/z
	return Pos2D(vpX+viewport.size.w/2,vpY+viewport.size.h/2)
end

function viewportSpaceToScreenSpace(pos)
	local x,y = pos.x,pos.y
	local screenX = (x*SCREEN_WIDTH)/viewport.size.w
	local screenY = (y*SCREEN_HEIGHT)/viewport.size.h
	return Pos2D(screenX,screenY)
end

function worldSpaceToScreenSpace(pos)
	return viewportSpaceToScreenSpace(worldSpaceToViewportSpace(pos))
end

-- METHODS --

function calculateMeshOrigin(mesh)
	local xAvg,yAvg,zAvg=0,0,0
	for _,triangle in pairs(mesh.triangles) do
		for _,vertex in pairs(triangle) do
			xAvg=xAvg+vertex[1]
			yAvg=yAvg+vertex[2]
			zAvg=zAvg+vertex[3]
		end
	end
	xAvg=xAvg/mesh.numberOfTriangles
	yAvg=yAvg/mesh.numberOfTriangles
	zAvg=zAvg/mesh.numberOfTriangles
	return Pos3D(xAvg,yAvg,zAvg)
end

function getMeshRelativeToOrigin(mesh,origin)
	newmesh=mesh
	for t,triangle in ipairs(newmesh.triangles) do
		for v,vertex in ipairs(triangle) do
			vPos=Pos3D(table.unpack(vertex))
			vPos=vPos-origin
			newmesh.triangles[t][v]={vPos.x,vPos.y,vPos.z}
		end
	end
	return newmesh
end

-- function updateViewportVectors()
-- 	viewport.center = translate3D(camera.pos,camera.rot,viewport.focalDist)
-- 	viewport.horizontalVector = Rot3D(camera.rot.x,camera.rot.y,camera.rot.z)
-- 	viewport.verticalVector = Rot3D(camera.rot.x,camera.rot.y,camera.rot.z)
-- 	viewport.horizontalVector:rotate(0,-math.pi/2,0)
-- 	viewport.verticalVector:rotateAboutAxis(viewport.horizontalVector,math.pi/2)
-- 	viewport.base = translate3D(viewport.center,viewport.horizontalVector,-viewport.size.w/2)
-- 	viewport.base = translate3D(viewport.base,viewport.verticalVector,viewport.size.h/2)
-- end

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

function dirBetween3DPoints(p1,p2)
	local dist = distBetween3DPoints(p1,p2)
	local dx = p2.x-p1.x
	local dy = p2.y-p1.y
	local dz = p2.z-p1.z
	return Dir3D(round(dx/dist,4),round(dy/dist,4),round(dz/dist,4))
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

function renderScreen()
	for _,obj in pairs(scene.activeObjects) do
		obj:render()
	end
end

-- MAIN LOOP --

t=0

function TIC()

	updateMouseInfo()

	if t==0 then
		loadObjects()
		cube=Object3D("mesh","cube",Pos3D(0,0,5),Rot3D(0,0,0),Dir3D(0,0,1),0.5)
	end

	cls(0)

	if btn(0) then camera.pos=translate3D(camera.pos,camera.dir,0.1) end --forward
	if btn(1) then camera.pos=translate3D(camera.pos,camera.dir,-0.1) end --backward
	if btn(2) then camera:rotate(0,-math.pi/32,0) end--right
	if btn(3) then camera:rotate(0,math.pi/32,0) end --left

	if gmouse.down then
		physicalSpace = (gmouse.deltaX/SCREEN_WIDTH)*viewport.size.w*(gmouse.sensitivity/100)
		camera:rotate(0,-(2*math.pi)*(physicalSpace/viewport.size.w),0)
	end

	scene.get(cube).rot:rotate(0,math.pi/64,0)

	-- light.pos.x=10*math.sin(t/100)
	-- light.pos.z=10*math.cos(t/100)+15
	-- light.pos.y=3*math.sin(t/180)

	renderScreen()
		
	t=t+1
end