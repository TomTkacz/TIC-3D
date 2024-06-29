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

-- [TQ-Bundler: class.Pos3D]

Pos3D={}
Pos3D.mt={}
Pos3D.mti={}

function Pos3D.mt.__call(self,x,y,z)
	local s={x=x,y=y,z=z}
	function s:dot(p2)
		return (self.x*p2.x)+(self.y*p2.y)+(self.z*p2.z)
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

	function s:dot(p2)
		return (self.x*p2.x)+(self.y*p2.y)+(self.z*p2.z)
	end

	function s:rotate(x,y,z)
		local m=Matrix.fromVector(self)
		m:applyRotation(x,y,z)
		self.x,self.y,self.z = table.unpack(m[1])
	end

	function s:rotateAboutVector(v,angle)
		local m=Matrix.fromVector(self)
		m:applyAxisAngleRotation(v,angle)
		self.x,self.y,self.z = table.unpack(m[1])
	end

	setmetatable(s,Rot3D.mti)
	return s
end

function Rot3D.mti.__mul(self,v)
	if type(v) == "table" then
		return Rot3D(self.x*v.x,self.y*v.y,self.z*v.z)
	elseif type(v) == "number" then
		return Rot3D(self.x*v,self.y*v,self.z*v)
	else return end
end

function Rot3D.fromMatrix(m)
	if m.rows~=1 or m.cols~=3 then return end
	return Rot3D(m[1][1],m[1][2],m[1][3])
end

setmetatable(Rot3D,Rot3D.mt)

-- [/TQ-Bundler: class.Rot3D]

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
		local rx=Matrix(3,3)
		rx.values={{1,0,0},{0,math.cos(x),-math.sin(x)},{0,math.sin(x),math.cos(x)}}
		local ry=Matrix(3,3)
		ry.values={{math.cos(y),0,math.sin(y)},{0,1,0},{-math.sin(y),0,math.cos(y)}}
		local rz=Matrix(3,3)
		rz.values={{math.cos(z),-math.sin(z),0},{math.sin(z),math.cos(z),0},{0,0,1}}
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
	if type(m)=="number" then
		n=Matrix(self.rows,self.cols)
		for row=1,self.rows do
			for col=1,self.cols do
				n[row][col] = self[row][col]*m
			end
		end
		return n
	elseif type(m)=="table" then
		if self.cols ~= m.rows then return end
		n=Matrix(self.rows,m.cols)
		for nrow=1,self.rows do
			for ncol=1,m.cols do
				total=0
				for col=1,self.cols do
					total=total+(self[nrow][col]*m[col][ncol])
				end
				n[nrow][ncol]=total
			end
		end
		return n
	else return end
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

function Object3D.mt.__call(self,type,...)

    local s={}
    s=Object3D._inits[type](...)
    s.type=type
    s.hasCustomRenderRoutine = Object3D._renderRoutines[type] ~= nil
    
    function s:getHitPoint(ray)
        return Object3D._hitChecks[self.type](self,ray)
    end

    function s:renderColor(ray,hit)
        return Object3D._renderRoutines[self.type](self,ray,hit)
    end

    setmetatable(s,Object3D.mti)
    table.insert(scene.activeObjects,s)
    return #scene.activeObjects

end
setmetatable(Object3D,Object3D.mt)

-- SPHERE --

function Object3D._inits.sphere(pos,radius)
    return {pos=pos,r=radius}
end

function Object3D._hitChecks.sphere(self,ray)
    local r=ray
    local co=r.pos-self.pos
	local a=r.dir:dot(r.dir)
	local b=2*co:dot(r.dir)
	local c=co:dot(co)-(self.r*self.r)
	local disc=(b*b)-4*a*c
	if disc<0 then
		return
	end
	local hit1=(-b+math.sqrt(disc))/(2*a)
	local hit2=(-b-math.sqrt(disc))/(2*a)
	local hit=-1
	if hit2<0 or (hit1>=0 and hit1<hit2) then hit=hit1 end
	if hit1<0 or (hit2>=0 and hit2<hit1) then hit=hit2 end
    return hit
end

function Object3D._renderRoutines.sphere(self,ray,hit)
    local distanceToLight=distBetween3DPoints(translate3D(camera.pos,ray.dir,hit),light.pos)
    if distanceToLight>13 then
        return 1
    end
    return 7.5-math.floor(distanceToLight/2)+1
end

-- MESH --

function Object3D._inits.mesh(triangles,pos,rot)
    return {triangles=triangles,pos=pos,rot=rot}
end

function Object3D._hitChecks.mesh(self)

end

-- [/TQ-Bundler: class.Object3D]

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

					trace("---")
					trace(peek(curNibbleAddr(),4))
					trace(base)
					trace(exp)

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

	if not hit or hit < 0 then
		screen.pixels[y][x]=0
	elseif scene.get(sphere).hasCustomRenderRoutine then
		screen.pixels[y][x]=scene.get(sphere):renderColor(r,hit)
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
		loadObjects()
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
-- <MAP>
-- 000:365726560000000000000000c00008008000008000008008008008008008008008008008008000008008008000008008008000008008008008008008008008008008008000008000008008008000008008008000008000008008008008008000008000008000008008008008008000008000008008008000008000008008008008008008008008008000008008008008008008008008008000008008008000008000008000008000008000008008008008008000008000008008008000008008008008008008008008008008008000008008008000008000008008008000008008008008008000008000008008008000
-- 001:0080000080000080000080080080000080000080000080000080080080000080000080080080080080000080000080080080080080000080080080000080080080080080000080080080000080080080080080000080000080000080000080000080b6e696665600000000000000310000f9ec5647efa1e3e120086963e66920dc6400f9ecb32e68685cea50316f89f2e950166220086989f2e9a1e3e1203d609c4569a1e3e120086989f2e9296cef200869e037e0c8ec6a20086963e66920dc6408f9ec5647efa1e3e108f9ecb32e68685cea28086963e66920dc6400f9ecb32e68685cea20086963e66920dc642008
-- 002:69e037e0c8ec6a0029e041bce869fa64200869e037e0c8ec6a20086989f2e9296cef58316f89f2e95016622808691d88eb5016e1283d609c4569a1e3e128086989f2e9296cef58316f89f2e950166228086989f2e9a1e3e108f9ecb32e68685cea0829e041bce869fa64280869e037e0c8ec6a0829e041bce869fa64088ce08934e7f9f3e428086989f2e9296cef0029e041bce869fa640829e041bce869fa6408f9ecb32e68685cea2008691d88eb5016e12808691d88eb5016e158316f89f2e950166200f9ecb32e68685cea08f9ecb32e68685cea08f9ec5647efa1e3e100f9ec5647efa1e3e108f9ec5647efa1e3
-- 003:e128086989f2e9a1e3e120086989f2e9296cef28086989f2e9296cef088ce08934e7f9f3e4203d609c4569a1e3e1283d609c4569a1e3e12808691d88eb5016e1008ce08934e7f9f3e4088ce08934e7f9f3e40829e041bce869fa6420086989f2e9a1e3e128086989f2e9a1e3e1283d609c4569a1e3e150316f89f2e950166258316f89f2e950166228086989f2e9296cef0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

