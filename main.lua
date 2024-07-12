-- title: 3D
-- author:  Tom Tkacz, github.com/TomTkacz
-- desc:    3D rendering
-- site:    https://www.thomastkacz.com
-- license: MIT License
-- script:  lua

include "include.Utils"
include "include.LoadObjects"
include "class.Camera"
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

camera=Camera( Pos3D(0,0,0), Rot3D(0,0,0), Dir3D(0,0,1) )

viewport={
	size=Size2D(SCREEN_WIDTH,SCREEN_HEIGHT),
	fov=90,
}
function viewport:updateFocalDist()
	self._focalDist = self.size.w / ( 2*math.tan(self.fov/2) )
	self._vfov = 2 * math.atan( self.size.h, (2*self._focalDist) ) -- in radians
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
	local vpX = (x*viewport._focalDist)/z
	local vpY = (y*viewport._focalDist)/z
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

function getSurfaceNormal(p1,p2,p3)
	local a = p2 - p1
	local b = p3 - p1
	local nX = a.y * b.z - a.z * b.y
	local nY = a.z * b.x - a.x * b.z
	local nZ = a.x * b.y - a.y * b.x
	return Dir3D(nX,nY,nZ)
end

function getTriangleCircumcenter(pA,pB,pC)
	local faceNormal = getSurfaceNormal(pA,pB,pC)

	local abMidpoint = (pA+pB)/2
	local abPerpDir = dirBetween3DPoints(pA,pB)
	abPerpDir:rotateAboutAxis(faceNormal,math.pi/2)

	local bcMidpoint = (pB+pC)/2
	local bcPerpDir = dirBetween3DPoints(pB,pC)
	bcPerpDir:rotateAboutAxis(faceNormal,math.pi/2)

	-- L1 = abMidpoint + a * abPerpDir
	-- L2 = bcMidpoint + b * bcPerpDir
	-- abMidpoint + a * abPerpDir = bcMidpoint + b * bcPerpDir
	-- a * abPerpDir = ( bcMidpoint - abMidpoint ) + b * bcPerpDir
	-- a * ( abPerpDir * bcPerpDir ) = ( bcMidpoint - abMidpoint ) * bcPerpDir

	local a = 0
	local lastDifference = math.huge
	while a < 5 do
		local left = ( abPerpDir:cross(bcPerpDir) ) * a
		local right = ( bcMidpoint - abMidpoint ):cross(bcPerpDir)
		local difference = (left-right):magnitude()
		if difference > lastDifference then break end
		lastDifference = difference
		a=a+0.01
	end

	return translate3D(abMidpoint,abPerpDir,a)
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
		camera:updateVectors()
		camera:updateClippingPlanes()
		loadObjects()
		cube=Object3D("mesh","cube",Pos3D(0,0,5),Rot3D(0,0,0),Dir3D(0,0,1),0.5)
	end

	cls(0)

	if btn(0) then camera.pos=translate3D(camera.pos,camera.dir,0.1) end --forward
	if btn(1) then camera.pos=translate3D(camera.pos,camera.dir,-0.1) end --backward
	if btn(2) then camera:rotate( Rot3D(0,-math.pi/32,0) ) end --right
	if btn(3) then camera:rotate( Rot3D(0,math.pi/32,0) ) end --left

	camera:updateVectors()
	camera:updateClippingPlanes()

	if gmouse.down then
		physicalSpace = (gmouse.deltaX/SCREEN_WIDTH)*viewport.size.w*(gmouse.sensitivity/100)
		camera:rotate( Rot3D(0,2*math.pi*(physicalSpace/viewport.size.w),0) )
	end

	--scene.get(cube).rot:rotate(0,math.pi/64,0)

	-- light.pos.x=10*math.sin(t/100)
	-- light.pos.z=10*math.cos(t/100)+15
	-- light.pos.y=3*math.sin(t/180)

	renderScreen()
	t=t+1
end