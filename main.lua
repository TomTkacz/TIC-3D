-- title: 3D
-- author:  Tom Tkacz, github.com/TomTkacz
-- desc:    3D rendering
-- site:    https://www.thomastkacz.com
-- license: MIT License
-- script:  lua

include "include.Lookup"
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
include "class.Matrix4D"
include "class.Object3D"
include "debug.Profiler"

-- GLOBAL VALUES --

SCREEN_WIDTH=240
SCREEN_HEIGHT=136
MAP_BASE_ADDRESS=0x8000
MAP_SIZE_BYTES=32640
PI=3.1415927
TWO_PI=6.2831854
PI_OVER_TWO=1.57079635
WORLD_ORIGIN=Pos3D(0,0,0)
Z_BUFFER={}
DEBUG=false
X_AXIS,Y_AXIS,Z_AXIS = Dir3D(1,0,0),Dir3D(0,1,0),Dir3D(0,0,1)

-- SCENE COMPONENTS --

camera=Camera( Pos3D(0,0,0), Rot3D(0,0,0), Dir3D(0,0,1) )

viewport={
	size=Size2D(SCREEN_WIDTH,SCREEN_HEIGHT),
	fov=90,
}
function viewport:updateFocalDist()
	self._focalDist = self.size.w / ( 2*math.tan(math.rad(self.fov)/2) )
	self._vfov = 2 * math.atan( self.size.h, (2*self._focalDist) ) -- in radians
	Matrix4D.screenProjectionMatrix[1][1],Matrix4D.screenProjectionMatrix[2][2]=self._focalDist,self._focalDist
end
viewport:updateFocalDist()

HalfViewportWidth,HalfViewportHeight = viewport.size.w/2,viewport.size.h/2
ScreenWidthScale,ScreenHeightScale = SCREEN_WIDTH/viewport.size.w,SCREEN_HEIGHT/viewport.size.h

light={
	pos=Pos3D(-5,6,5)
}

gmouse={
	sensitivity=70,
}

scene={
	lights={},
	loadedObjects={},
	activeObjects={},
	get = function(id)
		return scene.activeObjects[id]
	end
}

-- METHODS --

function initializeZBuffer()
	local huge = math.huge
	for col=1,SCREEN_WIDTH do
		if not Z_BUFFER[col] then Z_BUFFER[col] = {} end
		local zcol = Z_BUFFER[col]
		for row=1,SCREEN_HEIGHT do
			zcol[row] = huge
		end
	end
end

function calculateMeshOrigin(mesh)
	local xAvg,yAvg,zAvg=0,0,0
	for _,triangle in pairs(mesh.triangles) do
		for _,vertex in pairs(triangle.vertices) do
			xAvg=xAvg+vertex.x
			yAvg=yAvg+vertex.y
			zAvg=zAvg+vertex.z
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
	return math.sqrt(delta:getDotProduct(delta))
end

function dirBetween3DPoints(p1,p2)
	local dist = distBetween3DPoints(p1,p2)
	local dx = p2.x-p1.x
	local dy = p2.y-p1.y
	local dz = p2.z-p1.z
	return Dir3D(dx/dist,dy/dist,dz/dist)
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
	abPerpDir:rotateAboutAxis(faceNormal,PI_OVER_TWO)

	local bcMidpoint = (pB+pC)/2
	local bcPerpDir = dirBetween3DPoints(pB,pC)
	bcPerpDir:rotateAboutAxis(faceNormal,PI_OVER_TWO)

	local a = 0
	local lastDifference = math.huge
	while a < 5 do
		local left = ( abPerpDir:getCrossProduct(bcPerpDir) ) * a
		local right = ( bcMidpoint - abMidpoint ):getCrossProduct(bcPerpDir)
		local difference = (left-right):getMagnitude()
		if difference > lastDifference then break end
		lastDifference = difference
		a=a+0.01
	end

	return translate3D(abMidpoint,abPerpDir,a)
end

function updateMouseInfo()
	if not gmouse.x then gmouse.x=0 end
	if not gmouse.y then gmouse.y=0 end
	if not gmouse.previous then gmouse.previous={} end
	gmouse.previous.x=gmouse.x
	gmouse.previous.y=gmouse.y
	gmouse.previous.down=mouseDown
	gmouse.x,gmouse.y,gmouse.down=mouse()
	gmouse.deltaX=gmouse.x-gmouse.previous.x
	gmouse.deltaY=gmouse.previous.y-gmouse.y
end

function renderScreen()
	initializeZBuffer()
	for _,obj in pairs(scene.activeObjects) do
		obj:render()
	end
end

-- MAIN LOOP --

t=0
frameStartTimeMilliseconds=0
frameEndTimeMilliseconds=0
fpsInterval=5
currentFPS=0

function TIC()

	updateMouseInfo()

	if t==0 then
		camera:updateVectors()
		camera:initalizeClippingPlanes()
		camera:updateClippingPlanes()
		loadObjects()
		cube=Object3D("mesh","mips",Pos3D(0,-1.4,5),Rot3D(0,0,0),Dir3D(0,0,1),0.2)
		if DEBUG then profiler.start() end
	end

	cls(0)

	if btn(0) then camera.pos=translate3D(camera.pos,camera.dir,0.1) end --forward
	if btn(1) then camera.pos=translate3D(camera.pos,camera.dir,-0.1) end --backward
	if btn(2) then camera.pos=translate3D(camera.pos,camera.horizontalVector,0.1) end --right
	if btn(3) then camera.pos=translate3D(camera.pos,camera.horizontalVector,-0.1) end --left

	if btn(4) then
		scene.get(cube).rot:rotate(0,0.1,0)
	end

	if gmouse.down then
		physicalSpace = (gmouse.deltaX/SCREEN_WIDTH)*viewport.size.w*(gmouse.sensitivity/100)
		camera:rotate( Rot3D(0,2*PI*(physicalSpace/viewport.size.w),0) )
	end

	camera:updateVectors()
	camera:updateClippingPlanes()

	renderScreen()

	if DEBUG and t==10 then
		profiler.stop()
		trace(profiler.report(20))
		exit()
	end

	if t%fpsInterval==0 then
		frameEndTimeMilliseconds=time()
		currentFPS=fpsInterval/((frameEndTimeMilliseconds-frameStartTimeMilliseconds)/1000)
		frameStartTimeMilliseconds=time()
	end

	print("FPS:"..round(currentFPS,2))

	t=t+1
end