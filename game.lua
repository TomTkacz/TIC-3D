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
		--Object3D("mesh","cube",Pos3D(1,3,8),Rot3D(0.03,math.pi/8,0.9),Dir3D(0,0,1),1)
		--Object3D("mesh","cube",Pos3D(0,0,10),Rot3D(0,math.pi/8,0),Dir3D(0,0,1),2)
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
-- 001:0080000080000080000080080080000080000080000080000080080080000080000080080080080080000080000080080080080080000080080080000080080080080080000080080080000080080080080080000080000080000080000080000080b6e696665600000000000000820000f0dfa052d420f95d0060c65017d70074db00f0df50df5108da5600d04028b6d20098db0060c628b6d220f95d00845578555420f95d0060c61017de18745e0060c65017d70074db0060c628b6d220f95d08f0dfa052d420f95d08f0df50df5108da560860c65017d70074db00e0592041d52844db00f0df50df5108da560060
-- 002:c65017d70074db00204028d6d238f15f00e0592041d52844db0060c61017de18745e08d04028b6d20098db0860c68872d40098db08845578555420f95d0860c65017d70074db0860c628b6d220f95d08f0dfa052d420f95d0860c65017d70074db08f0df50df5108da5608e0592041d52844db0860c61017de18745e08e0592041d52844db08204028d6d238f15f00f0df50df5108da5600e0592041d52844db08e0592041d52844db00d04028b6d20098db0060c68872d40098db0860c68872d40098db00f0dfa052d420f95d00f0df50df5108da5608f0df50df5108da560060c628b6d220f95d00f0dfa052d420f9
-- 003:5d08f0dfa052d420f95d00204028d6d238f15f0060c628b6d2180e5b0860c628b6d2180e5b00845578555420f95d08845578555420f95d0860c68872d40098db00e0592041d52844db00204028d6d238f15f08204028d6d238f15f00845578555420f95d0060c628b6d220f95d0860c628b6d220f95d0060c628b6d2180e5b00d04028b6d20098db08d04028b6d20098db00d04028b6d20098db00845578555420f95d0060c68872d40098db0060c61017de18745e0060c628b6d220f95d0060c628b6d2180e5b0060c628b6d2180e5b0060c628b6d220f95d00d04028b6d20098db0060c628b6d220f95d0060c65017
-- 004:d70074db00f0dfa052d420f95d00e0592041d52844db0060c65017d70074db0060c61017de18745e00204028d6d238f15f0060c61017de18745e0060c628b6d2180e5b08d04028b6d20098db08845578555420f95d0860c628b6d220f95d08d04028b6d20098db0860c628b6d220f95d0860c628b6d2180e5b0860c628b6d2180e5b0860c628b6d220f95d0860c61017de18745e0860c61017de18745e0860c628b6d220f95d0860c65017d70074db0860c65017d70074db08e0592041d52844db0860c61017de18745e0860c61017de18745e08204028d6d238f15f0860c628b6d2180e5b00f0df50df5108da5608e0
-- 005:592041d52844db08f0df50df5108da5600d04028b6d20098db0860c68872d40098db08d04028b6d20098db00f0dfa052d420f95d08f0df50df5108da5608f0dfa052d420f95d0060c628b6d220f95d08f0dfa052d420f95d0860c628b6d220f95d00204028d6d238f15f0860c628b6d2180e5b08204028d6d238f15f00845578555420f95d0860c68872d40098db0060c68872d40098db00e0592041d52844db08204028d6d238f15f08e0592041d52844db00845578555420f95d0860c628b6d220f95d08845578555420f95d0060c628b6d2180e5b08d04028b6d20098db0860c628b6d2180e5bd6162796f6000000
-- 006:000000009f000000000041970080a9e839c3749bc2499f49d932cf14284cc8b5cfa1d5c343484d1741dc717eca6418c92953485167c26445425136c9e839c3749bc2499f49e87bc7237a4b39074cd932cf14284cc8b5cfc1a842b3a5c88f7fd1c0d94e23e84049be49717eca6418c9295348a1d5c343484d1741dc0000307360c020e6be99bc49330e4e37ae5e5167c26445425136c90000307360c020e6bea1d5c343484d1741dc0000000041970080a9d932cf14284cc8b5cf498f4a54cf456140cc5167c26445425136c90000000041970080a9498f4a54cf456140cc5167c26445425136c9717eca6418c9295348
-- 007:0000000041970080a999bc49330e4e37ae5e0000307360c020e6be498f4a54cf456140cc99bc49330e4e37ae5e498f4a54cf456140ccd932cf14284cc8b5cf0000000041970080a9717eca6418c9295348e839c3749bc2499f49a1d5c343484d1741dcc1a842b3a5c88f7fd1717eca6418c92953480000307360c020e6be5167c26445425136c9498f4a54cf456140cc99bc49330e4e37ae5ed932cf14284cc8b5cfe87bc7237a4b39074cc1a842b3a5c88f7fd1a1d5c343484d1741dcc0d94e23e84049be49c0d94e23e84049be49a1d5c343484d1741dc99bc49330e4e37ae5e99bc49330e4e37ae5ee87bc7237a4b
-- 008:39074cc0d94e23e84049be49717eca6418c9295348c0d94e23e84049be49e839c3749bc2499f49c0d94e23e84049be49e87bc7237a4b39074ce839c3749bc2499f49107b5904fa40a123c9b0dbcf35c5c3b139c1189cbd75874181ce42107b5904fa40a123c9189cbd75874181ce42993348a420c331594ba19c4b740149113140b0dbcf35c5c3b139c1107b5904fa40a123c9b0dbcf35c5c3b139c120733fa517cf21ebc8d0514fb6e44162acd8f84e4a6555c969e2c409edc51438ce1889b2289dbc64494a08e2bcf84e4a6555c969e2c4f0f147046fc0090ec809edc51438ce1889b2914347b4504e0892a2f84e4a
-- 009:6555c969e2c4717bce46974b4eda5bf84e4a6555c969e2c4914347b4504e0892a2f0f147046fc0090ec8f0f147046fc0090ec8914347b4504e0892a2a19c4b740149113140993348a420c331594b289dbc64494a08e2bc106151535c4600b2af09edc51438ce1889b2106151535c4600b2af289dbc64494a08e2bc106151535c4600b2af107b5904fa40a123c9993348a420c331594b106151535c4600b2af09edc51438ce1889b2f0f147046fc0090ec8a19c4b740149113140106151535c4600b2aff0f147046fc0090ec8a19c4b740149113140107b5904fa40a123c9106151535c4600b2afc8dec0b67c4a91c059
-- 010:106854b6db4b0f1bd87977ca4657c04e9356f84e4a6555c969e2c47977ca4657c04e9356106854b6db4b0f1bd8717bce46974b4eda5b106854b6db4b0f1bd8d0514fb6e44162acd8106854b6db4b0f1bd8717bce46974b4eda5bf84e4a6555c969e2c4b0dbcf35c5c3b139c1a19c4b74014911314020733fa517cf21ebc800f9cbb3824451c8dff0824ef38e42a015ca049bdfd3114df8fa46049bdfd3114df8fa46f0824ef38e42a015ca20b5b9d331c509824620b5b9d331c5098246f0824ef38e42a015cad15d4200f0135136de91b842e1fb4aadd45495cfd5a1bcc50ad5dd0020900080990892a600309e00000d
-- 011:0061aa95cfd5a1bcc50ad5dd91b842e1fb4aadd454d15d4200f0135136def0824ef38e42a015ca00309e00000d0061aa20b5b9d331c5098246d15d4200f0135136de91b842e1fb4aadd454049bdfd3114df8fa4620b5b9d331c50982460020900080990892a600f9cbb3824451c8df049bdfd3114df8fa460020900080990892a6f0824ef38e42a015ca00f9cbb3824451c8df00309e00000d0061aa00f9cbb3824451c8df95cfd5a1bcc50ad5dd00309e00000d0061aa0020900080990892a695cfd5a1bcc50ad5dd00f9cbb3824451c8df20b5b9d331c509824691b842e1fb4aadd4540020900080990892a600309e
-- 012:00000d0061aa91b842e1fb4aadd454d15d4200f0135136de4117c632f24ff310d6f089cf27e4d445945000000c0000069072dcf0b64f125bcc190cc200000c0000069072dcf0eb42c0a8c019684ef0b64f125bcc190cc2f0eb42c0a8c019684e0000970042ab0020a54117c632f24ff310d60000970042ab0020a5f089cf27e4d44594504117c632f24ff310d655a8d2522f4a8914580000970042ab0020a50000970042ab0020a555a8d2522f4a891458f0b64f125bcc190cc2f0b64f125bcc190cc24117c632f24ff310d600000c0000069072dcf0b64f125bcc190cc255a8d2522f4a8914584117c632f24ff310d6
-- 013:f0eb42c0a8c019684ef089cf27e4d44594500000970042ab0020a500000c0000069072dcf089cf27e4d4459450f0eb42c0a8c019684e08008600000d0051a198c1ddb3d14e20d7cff8a640f3fac2964bde0820900065ab084093db97d8d3b5c9f8a9c698c1ddb3d14e20d7cf0820900065ab08409379b543d37942095642db97d8d3b5c9f8a9c699cb4ce1ddcffdfcd8d9bc40b3074ff0dfde79b543d3794209564208008600000d0051a1f8a640f3fac2964bded9bc40b3074ff0dfde99cb4ce1ddcffdfcd8dd18dfa13c462a865908008600000d0051a10820900065ab084093dd18dfa13c462a865999cb4ce1ddcf
-- 014:fdfcd8d9bc40b3074ff0dfdef8a640f3fac2964bde79b543d3794209564279b543d37942095642f8a640f3fac2964bdedb97d8d3b5c9f8a9c6db97d8d3b5c9f8a9c6f8a640f3fac2964bde98c1ddb3d14e20d7cfd9bc40b3074ff0dfde99cb4ce1ddcffdfcd808008600000d0051a10820900065ab08409399cb4ce1ddcffdfcd879b543d3794209564298c1ddb3d14e20d7cfdd18dfa13c462a86590820900065ab08409308008600000d0051a1dd18dfa13c462a865998c1ddb3d14e20d7cfa9e04ce090cbc302de0800010042ab9072dc0800860055a20000830800010042ab9072dcf8eb414691d61859338c31d3
-- 015:300bb91d36d1f8eb414691d6185933a9e04ce090cbc302de990fc122c2c24ff25a0800860055a20000838c31d3300bb91d36d1990fc122c2c24ff25aa9e04ce090cbc302def8eb414691d61859330800010042ab9072dc0800860055a2000083990fc122c2c24ff25aa9e04ce090cbc302de990fc122c2c24ff25a8c31d3300bb91d36d1f8eb414691d61859330800010042ab9072dc8c31d3300bb91d36d10800860055a2000083189cbd75874181ce42b0dbcf35c5c3b139c1d0514fb6e44162acd8189cbd75874181ce42d0514fb6e44162acd8c8dec0b67c4a91c059289dbc64494a08e2bc993348a420c331594b
-- 016:7977ca4657c04e9356289dbc64494a08e2bc7977ca4657c04e9356f84e4a6555c969e2c4a19c4b740149113140914347b4504e0892a2717bce46974b4eda5bc8dec0b67c4a91c059d0514fb6e44162acd8106854b6db4b0f1bd820733fa517cf21ebc8717bce46974b4eda5bd0514fb6e44162acd8a19c4b740149113140717bce46974b4eda5b20733fa517cf21ebc8c8dec0b67c4a91c0597977ca4657c04e9356189cbd75874181ce427977ca4657c04e9356993348a420c331594b189cbd75874181ce42614547a657c16850cdd263c0465ccb40cb44d28ac226ba4e4d9f5361754f8581c9ea7758c2e4ce95deca
-- 017:307250d263c0465ccb40cb4461754f8581c9ea7758d28ac226ba4e4d9f53c2e4ce95deca307250717d451699c17542dd61754f8581c9ea7758d263c0465ccb40cb44614547a657c16850cd717d451699c17542ddd263c0465ccb40cb4461754f8581c9ea7758614547a657c16850cdd28ac226ba4e4d9f53d28ac226ba4e4d9f53d263c0465ccb40cb44c2e4ce95deca30725061754f8581c9ea7758717d451699c17542dd614547a657c16850cd72484296d0499a48ded372cb56acc9fa94d0b39644b5e2c90b945872484296d0499a48dea3dec2565142c35bdcd372cb56acc9fa94d0727746a506cf1a395bb39644
-- 018:b5e2c90b9458a3dec2565142c35bdcb39644b5e2c90b9458d372cb56acc9fa94d0a3dec2565142c35bdc8234c1164f437419d7727746a506cf1a395ba3dec2565142c35bdc72484296d0499a48de8234c1164f437419d7a3dec2565142c35bdc727746a506cf1a395b72484296d0499a48deb39644b5e2c90b94588234c1164f437419d772484296d0499a48de727746a506cf1a395bbad54c1681c87006c8696cc675b54b91b5536930c676eec4233550daf6cea536493a60d269c7ca9048beb8a1ce696cc675b54b91b553dad34b76994128ebc56930c676eec423355069c7ca9048beb8a1cedaf6cea536493a60d2
-- 019:dad34b76994128ebc569c7ca9048beb8a1cebad54c1681c87006c8daf6cea536493a60d2696cc675b54b91b553dad34b76994128ebc5bad54c1681c87006c86930c676eec4233550696cc675b54b91b55369c7ca9048beb8a1ce6930c676eec4233550dad34b76994128ebc5daf6cea536493a60d2bad54c1681c87006c8bb354946b9c3d33f599a874585f7c671f5587a99c666f645b2d1d3bbc9c6958bcf6a14d28ad1cff59ac79d00dd9a874585f7c671f5586842b946884d1b0fde7a99c666f645b2d1d38ad1cff59ac79d00ddbb354946b9c3d33f596842b946884d1b0fdebbc9c6958bcf6a14d26842b946884d
-- 020:1b0fdebb354946b9c3d33f597a99c666f645b2d1d3bbc9c6958bcf6a14d26842b946884d1b0fde8ad1cff59ac79d00ddbb354946b9c3d33f59bbc9c6958bcf6a14d29a874585f7c671f5587a99c666f645b2d1d39a874585f7c671f5588ad1cff59ac79d00ddc1fac41808d3817ec06006d061f25f612649533bdf08f0d118cb3da182c52896df2994cdc1fac41808d3817ec0533bdf08f0d118cb3d00000ce06bc357fad7c1fac41808d3817ec0a182c52896df2994cd6006d061f25f612649f02eca016ec24987ce533bdf08f0d118cb3df02eca016ec24987ce00000ce06bc357fad7a182c52896df2994cd01e14a
-- 021:20c0ba1137c96006d061f25f612649c1fac41808d3817ec000000ce06bc357fad701e14a20c0ba1137c9c1fac41808d3817ec0f02eca016ec24987cea182c52896df2994cd533bdf08f0d118cb3df02eca016ec24987ce6006d061f25f61264901e14a20c0ba1137c901e14a20c0ba1137c900000ce06bc357fad7f02eca016ec24987ce09e7c811334849954c08b4ace06bc357fad70911c74116cf11d04d0911c74116cf11d04d88d1d9e0d3de517ec109e7c811334849954ceb985310dcd7199aceb9224f103bde29f5cd09e7c811334849954cc968476872552028300911c74116cf11d04d08b4ace06bc357fad7
-- 022:c9684768725520283088d1d9e0d3de517ec10911c74116cf11d04db9224f103bde29f5cd08b4ace06bc357fad709e7c811334849954ceb985310dcd7199ace09e7c811334849954c88d1d9e0d3de517ec1b9224f103bde29f5cdc9684768725520283008b4ace06bc357fad7eb985310dcd7199acec96847687255202830b9224f103bde29f5cdeb985310dcd7199ace88d1d9e0d3de517ec1c968476872552028302a1bcbd03cb26d5a5748b43ff015b25d5d51598a49c0a83e19514a48b43ff015b25d5d511911cee015b88a4d4f08a222c0183c4af147598a49c0a83e19514a48b43ff015b25d5d5108a222c0183c
-- 023:4af14708a222c0183c4af1471911cee015b88a4d4f11f742e063bd9a244908a222c0183c4af14711f742e063bd9a244901fe47c0183d2a4fc101fe47c0183d2a4fc111f742e063bd9a2449b2e4ce10782f5d02de518f44c0b8b61911c101fe47c0183d2a4fc1b2e4ce10782f5d02de518f44c0b8b61911c1b2e4ce10782f5d02de3244c4d0ebb56d7a502905caf0baba9171c548b43ff015b25d5d512a1bcbd03cb26d5a57cd065b0141bdc239cb10265e109a2ef154432905caf0baba9171c52905caf0baba9171c50e84d3213c3fa1124c48b43ff015b25d5d511911cee015b88a4d4f48b43ff015b25d5d5110e655
-- 024:3123bc40b3d610e6553123bc40b3d648b43ff015b25d5d510e84d3213c3fa1124cb2e4ce10782f5d02de2141cef04cb891b84f3244c4d0ebb56d7a50b2e4ce10782f5d02de00509700408a00409d2141cef04cb891b84f00509700408a00409db2e4ce10782f5d02de10e6553123bc40b3d610e6553123bc40b3d6b2e4ce10782f5d02de11f742e063bd9a24491911cee015b88a4d4f10e6553123bc40b3d611f742e063bd9a244910265e109a2ef15443cd065b0141bdc239cb2141cef04cb891b84f2905caf0baba9171c52141cef04cb891b84fcd065b0141bdc239cb10e6553123bc40b3d60e84d3213c3fa1124c
-- 025:00509700408a00409d10265e109a2ef154432141cef04cb891b84f00509700408a00409d00509700408a00409d0e84d3213c3fa1124c10265e109a2ef154430e84d3213c3fa1124c2905caf0baba9171c510265e109a2ef15443bd7e5cd015b6f14a492429d8d04cbdf11cc22905caf0baba9171c5899ec7d0c5bb912fc0bd7e5cd015b6f14a492905caf0baba9171c52905caf0baba9171c52429d8d04cbdf11cc22141cef04cb891b84f2429d8d04cbdf11cc291c2ccd0c5be916fcc2141cef04cb891b84f2a1bcbd03cb26d5a57899ec7d0c5bb912fc02905caf0baba9171c5899ec7d0c5bb912fc02a1bcbd03cb2
-- 026:6d5a572ab1cd772ec9ea265822964f772ec9ea26593244c4d0ebb56d7a5091c2ccd0c5be916fcc2141cef04cb891b84f91c2ccd0c5be916fcc3244c4d0ebb56d7a5091c2ccd0c5be916fcc2429d8d04cbdf11cc2514fc307674b912c4a2429d8d04cbdf11cc28628dd778e402256c9514fc307674b912c4a381753374cc422f148514fc307674b912c4a8628dd778e402256c9514fc307674b912c4a22964f772ec9ea265991c2ccd0c5be916fcced44db666ece2106cbc876cf8782c0221dc32ab1cd772ec9ea2658381753374cc422f148c876cf8782c0221dc3ed44db666ece2106cbc876cf8782c0221dc3bd7e5c
-- 027:d015b6f14a49899ec7d0c5bb912fc0899ec7d0c5bb912fc02ab1cd772ec9ea2658c876cf8782c0221dc3ed44db666ece2106cb514fc307674b912c4a381753374cc422f14808309910a1a00800860042ab10a1a0080086ed44db666ece2106cb0042ab10a1a0080086514fc307674b912c4aed44db666ece2106cb514fc307674b912c4a0042ab10a1a008008622964f772ec9ea26592ab1cd772ec9ea265808309910a1a0080086ed44db666ece2106cb22964f772ec9ea2659518f44c0b8b61911c13244c4d0ebb56d7a502ab1cd772ec9ea26582a1bcbd03cb26d5a57598a49c0a83e19514a0042ab10a1a0080086
-- 028:518f44c0b8b61911c122964f772ec9ea26592ab1cd772ec9ea2658598a49c0a83e19514a08309910a1a0080086381753374cc422f1488628dd778e402256c9cbf8d1477bcb53614348fcd6d0dfb5438e4de0b94510c52ad27bc52429d8d04cbdf11cc2bd7e5cd015b6f14a49e869c9d0893bf278c32429d8d04cbdf11cc22429d8d04cbdf11cc2e869c9d0893bf278c348fcd6d0dfb5438e4de0b94510c52ad27bc548fcd6d0dfb5438e4dd0674f1083ab2313c1d0674f1083ab2313c18628dd778e402256c9e0b94510c52ad27bc58628dd778e402256c9d0674f1083ab2313c1cbf8d1477bcb536143e0b94510c52a
-- 029:d27bc58628dd778e402256c92429d8d04cbdf11cc2cbf8d1477bcb536143d0674f1083ab2313c148fcd6d0dfb5438e4d08309910a1a00800860000001042af08008a0042ab10a1a0080086c876cf8782c0221dc3cbf8d1477bcb536143e869c9d0893bf278c3cbf8d1477bcb536143c876cf8782c0221dc3381753374cc422f148c876cf8782c0221dc3e869c9d0893bf278c3bd7e5cd015b6f14a49e869c9d0893bf278c3cbf8d1477bcb53614348fcd6d0dfb5438e4d0000001042af08008a187cb8470a4c6a00c308a222c0183c4af147719bcee664cbd99dca21624f471a465aff4901fe47c0183d2a4fc1518f44
-- 030:c0b8b61911c1719bcee664cbd99dca01fe47c0183d2a4fc10000001042af08008a08a222c0183c4af14701fe47c0183d2a4fc10000001042af08008a01fe47c0183d2a4fc121624f471a465aff49719bcee664cbd99dca518f44c0b8b61911c10042ab10a1a008008608a222c0183c4af147796648e6344ed9cdc5598a49c0a83e19514a187cb8470a4c6a00c3796648e6344ed9cdc508a222c0183c4af14708309910a1a0080086598a49c0a83e19514a796648e6344ed9cdc50000001042af08008a08309910a1a0080086796648e6344ed9cdc50000001042af08008a21624f471a465aff49719bcee664cbd99dca
-- 031:719bcee664cbd99dca0042ab10a1a00800860000001042af08008a796648e6344ed9cdc5187cb8470a4c6a00c30000001042af08008a0cfac746f1ccc06ec68b4549009fa3f82ede1cc3c4a0fc3ee8a9531cc3c4a0fc3ee8a9538b4549009fa3f82ede0c5fc64610c809a0c40c5fc64610c809a0c48b4549009fa3f82edefbad4b852b424e61dcfbad4b852b424e61dc8b4549009fa3f82edefb794a8531419491dbfb794a8531419491db8b4549009fa3f82ede0cfac746f1ccc06ec60c5fc64610c809a0c44d524cd571c22841b31cc3c4a0fc3ee8a9531cc3c4a0fc3ee8a953bd53c186adcda02c4c0cfac746f1cc
-- 032:c06ec60cfac746f1ccc06ec6bd53c186adcda02c4cfcf243d43246d010c04d524cd571c22841b3ddb1cb655ecea27bdfbd53c186adcda02c4cddb1cb655ecea27bdf4d524cd571c22841b3fcf243d43246d010c04d524cd571c22841b3fbad4b852b424e61dcfcf243d43246d010c0bd53c186adcda02c4cddb1cb655ecea27bdffcf243d43246d010c04d524cd571c22841b3bd53c186adcda02c4c1cc3c4a0fc3ee8a9530cfac746f1ccc06ec6fcf243d43246d010c0fb794a8531419491dbfcf243d43246d010c0fbad4b852b424e61dcfb794a8531419491db4d524cd571c22841b30c5fc64610c809a0c4fbad4b
-- 033:852b424e61dc147649c64eca5857d0b519cfa6394be64cdd803739f5a0c8496c4405dd4be4774fc0ef4fd58fca85a4cea21d52b519cfa6394be64cdd05dd4be4774fc0ef4f049d43804fb80e44d9803739f5a0c8496c44803739f5a0c8496c44d58fca85a4cea21d5205dd4be4774fc0ef4fb519cfa6394be64cddd58fca85a4cea21d52803739f5a0c8496c4405dd4be4774fc0ef4fb519cfa6394be64cdd1407cb4656c1d00a401407cb4656c1d00a40b519cfa6394be64cdd147649c64eca5857d0147649c64eca5857d0803739f5a0c8496c4404afc946bec6f8f44d1407cb4656c1d00a40837ac5002008089c4d
-- 034:04cac685a8c0b45950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

