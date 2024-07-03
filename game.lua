--
-- Bundle file
-- Code changes will be overwritten
--

-- title: 3D
-- author:  Tom Tkacz, github.com/TomTkacz
-- desc:    3D rendering
-- site:    https://www.thomastkacz.com
-- license: MIT License
-- script:  lua

-- [TQ-Bundler: include.Utils]

function byteToUTF8(codepoint)
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

function round(n,d)
	return math.floor(n*math.pow(10,d))/math.pow(10,d)
end

function printTable(t, indent)
    indent = indent or ""
    for key, value in pairs(t) do
        if type(value) == "table" then
            trace(indent .. tostring(key) .. ": ")
            printTable(value, indent .. "  ")
        elseif type(value) ~= "function" then
            trace(indent .. tostring(key) .. ": " .. tostring(value))
        end
    end
end

function copyTable(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[copyTable(k, s)] = copyTable(v, s) end
    return res
end

function inRads(v)
    return v%(2*math.pi)
end

-- [/TQ-Bundler: include.Utils]

-- [TQ-Bundler: include.LoadObjects]

function loadObjects()
	objects={}

	bytesOffset = 0

	-- get current byte address from byte offset
	local function curByteAddr()
		return MAP_BASE_ADDRESS+bytesOffset
	end

	-- get current nibble address from byte offset
	local function curNibbleAddr()
		return (MAP_BASE_ADDRESS+bytesOffset)*2
	end

	-- get current bit address from byte offset
	local function curBitAddr()
		return (MAP_BASE_ADDRESS+bytesOffset)*8
	end

	while bytesOffset < MAP_SIZE_BYTES do

		meshID = ""

		for i=1,12 do
			if peek(curByteAddr()) ~= 0 then
				meshID = meshID..byteToUTF8(peek(curByteAddr()))
			end
			bytesOffset = bytesOffset + 1
		end

		numberOfTriangles = peek(curByteAddr())
		if numberOfTriangles == 0 then break end

		mesh = {meshID=meshID,numberOfTriangles=numberOfTriangles,triangles={}}

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

			table.insert(mesh.triangles,triangle)

		end

		origin=calculateMeshOrigin(mesh)
		mesh=getMeshRelativeToOrigin(mesh,origin)
		mesh.origin=origin
		objects[meshID] = mesh

	end

	scene.loadedObjects = objects

end


-- [/TQ-Bundler: include.LoadObjects]

-- [TQ-Bundler: class.Pos3D]

Pos3D={}
Pos3D.mt={}
Pos3D.mti={}

function Pos3D.mt.__call(self,x,y,z)
	local s={x=x,y=y,z=z}

	function s:dot(p2)
		return (self.x*p2.x)+(self.y*p2.y)+(self.z*p2.z)
	end

	function s:rotateAboutAxis(dir,angle)
		local m=Matrix.fromVector(self)
		m:applyAxisAngleRotation(dir,angle)
		self.x,self.y,self.z = table.unpack(m[1])
	end

	setmetatable(s,Pos3D.mti)
	return s
end

function Pos3D.fromMatrix(m)
	if m.rows~=1 or m.cols~=3 then return end
	return Pos3D(m[1][1],m[1][2],m[1][3])
end

function Pos3D.mti.__add(self,v)
	if not type(v) == "table" then return end
	return Pos3D(self.x+v.x,self.y+v.y,self.z+v.z)
end

function Pos3D.mti.__sub(self,v)
	if not type(v) == "table" then return end
	return Pos3D(self.x-v.x,self.y-v.y,self.z-v.z)
end

function Pos3D.mti.__mul(self,v)
	if type(v) == "number" then
		return Pos3D(self.x*v,self.y*v,self.z*v)
	elseif type(v) == "table" then
		return Pos3D(self.x*v.x,self.y*v.y,self.z*v.z)
	end
end

setmetatable(Pos3D,Pos3D.mt)

-- [/TQ-Bundler: class.Pos3D]

-- [TQ-Bundler: class.Pos2D]

Pos2D={}
Pos2D.mt={}
Pos2D.mti={}

function Pos2D.mt.__call(self,x,y)
	local s={x=x,y=y}
	setmetatable(s,Pos2D.mti)
	return s
end

setmetatable(Pos2D,Pos2D.mt)

-- [/TQ-Bundler: class.Pos2D]

-- [TQ-Bundler: class.Rot3D]

Rot3D={}
Rot3D.mt={}
Rot3D.mti={}

function Rot3D.mt.__call(self,x,y,z)
	local s={x=x,y=y,z=z}

	function s:rotate(x,y,z)
		self.x=self.x+x
		self.y=self.y+y
		self.z=self.z+z
	end

	function s:rotateAboutAxis(dir,angle)
		local m=Matrix.fromVector(self)
		m:applyAxisAngleRotation(dir,angle)
		self.x,self.y,self.z = table.unpack(m[1])
	end

	setmetatable(s,Rot3D.mti)
	return s
end

function Rot3D.mti.__add(self,v)
	if not type(v) == "table" then return end
	return Rot3D(inRads(self.x+v.x),inRads(self.y+v.y),inRads(self.z+v.z))
end

function Rot3D.mti.__sub(self,v)
	if not type(v) == "table" then return end
	return Rot3D(inRads(self.x-v.x),inRads(self.y-v.y),inRads(self.z-v.z))
end

function Rot3D.mti.__mul(self,v)
	if type(v) == "table" then
		return Rot3D(inRads(self.x*v.x),inRads(self.y*v.y),inRads(self.z*v.z))
	elseif type(v) == "number" then
		return Rot3D(inRads(self.x*v),inRads(self.y*v),inRads(self.z*v))
	else return end
end

function Rot3D.mti.__unm(self)
	return Rot3D(-self.x,-self.y,-self.z)
end

function Rot3D.fromMatrix(m)
	if m.rows~=1 or m.cols~=3 then return end
	return Rot3D(m[1][1],m[1][2],m[1][3])
end

setmetatable(Rot3D,Rot3D.mt)

-- [/TQ-Bundler: class.Rot3D]

-- [TQ-Bundler: class.Dir3D]

Dir3D={}
Dir3D.mt={}
Dir3D.mti={}

function Dir3D.mt.__call(self,x,y,z)
	local s={x=x,y=y,z=z}

	function s:dot(p2)
		return (self.x*p2.x)+(self.y*p2.y)+(self.z*p2.z)
	end

	function s:rotate(x,y,z)
		local m=Matrix.fromVector(self)
		m:applyRotation(x,y,z)
		self.x,self.y,self.z = table.unpack(m[1])
	end

	function s:rotateAboutAxis(dir,angle)
		local m=Matrix.fromVector(self)
		m:applyAxisAngleRotation(dir,angle)
		self.x,self.y,self.z = table.unpack(m[1])
	end

	setmetatable(s,Dir3D.mti)
	return s
end

function Dir3D.mti.__add(self,v)
	if not type(v) == "table" then return end
	return Dir3D(self.x+v.x,self.y+v.y,self.z+v.z)
end

function Dir3D.mti.__sub(self,v)
	if not type(v) == "table" then return end
	return Dir3D(self.x-v.x,self.y-v.y,self.z-v.z)
end

function Dir3D.mti.__mul(self,v)
	if type(v) == "table" then
		return Dir3D(self.x*v.x,self.y*v.y,self.z*v.z)
	elseif type(v) == "number" then
		return Dir3D(self.x*v,self.y*v,self.z*v)
	else return end
end

function Dir3D.mti.__unm(self)
	return Dir3D(-self.x,-self.y,-self.z)
end

function Dir3D.fromMatrix(m)
	if m.rows~=1 or m.cols~=3 then return end
	return Dir3D(m[1][1],m[1][2],m[1][3])
end

setmetatable(Dir3D,Dir3D.mt)

-- [/TQ-Bundler: class.Dir3D]

-- [TQ-Bundler: class.Size2D]

Size2D={}
Size2D.mt={}
Size2D.mti={}

function Size2D.mt.__call(self,w,h)
	local s={w=w,h=h}
	setmetatable(s,Size2D.mti)
	return s
end

setmetatable(Size2D,Size2D.mt)

-- [/TQ-Bundler: class.Size2D]

-- [TQ-Bundler: class.Ray]

Ray={}
Ray.mt={}
Ray.mti={}

function Ray.mt.__call(self,pos,dir)
	local s={pos=pos,dir=dir}
	setmetatable(s,Ray.mti)
	return s
end

function Ray.fromPoints(pos1,pos2)
	return Ray(Pos3D(pos1.x,pos1.y,pos1.z),dirBetween3DPoints(pos1,pos2))
end

setmetatable(Ray,Ray.mt)

-- [/TQ-Bundler: class.Ray]

-- [TQ-Bundler: class.Matrix]

Matrix={}
Matrix.mt={}
Matrix.mti={}

function Matrix.mt.__call(self,rows,cols,fill)
	if fill==nil then fill=0 end
	s={rows=rows,cols=cols,values={}}

	function s:applyRotation(x,y,z)
		local sin = math.sin
		local cos = math.cos
		local rx=Matrix(3,3)
		local sinx,cosx = sin(x),cos(x)
		rx.values={{1,0,0},{0,cosx,-sinx},{0,sinx,cosx}}
		local ry=Matrix(3,3)
		local siny,cosy = sin(y),cos(y)
		ry.values={{cosy,0,siny},{0,1,0},{-siny,0,cosy}}
		local rz=Matrix(3,3)
		local sinz,cosz = sin(z),cos(z)
		rz.values={{cosz,-sinz,0},{sinz,cosz,0},{0,0,1}}
		self.values = (self*(rx*ry*rz)).values
	end

	function s:applyAxisAngleRotation(dir,angle)
		local c=math.cos(angle)
		local s=math.sin(angle)
		local C=1-c
		local x=dir.x
		local y=dir.y
		local z=dir.z
		local Q=Matrix(3,3)
		Q.values={
			{ x*x*C+c, x*y*C-z*s, x*z*C+y*s },
			{ y*x*C+z*s, y*y*C+c, y*z*C-x*s },
			{ z*x*C-y*s, z*y*C+x*s, z*z*C+c },
		}
		self.values = (self*Q).values
	end

	for row=1,rows do
		s.values[row]={}
		for col=1,cols do
			s.values[row][col]=fill
		end
	end
	setmetatable(s,Matrix.mti)
	return s
end

function Matrix.fromVector(v)
	local m=Matrix(1,3)
	m.values={{v.x,v.y,v.z}}
	return m
end

function Matrix.mti.__index(self,i)
	return self.values[i]
end

function Matrix.mti.__add(self,m)
	if self.rows ~= m.rows then return end
	if self.cols ~= m.cols then return end
	n=Matrix(self.rows,self.cols)
	for row=1,self.rows do
		for col=1,self.cols do
			n[row][col] = self[row][col]+m[row][col]
		end
	end
	return n
end

function Matrix.mti.__sub(self,m)
	if self.rows ~= m.rows then return end
	if self.cols ~= m.cols then return end
	n=Matrix(self.rows,self.cols)
	for row=1,self.rows do
		for col=1,self.cols do
			n[row][col] = self[row][col]-m[row][col]
		end
	end
	return n
end

function Matrix.mti.__mul(self,m)
	if type(m)=="table" then
		if self.cols ~= m.rows then return end
		local n=Matrix(self.rows,m.cols)
		for nrow=1,self.rows do
			for ncol=1,m.cols do
				local total=0
				for col=1,self.cols do
					total=total+(self[nrow][col]*m[col][ncol])
				end
				n[nrow][ncol]=total
			end
		end
		return n
	end
	local n=Matrix(self.rows,self.cols)
	for row=1,self.rows do
		for col=1,self.cols do
			n[row][col] = self[row][col]*m
		end
	end
	return n
end

setmetatable(Matrix,Matrix.mt)

-- [/TQ-Bundler: class.Matrix]

-- [TQ-Bundler: class.Object3D]

Object3D={}
Object3D.mt={}
Object3D.mti={}
Object3D._inits={}
Object3D._hitChecks={}
Object3D._renderRoutines={}

---@param type string
function Object3D.mt.__call(self,type,...)

    local s={}
    s=Object3D._inits[type](...)
    s.type=type
    s.hasCustomRenderRoutine = Object3D._renderRoutines[type] ~= nil

    function s:render()
        return Object3D._renderRoutines[self.type](self)
    end

    setmetatable(s,Object3D.mti)
    table.insert(scene.activeObjects,s)
    return #scene.activeObjects

end
setmetatable(Object3D,Object3D.mt)

-- MESH --

function Object3D._inits.mesh(meshID,pos,rot,dir,scale)
    local mesh = scene.loadedObjects[meshID]
    return {
        meshID=mesh.meshID,
        pos=pos,
        rot=rot,
        dir=dir,
        scale=scale,
        origin=mesh.origin,
        numberOfTriangles=mesh.numberOfTriangles
    }
end

function Object3D._renderRoutines.mesh(self)
    local mesh = scene.loadedObjects[self.meshID]
    self.origin = self.pos

    for i,triangle in pairs(mesh.triangles) do
        data={}
        for _,vertex in ipairs(triangle) do
            self.origin = self.pos
            local vertexPos = Pos3D(table.unpack(vertex))

            -- scale mesh
            local vModelScaled = vertexPos*self.scale

            -- translate/rotate mesh about its origin
            local vModelRotated = vModelScaled
            vModelRotated:rotateAboutAxis(Dir3D(1,0,0),self.rot.x)
            vModelRotated:rotateAboutAxis(Dir3D(0,1,0),self.rot.y)
            vModelRotated:rotateAboutAxis(Dir3D(0,0,1),self.rot.z)
            vWorld = vModelRotated+self.origin

            -- translate/rotate mesh about the camera
            local vTranslated = vWorld-camera.pos
            vTranslated:rotateAboutAxis(Dir3D(1,0,0),-camera.rot.x)
            vTranslated:rotateAboutAxis(Dir3D(0,1,0),math.pi-camera.rot.y)
            vTranslated:rotateAboutAxis(Dir3D(0,0,1),-camera.rot.z)

            local screenPos=worldSpaceToScreenSpace(vTranslated)

            table.insert(data,screenPos.x)
            table.insert(data,screenPos.y)
        end
        table.insert(data,(i%11)+1)
        tri(table.unpack(data))
    end
end

-- [/TQ-Bundler: class.Object3D]

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
	self.dir:rotate(self.rot.x,self.rot.y,self.rot.z)
end
camera.dir:rotate(camera.rot.x,camera.rot.y,camera.rot.z)

viewport={
	size=Size2D(SCREEN_WIDTH,SCREEN_HEIGHT),
	focalDist=100,
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

function updateViewportVectors()
	viewport.center = translate3D(camera.pos,camera.rot,viewport.focalDist)
	viewport.horizontalVector = Rot3D(camera.rot.x,camera.rot.y,camera.rot.z)
	viewport.verticalVector = Rot3D(camera.rot.x,camera.rot.y,camera.rot.z)
	viewport.horizontalVector:rotate(0,-math.pi/2,0)
	viewport.verticalVector:rotateAboutAxis(viewport.horizontalVector,math.pi/2)
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

function dirBetween3DPoints(p1,p2)
	local dist = distBetween3DPoints(p1,p2)
	local dx = p2.x-p1.x
	local dy = p2.y-p1.y
	local dz = p2.z-p1.z
	return Dir3D(round(dx/dist,4),round(dy/dist,4),round(dz/dist,4))
end

-- function renderPixel(x,y)
-- 	targetpos=screenSpaceToViewportSpace(x,y)
-- 	r=Ray.fromPoints(camera.pos,targetpos)

-- 	hit=scene.get(sphere):getHitPoint(r)

-- 	color = -1

-- 	if not hit or hit < 0 then
-- 		color=0
-- 	elseif scene.get(sphere).hasCustomRenderRoutine then
-- 		color=scene.get(sphere):renderColor(r,hit)
-- 	elseif hit>=0 or color==-1 then
-- 		-- checker pattern for missing render routine
-- 		color=12+((y%2)+(x%2))%2
-- 	end
-- 	screen.pixels[y][x] = color
-- end

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
		cube=Object3D("mesh","knife",Pos3D(0,0,5),Rot3D(0,0,0),Dir3D(0,0,1),0.5)
		-- Object3D("mesh","cube",Pos3D(1,3,8),Rot3D(0.03,math.pi/8,0.9),Dir3D(0,0,1),1)
		--Object3D("mesh","knife",Pos3D(0,0,10),Rot3D(0,math.pi/8,0),Dir3D(0,0,1),6)
		printTable(scene.loadedObjects.knife)
	end

	cls(0)

	if btn(0) then camera.pos=translate3D(camera.pos,camera.dir,0.1) end --forward
	if btn(1) then camera.pos=translate3D(camera.pos,camera.dir,-0.1) end --backward
	if btn(2) then camera:rotate(0,math.pi/32,0) end--right
	if btn(3) then camera:rotate(0,-math.pi/32,0) end --left

	if gmouse.down then
		physicalSpace = (gmouse.deltaX/SCREEN_WIDTH)*viewport.size.w*(gmouse.sensitivity/100)
		camera:rotate(0,-(2*math.pi)*(physicalSpace/viewport.size.w),0)
	end

	scene.get(cube).rot:rotate(0,math.pi/64,0)

	-- light.pos.x=10*math.sin(t/100)
	-- light.pos.z=10*math.cos(t/100)+15
	-- light.pos.y=3*math.sin(t/180)

	updateViewportVectors()
	renderScreen()
		
	t=t+1
end
-- <MAP>
-- 000:365726560000000000000000c00008008000008000008008008008008008008008008008008000008008008000008008008000008008008008008008008008008008008000008000008008008000008008008000008000008008008008008000008000008000008008008008008000008000008008008000008000008008008008008008008008008000008008008008008008008008008000008008008000008000008000008000008000008008008008008000008000008008008000008008008008008008008008008008008000008008008000008000008008008000008008008008008000008000008008008000
-- 001:0080000080000080000080080080000080000080000080000080080080000080000080080080080080000080000080080080080080000080080080000080080080080080000080080080000080080080080080000080000080000080000080000080b6e696665600000000000000820000f9ec5647efa1e3e120086963e66920dc6400f9ecb32e68685cea50316f89f2e950166220086989f2e9a1e3e1203d609c4569a1e3e1200869e037e0c8ec6a20086963e66920dc6420086989f2e9a1e3e108f9ec5647efa1e3e108f9ecb32e68685cea28086963e66920dc640029e041bce869fa6400f9ecb32e68685cea2008
-- 002:6963e66920dc64008ce08934e7f9f3e40029e041bce869fa64200869e037e0c8ec6a58316f89f2e95016622808691d88eb5016e1283d609c4569a1e3e128086963e66920dc6428086989f2e9a1e3e108f9ec5647efa1e3e128086963e66920dc6408f9ecb32e68685cea0829e041bce869fa64280869e037e0c8ec6a0829e041bce869fa64088ce08934e7f9f3e400f9ecb32e68685cea0029e041bce869fa640829e041bce869fa6450316f89f2e95016622008691d88eb5016e12808691d88eb5016e100f9ec5647efa1e3e100f9ecb32e68685cea08f9ecb32e68685cea20086989f2e9a1e3e100f9ec5647efa1e3
-- 003:e108f9ec5647efa1e3e1008ce08934e7f9f3e420086989f2e9296cef28086989f2e9296cef203d609c4569a1e3e1283d609c4569a1e3e12808691d88eb5016e10029e041bce869fa64008ce08934e7f9f3e4088ce08934e7f9f3e4203d609c4569a1e3e120086989f2e9a1e3e128086989f2e9a1e3e120086989f2e9296cef50316f89f2e950166258316f89f2e950166250316f89f2e9501662203d609c4569a1e3e12008691d88eb5016e1200869e037e0c8ec6a20086989f2e9a1e3e120086989f2e9296cef20086989f2e9296cef20086989f2e9a1e3e150316f89f2e950166220086989f2e9a1e3e120086963e6
-- 004:6920dc6400f9ec5647efa1e3e10029e041bce869fa6420086963e66920dc64200869e037e0c8ec6a008ce08934e7f9f3e4200869e037e0c8ec6a20086989f2e9296cef58316f89f2e9501662283d609c4569a1e3e128086989f2e9a1e3e158316f89f2e950166228086989f2e9a1e3e128086989f2e9296cef28086989f2e9296cef28086989f2e9a1e3e1280869e037e0c8ec6a280869e037e0c8ec6a28086989f2e9a1e3e128086963e66920dc6428086963e66920dc640829e041bce869fa64280869e037e0c8ec6a280869e037e0c8ec6a088ce08934e7f9f3e428086989f2e9296cef00f9ecb32e68685cea0829
-- 005:e041bce869fa6408f9ecb32e68685cea50316f89f2e95016622808691d88eb5016e158316f89f2e950166200f9ec5647efa1e3e108f9ecb32e68685cea08f9ec5647efa1e3e120086989f2e9a1e3e108f9ec5647efa1e3e128086989f2e9a1e3e1008ce08934e7f9f3e428086989f2e9296cef088ce08934e7f9f3e4203d609c4569a1e3e12808691d88eb5016e12008691d88eb5016e10029e041bce869fa64088ce08934e7f9f3e40829e041bce869fa64203d609c4569a1e3e128086989f2e9a1e3e1283d609c4569a1e3e120086989f2e9296cef58316f89f2e950166228086989f2e9296cef0000000000000000
-- </MAP>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <PALETTE>
-- 000:1a1c2c001c00002c00003c04004c0000590000690000790029366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

