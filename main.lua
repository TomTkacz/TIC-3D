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
include "class.Object3D"

-- GLOBAL VALUES --

MAP_BASE_BYTE_ADDRESS=0x8000
MAP_SIZE_BYTES=32640

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

sphere=Object3D("sphere",Pos3D(0,0,15),5)

-- INITIALIZATION METHODS --

function initScreenPixels()
	for y=1,screen.size.h do
		screen.pixels[y]={}
		for x=1,screen.size.w do
			screen.pixels[y][x]=0
		end
	end
end

function loadObjects()
	objects={}

	bytesOffset = 0

	-- get current byte address from byte offset
	local function curByteAddr()
		return MAP_BASE_BYTE_ADDRESS+bytesOffset
	end

	-- get current nibble address from byte offset
	local function curNibbleAddr()
		return (MAP_BASE_BYTE_ADDRESS+bytesOffset)*2
	end

	-- get current bit address from byte offset
	local function curBitAddr()
		return (MAP_BASE_BYTE_ADDRESS+bytesOffset)*8
	end

	while bytesOffset < MAP_SIZE_BYTES do

		meshName = ""

		for i=1,12 do
			if peek(curByteAddr()) ~= 0 then
				meshName = meshName..codepoint_to_utf8(peek(curByteAddr()))
			end
			bytesOffset = bytesOffset + 1
		end

		numberOfTriangles = peek(curByteAddr())
		if numberOfTriangles == 0 then break end

		mesh = {meshName}

		bytesOffset = bytesOffset + 2 -- skip over flags for now

		for a=1,numberOfTriangles do

			triangle={}

			for b=1,3 do

				vertex={}

				for c=1,3 do

					-- reads first bit
					if peek(curBitAddr()+7,1) == 0 then sign=1 else sign=-1 end
					
					-- reads byte, removes leftmost bit, shifts left once, ORs with first bit of next byte
					b1 = peek(curByteAddr())
					if b1 >= 128 then b1 = b1 - 128 end
					b1 = b1 << 1
					b1 = b1 | (peek(curByteAddr()+1) >> 7)
					bytesOffset = bytesOffset + 1

					b2 = peek(curByteAddr())
					if b2 >= 128 then b2 = b2 - 128 end
					b2 = b2 << 1
					b2 = b2 | (peek(curByteAddr()+1) >> 7)
					bytesOffset = bytesOffset + 1

					-- reads byte, shifts right 3, removes bit 4
					b3 = peek(curByteAddr())
					b3 = b3 >> 3
					if b3 >= 16 then b3 = b3 - 16 end
					
					-- reads last 4 bits of byte and removes leftmost bit
					exp = peek(curNibbleAddr(),4)
					if exp >= 8 then exp = exp - 8 end

					-- ORs together all parts of base num
					b1 = b1 << 12
					b2 = b2 << 4
					base = b1 | b2 | b3

					-- calculates the final float value
					float = base*math.pow(10,-exp)*sign

					table.insert(vertex,float)
					
					bytesOffset = bytesOffset + 1
				end

				table.insert(triangle,vertex)
				
			end

			table.insert(mesh,triangle)

		end

		objects[meshName] = mesh

	end

	scene.loadedObjects = objects

end

-- CONVERSION METHODS --

function screenSpaceToViewportSpace(screenX,screenY)
	local xOffset = screenX*(viewport.size.w/screen.size.w)
	local yOffset = (screenY*(viewport.size.h/screen.size.h))
	local position = translate3D(viewport.base,viewport.horizontalVector,xOffset)
	return translate3D(position,viewport.verticalVector,-yOffset)
end

function worldSpaceToViewportSpace(pos)
	local x,y,z = pos.x,pos.y,pos.z
	local xPrime = (x*viewport.focalDist)/z
	local yPrime = (y*viewport.focalDist)/z
	local zPrime = viewport.focalDist
	return Pos3D(xPrime,yPrime,zPrime)
end

function viewportSpaceToScreenSpace(pos)
	local x,y = pos.x,pos.y
	local screenX = (x*screen.size.w)/viewport.size.w
	local screenY = (y*screen.size.h)/viewport.size.h
	return Pos2D(screenX,screenY)
end

function codepoint_to_utf8(codepoint)
    local utf8 = ""
    if codepoint <= 0x7F then
        utf8 = string.char(codepoint)
    elseif codepoint <= 0x7FF then
        utf8 = string.char(
            0xC0 + math.floor(codepoint / 0x40),
            0x80 + (codepoint % 0x40)
        )
    elseif codepoint <= 0xFFFF then
        utf8 = string.char(
            0xE0 + math.floor(codepoint / 0x1000),
            0x80 + (math.floor(codepoint / 0x40) % 0x40),
            0x80 + (codepoint % 0x40)
        )
    elseif codepoint <= 0x10FFFF then
        utf8 = string.char(
            0xF0 + math.floor(codepoint / 0x40000),
            0x80 + (math.floor(codepoint / 0x1000) % 0x40),
            0x80 + (math.floor(codepoint / 0x40) % 0x40),
            0x80 + (codepoint % 0x40)
        )
    else
        error("Code point out of range")
    end
    return utf8
end

-- METHODS --

function printTable(t, indent)
    indent = indent or ""
    for key, value in pairs(t) do
        if type(value) == "table" then
            trace(indent .. tostring(key) .. ": ")
            printTable(value, indent .. "  ")
        elseif type(value) == "function" then
            trace(indent .. tostring(key) .. ": func")
        else
            trace(indent .. tostring(key) .. ": " .. tostring(value))
        end
    end
end

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

	hit=scene.get(sphere):getHitPoint(r)

	color = -1

	if not hit or hit < 0 then
		color=0
	elseif scene.get(sphere).hasCustomRenderRoutine then
		color=scene.get(sphere):renderColor(r,hit)
	elseif hit>=0 or color==-1 then
		-- checker pattern for missing render routine
		color=12+((y%2)+(x%2))%2
	end
	screen.pixels[y][x] = color
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
		loadObjects()
		printTable(scene.activeObjects)
	end

	cls(0)

	if btn(0) then camera.pos=translate3D(camera.pos,camera.rot,0.5) end
	if btn(1) then camera.pos=translate3D(camera.pos,camera.rot,-0.5) end
	if btn(2) then camera.pos=translate3D(camera.pos,viewport.horizontalVector,-0.5) end
	if btn(3) then camera.pos=translate3D(camera.pos,viewport.horizontalVector,0.5) end

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
	circ(170+math.floor(scene.get(sphere).pos.x/2+0.5),20-math.floor(scene.get(sphere).pos.z/2+0.5),scene.get(sphere).r/2,5)
	circ(170+math.floor(camera.pos.x/2+0.5),20-math.floor(camera.pos.z/2+0.5),0.5,8)
		
	t=t+1
end