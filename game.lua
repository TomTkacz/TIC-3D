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

function getVectorPlaneIntersection(pos,dir,plane)
    if plane.normal:dot(dir) == 0 then return end
    local t = ( plane.normal:dot(plane.origin) - plane.normal:dot(pos) ) / plane.normal:dot(dir)
    return pos + ( dir * t )
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

			triangle={vertices={}}

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

				table.insert(triangle.vertices,Pos3D(table.unpack(vertex)))
				
			end

			triangle.center = getTriangleCircumcenter(triangle.vertices[1],triangle.vertices[2],triangle.vertices[3])

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

-- [TQ-Bundler: class.Camera]

Camera={}
Camera.mt={}
Camera.mti={}

function Camera.mt.__call(self,pos,rot,dir)

    local s={
        pos=pos,
        rot=rot,
        dir=dir,
    }

    function s:rotate(r)
        self.rot=self.rot+r
        self.dir:rotate(r.x,r.y,r.z)
    end

    function s:updateClippingPlanes()

        self.clippingPlanes = {}

        self.clippingPlanes.near = {
            origin=self.pos,
            normal=self.dir:copy(),
        }

        self.clippingPlanes.left = {
            origin=self.pos,
            normal=self.dir:copy(),
        }
        self.clippingPlanes.left.normal:rotateAboutAxis(self.verticalVector,-(viewport.fov/2)+(math.pi/2))

        self.clippingPlanes.right = {
            origin=self.pos,
            normal=self.dir:copy(),
        }
        self.clippingPlanes.right.normal:rotateAboutAxis(self.verticalVector,(viewport.fov/2)-(math.pi/2))

        self.clippingPlanes.top = {
            origin=self.pos,
            normal=self.dir:copy(),
        }
        self.clippingPlanes.top.normal:rotateAboutAxis(self.horizontalVector,(viewport._vfov/2)-(math.pi/2))

        self.clippingPlanes.bottom = {
            origin=self.pos,
            normal=self.dir:copy(),
        }
        self.clippingPlanes.bottom.normal:rotateAboutAxis(self.horizontalVector,-(viewport._vfov/2)+(math.pi/2))

    end

    function s:updateVectors()
        local horizontalVector,verticalVector = self.dir:copy(),self.dir:copy()
        horizontalVector:rotate(0,-math.pi/2,0) -- points right (will need to fixed if cam points up or down)
        verticalVector:rotateAboutAxis(horizontalVector,math.pi/2) -- points up
        self.horizontalVector,self.verticalVector = horizontalVector,verticalVector
    end

    function s:isPointInView(p,r)
        if r==nil then r=0 end
        local cameraPos = self.pos
        local clippingPlanes = self.clippingPlanes
        local isInView = true
        local planesClipped = {}
        local errorMargin = 0.005

        local planeDistFromOrigin = -( clippingPlanes.near.normal:dot(cameraPos) )
        local signedDistanceToPlane = clippingPlanes.near.normal:dot(p) + planeDistFromOrigin
        isInView = isInView and signedDistanceToPlane >= -r - errorMargin
        if signedDistanceToPlane < -r - errorMargin then table.insert(planesClipped,"near") end

        local planeDistFromOrigin = -( clippingPlanes.left.normal:dot(cameraPos) )
        local signedDistanceToPlane = clippingPlanes.left.normal:dot(p) + planeDistFromOrigin
        isInView = isInView and signedDistanceToPlane >= -r - errorMargin
        if signedDistanceToPlane < -r - errorMargin then table.insert(planesClipped,"left") end

        local planeDistFromOrigin = -( clippingPlanes.right.normal:dot(cameraPos) )
        local signedDistanceToPlane = clippingPlanes.right.normal:dot(p) + planeDistFromOrigin
        isInView = isInView and signedDistanceToPlane >= -r - errorMargin
        if signedDistanceToPlane < -r - errorMargin then table.insert(planesClipped,"right") end

        local planeDistFromOrigin = -( clippingPlanes.top.normal:dot(cameraPos) )
        local signedDistanceToPlane = clippingPlanes.top.normal:dot(p) + planeDistFromOrigin
        isInView = isInView and signedDistanceToPlane >= -r - errorMargin
        if signedDistanceToPlane < -r - errorMargin then table.insert(planesClipped,"top") end

        local planeDistFromOrigin = -( clippingPlanes.bottom.normal:dot(cameraPos) )
        local signedDistanceToPlane = clippingPlanes.bottom.normal:dot(p) + planeDistFromOrigin
        isInView = isInView and signedDistanceToPlane >= -r - errorMargin
        if signedDistanceToPlane < -r - errorMargin then table.insert(planesClipped,"bottom") end

        return isInView,planesClipped
    end

    setmetatable(s,Camera.mti)

    s:rotate(s.rot)

    return s

end

setmetatable(Camera,Camera.mt)

-- [/TQ-Bundler: class.Camera]

-- [TQ-Bundler: class.Pos3D]

Pos3D={}
Pos3D.mt={}
Pos3D.mti={}

function Pos3D.mt.__call(self,x,y,z,w)
	local s={x=x,y=y,z=z,w=1}
	if w~=nil then s.w=w end
	s.matrix=Matrix(4,1)
	s.matrix.values={{s.x},{s.y},{s.z},{s.w}}

	function s:updateMatrix()
		self.matrix.values={{self.x},{self.y},{self.z},{self.w}}
	end

	function s:copy()
		return Pos3D(self.x,self.y,self.z,self.w)
	end

	function s:dot(p2)
		return (self.x*p2.x)+(self.y*p2.y)+(self.z*p2.z)+(self.w*p2.w)
	end

	function s:scale(sx,sy,sz)
		local m=self.matrix
		m:applyScaleFactor(sx,sy,sz)
		self.x,self.y,self.z,self.w = m[1][1],m[2][1],m[3][1],m[4][1]
		self:updateMatrix()
	end

	function s:translate(tx,ty,tz)
		local m=self.matrix
		m:applyTranslation(tx,ty,tz)
		self.x,self.y,self.z,self.w = m[1][1],m[2][1],m[3][1],m[4][1]
		self:updateMatrix()
	end

	function s:rotateAboutAxis(dir,angle)
		local m=self.matrix
		m:applyAxisAngleRotation(dir,angle)
		self.x,self.y,self.z,self.w = m[1][1],m[2][1],m[3][1],m[4][1]
		self:updateMatrix()
	end

	function s:cross(v)
		local x = ( self.y * v.z ) - ( v.y * self.z )
		local y = ( self.z * v.x ) - ( v.z * self.x )
		local z = ( self.x * v.y ) - ( v.x * self.y )
		return Pos3D(x,y,z,self.w)
	end

	function s:toLocalTransform(origin,rot,scale)

		local vertexPos = self:copy()

		-- scale
		vertexPos:scale(scale,scale,scale)

		-- translate/rotate about the origin
		vertexPos:rotateAboutAxis(Dir3D(1,0,0),rot.x)
		vertexPos:rotateAboutAxis(Dir3D(0,1,0),rot.y)
		vertexPos:rotateAboutAxis(Dir3D(0,0,1),rot.z)
		vertexPos:translate(origin.x,origin.y,origin.z)

		return vertexPos

	end
	
	function s:magnitude()
		if s.w == 0 then
			return math.sqrt(self:dot(self))
		end
		return math.sqrt(math.abs(self:dot(self)-1))
	end

	function s:toCameraTransform()

		local vertexPos = self:copy()

		-- translate/rotate about the camera
		vertexPos:translate(-camera.pos.x,-camera.pos.y,-camera.pos.z)
		vertexPos:rotateAboutAxis(Dir3D(1,0,0),-camera.rot.x)
		vertexPos:rotateAboutAxis(Dir3D(0,1,0),math.pi-camera.rot.y)
		vertexPos:rotateAboutAxis(Dir3D(0,0,1),-camera.rot.z)

		return vertexPos

	end

	function s:canonical()
		local div = 1
		if self.w ~= 0 then div=self.w end
		return Pos3D(self.x/div,self.y/div,self.z/div,1)
	end

	setmetatable(s,Pos3D.mti)
	return s
end

function Pos3D.fromMatrix(m)
	if m.rows>4 or m.cols>4 then return end
	return Pos3D(m[1][1],m[1][2],m[1][3],m[1][4])
end

function Pos3D.mti.__add(self,v)
	if not type(v) == "table" then return end
	return Pos3D(self.x+v.x,self.y+v.y,self.z+v.z,self.w+v.w)
end

function Pos3D.mti.__sub(self,v)
	if not type(v) == "table" then return end
	return Pos3D(self.x-v.x,self.y-v.y,self.z-v.z,self.w-v.w)
end

function Pos3D.mti.__mul(self,v)
	if type(v) == "number" then
		return Pos3D(self.x*v,self.y*v,self.z*v,self.w*v)
	elseif type(v) == "table" then
		return Pos3D(self.x*v.x,self.y*v.y,self.z*v.z,self.w*v.w)
	end
end

function Pos3D.mti.__div(self,v)
	if type(v) == "number" then
		return Pos3D(self.x/v,self.y/v,self.z/v,self.w/v)
	elseif type(v) == "table" then
		return Pos3D(self.x/v.x,self.y/v.y,self.z/v.z,self.w/v.w)
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

function Pos2D.fromMatrix(m)
	local rows = #m
	local p = Pos2D(m[1][1],m[2][1])
	if rows > 2 then
		p.x = p.x/m[3][1]
		p.y = p.y/m[3][1]
	end
	return p
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

function Dir3D.mt.__call(self,x,y,z,w)
	local s={x=x,y=y,z=z,w=0}
	if w~=nil then s.w=w end
	s.matrix=Matrix(4,1)
	s.matrix.values={{s.x},{s.y},{s.z},{s.w}}

	function s:copy()
		return Dir3D(self.x,self.y,self.z,self.w)
	end

	function s:updateMatrix()
		self.matrix.values={{self.x},{self.y},{self.z},{self.w}}
	end

	function s:dot(p2)
		return (self.x*p2.x)+(self.y*p2.y)+(self.z*p2.z)
	end

	function s:cross(v)
		local x = ( self.y * v.z ) - ( v.y * self.z )
		local y = ( self.z * v.x ) - ( v.z * self.x )
		local z = ( self.x * v.y ) - ( v.x * self.y )
		return Dir3D(x,y,z,self.w)
	end

	function s:rotate(x,y,z)
		local m=self.matrix
		m:applyRotation(x,y,z)
		self.x,self.y,self.z,self.w = m[1][1],m[2][1],m[3][1],m[4][1]
		self:updateMatrix()
	end

	function s:rotateAboutAxis(dir,angle)
		local m=self.matrix
		m:applyAxisAngleRotation(dir,angle)
		self.x,self.y,self.z,self.w = m[1][1],m[2][1],m[3][1],m[4][1]
		self:updateMatrix()
	end

	function s:canonical()
		local div=self.w
		if self.w == 0 then div = 1 end
		return Dir3D(self.x/div,self.y/div,self.z/div,0)
	end

	function s:magnitude()
		local v = self:canonical()
		if v.w == 0 then
			return math.sqrt(math.abs(v:dot(v)))
		end
		return math.sqrt(math.abs(v:dot(v))-1)
	end

	setmetatable(s,Dir3D.mti)
	return s
end

function Dir3D.mti.__add(self,v)
	if not type(v) == "table" then return end
	return Dir3D(self.x+v.x,self.y+v.y,self.z+v.z,self.w+v.w)
end

function Dir3D.mti.__sub(self,v)
	if not type(v) == "table" then return end
	return Dir3D(self.x-v.x,self.y-v.y,self.z-v.z,self.w-v.w)
end

function Dir3D.mti.__mul(self,v)
	if type(v) == "table" then
		return Dir3D(self.x*v.x,self.y*v.y,self.z*v.z,self.w*v.w)
	elseif type(v) == "number" then
		return Dir3D(self.x*v,self.y*v,self.z*v,self.w*v)
	else return end
end

function Dir3D.mti.__unm(self)
	return Dir3D(-self.x,-self.y,-self.z,-self.w)
end

function Dir3D.fromMatrix(m)
	if m.rows>4 or m.cols>4 then return end
	return Dir3D(m[1][1],m[1][2],m[1][3],m[1][4])
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
		local sinx,cosx = sin(x),cos(x)
		local siny,cosy = sin(y),cos(y)
		local sinz,cosz = sin(z),cos(z)
		local rx,ry,rz=Matrix(4,4),Matrix(4,4),Matrix(4,4)

		rx.values={
			{ 1, 0, 0, 0},
			{ 0, cosx, -sinx, 0 },
			{ 0, sinx, cosx, 0 },
			{ 0, 0, 0, 1}
		}
		ry.values={
			{ cosy, 0, siny, 0},
			{ 0, 1, 0, 0 },
			{ -siny, 0, cosy, 0 },
			{ 0, 0, 0, 1}
		}
		rz.values={
			{ cosz, -sinz, 0, 0},
			{ sinz, cosz, 0, 0},
			{ 0, 0, 1, 0},
			{ 0, 0, 0, 1}
		}

		self.values = ((rx*ry*rz)*self).values
	end

	function s:applyAxisAngleRotation(dir,angle)
		local c=math.cos(angle)
		local s=math.sin(angle)
		local C=1-c
		local x=dir.x
		local y=dir.y
		local z=dir.z
		local Q=Matrix(4,4)
		Q.values={
			{ x*x*C+c,   x*y*C-z*s, x*z*C+y*s, 0 },
			{ y*x*C+z*s, y*y*C+c,   y*z*C-x*s, 0 },
			{ z*x*C-y*s, z*y*C+x*s, z*z*C+c,   0 },
			{ 0,         0,         0,         1 }
		}
		self.values = (Q*self).values
	end

	function s:applyScaleFactor(sx,sy,sz)
		local Q=Matrix(4,4)
		Q.values = {
			{ sx, 0, 0, 0 },
			{ 0, sy, 0, 0 },
			{ 0, 0, sz, 0 },
			{ 0, 0, 0, 1 }
		}
		self.values = (Q*self).values
	end

	function s:applyTranslation(tx,ty,tz)
		local Q=Matrix(4,4)
		Q.values = {
			{ 1, 0, 0, tx },
			{ 0, 1, 0, ty },
			{ 0, 0, 1, tz },
			{ 0, 0, 0, 1 }
		}
		self.values = (Q*self).values
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

function Matrix.fromVector(v,d)
	if d then
		m=Matrix(4,1)
		m.values={{v.x},{v.y},{v.z},{v.w}}
	else
		m=Matrix(1,4)
		m.values={{v.x,v.y,v.z,v.w}}
	end
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

    -- takes a triangle object (table with "vertices" key that contains 3 Pos3D objects) and returns two tables:
    -- one containing tables with keys "vertex" and "plane" for storing the vertex outside of one or more viewing planes (Pos3D) and that plane
    -- and another containing vertices inside all the viewing planes
    local function sortTriangleVerticesByPlaneClipping(tri,origin,rot,scale)

        local clippedVertexPlanePairs = {}
        local unclippedVertices = {}
        local transform = origin ~= nil

        for vertexIndex=1,3 do

            local vertex = tri.vertices[vertexIndex]:copy()
            local vertexLocalTransformPos = vertex
            if transform then vertexLocalTransformPos = vertex:toLocalTransform(origin,rot,scale) end
            
            local pointInView,planes = camera:isPointInView(vertexLocalTransformPos)
            
            if pointInView then
                table.insert(unclippedVertices,vertexLocalTransformPos)
            else
                local clipsNearPlane = false
                for _,plane in pairs(planes) do
                    if plane == "near" then
                        clipsNearPlane = true
                        break
                    end
                end
                table.insert(clippedVertexPlanePairs,{vertex=vertexLocalTransformPos,plane=planes[1],clipsNearPlane=clipsNearPlane})
            end

        end

        return clippedVertexPlanePairs,unclippedVertices

    end

    local function getResultantTriangles(clippedVertexPlanePairs,unclippedVertices)

        local result = {}

        if #clippedVertexPlanePairs == 0 then

            return { {vertices=unclippedVertices} }

        elseif #clippedVertexPlanePairs == 1 then

            local tri1,tri2={vertices={}},{vertices={}}

            tri1.vertices[1] = unclippedVertices[1]
            tri1.vertices[2] = unclippedVertices[2]
            tri1.vertices[3] = getVectorPlaneIntersection( unclippedVertices[1], dirBetween3DPoints(unclippedVertices[1], clippedVertexPlanePairs[1].vertex), camera.clippingPlanes[clippedVertexPlanePairs[1].plane] )
            tri2.vertices[1] = tri1.vertices[3]
            tri2.vertices[2] = unclippedVertices[2]
            tri2.vertices[3] = getVectorPlaneIntersection( unclippedVertices[2], dirBetween3DPoints(unclippedVertices[2], clippedVertexPlanePairs[1].vertex), camera.clippingPlanes[clippedVertexPlanePairs[1].plane] )
            
            local tri1Clipped,tri1Unclipped = sortTriangleVerticesByPlaneClipping(tri1)
            local tri1Absolute = {}
            if #tri1Clipped > 0 then
                tri1Absolute = getResultantTriangles(tri1Clipped,tri1Unclipped)
                for _,v in pairs(tri1Absolute) do
                    table.insert(result,v)
                end
            else
                table.insert(result,tri1)
            end

            local tri2Clipped,tri2Unclipped = sortTriangleVerticesByPlaneClipping(tri2)
            local tri2Absolute = {}
            if #tri2Clipped > 0 then
                tri2Absolute = getResultantTriangles(tri2Clipped,tri2Unclipped)
                for _,v in pairs(tri2Absolute) do
                    table.insert(result,v)
                end
            else
                table.insert(result,tri2)
            end
            
        elseif #clippedVertexPlanePairs == 2 then

            local t={vertices={}}

            t.vertices[1] = unclippedVertices[1]
            t.vertices[2] = getVectorPlaneIntersection( t.vertices[1], dirBetween3DPoints(t.vertices[1],clippedVertexPlanePairs[1].vertex), camera.clippingPlanes[clippedVertexPlanePairs[1].plane])
            t.vertices[3] = getVectorPlaneIntersection( t.vertices[1], dirBetween3DPoints(t.vertices[1],clippedVertexPlanePairs[2].vertex), camera.clippingPlanes[clippedVertexPlanePairs[2].plane])

            local tClipped,tUnclipped = sortTriangleVerticesByPlaneClipping(t)
            local tAbsolute = {}
            if #tClipped > 0 then
                tAbsolute = getResultantTriangles(tClipped,tUnclipped)
                for _,v in pairs(tAbsolute) do
                    table.insert(result,v)
                end
            else
                table.insert(result,t)
            end

        elseif #clippedVertexPlanePairs == 3 then
            local triangleVisible = false
            local subdivisions = 8
            local pointA,pointB,pointC = clippedVertexPlanePairs[1].vertex,clippedVertexPlanePairs[2].vertex,clippedVertexPlanePairs[3].vertex
            local dirBToC,distBToC = dirBetween3DPoints(pointB,pointC),distBetween3DPoints(pointB,pointC)

            local offsetBC = 0
            while offsetBC <= distBToC do
                local scanPointBC = translate3D(pointB,dirBToC,offsetBC)
                local dirScanPointBCToA,distScanPointBCToA = dirBetween3DPoints(pointA,scanPointBC),distBetween3DPoints(scanPointBC,pointA)
                local offsetFromScanPointBC = 0
                while offsetFromScanPointBC <= distScanPointBCToA do
                    triangleVisible = camera:isPointInView( translate3D(pointA,dirScanPointBCToA,offsetFromScanPointBC) )
                    if triangleVisible then break end
                    offsetFromScanPointBC = offsetFromScanPointBC + distScanPointBCToA/subdivisions
                end
                if triangleVisible then break end
                offsetBC = offsetBC + distBToC/subdivisions
            end

            if triangleVisible then
                local clipped,unclipped = {},{}
                for _,v in pairs(clippedVertexPlanePairs) do
                    if v.clipsNearPlane then
                        table.insert(clipped,{vertex=v.vertex,plane="near"})
                    else
                        table.insert(unclipped,v.vertex)
                    end
                end
                result = getResultantTriangles(clipped,unclipped)
            end

        end

        return result

    end

    for triangleIndex,triangle in ipairs(mesh.triangles) do

        local triangleCenter = triangle.center:toLocalTransform(self.origin,self.rot,self.scale)
        local triangleBoundingSphereRadius = distBetween3DPoints( triangleCenter, triangle.vertices[1]:toLocalTransform(self.origin,self.rot,self.scale) )

        if camera:isPointInView(triangleCenter,triangleBoundingSphereRadius) then

            local resultantTriangles = {}
            if triangleIndex == 1 then
                resultantTriangles = getResultantTriangles( sortTriangleVerticesByPlaneClipping(triangle,self.origin,self.rot,self.scale) )
            end

            for _,t in pairs(resultantTriangles) do
                local triangleScreenValues = {}
                for _,vertex in pairs(t.vertices) do
                    local screenPos = worldSpaceToScreenSpace(vertex:toCameraTransform())
                    table.insert(triangleScreenValues,screenPos.x)
                    table.insert(triangleScreenValues,screenPos.y)
                end

                table.insert(triangleScreenValues,5+(6%triangleIndex))
                tri(table.unpack(triangleScreenValues))
                triangleScreenValues[7] = 12
                trib(table.unpack(triangleScreenValues))
            end

        end
    end
end

-- [/TQ-Bundler: class.Object3D]

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
		cube=Object3D("mesh","cube",Pos3D(0,0,3),Rot3D(0,0,0),Dir3D(0,0,1),3)
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

	if btn(4) then scene.get(cube).pos = Pos3D(0,math.sin(t/20)*3,3) end

	-- light.pos.x=10*math.sin(t/100)
	-- light.pos.z=10*math.cos(t/100)+15
	-- light.pos.y=3*math.sin(t/180)

	renderScreen()
	t=t+1
end
-- <MAP>
-- 000:365726560000000000000000c00008008000008000008008008008008008008008008008008000008008008000008008008000008008008008008008008008008008008000008000008008008000008008008000008000008008008008008000008000008000008008008008008000008000008008008000008000008008008008008008008008008000008008008008008008008008008000008008008000008000008000008000008000008008008008008000008000008008008000008008008008008008008008008008008000008008008000008000008008008000008008008008008000008000008008008000
-- 001:0080000080000080000080080080000080000080000080000080080080000080000080080080080080000080000080080080080080000080080080000080080080080080000080080080000080080080080080000080000080000080000080000080b6e696665600000000000000820000f0dfa052d420f95d0060c65017d70074db00f0df50df5108da5600d04028b6d20098db0060c628b6d220f95d00845578555420f95d0060c61017de18745e0060c65017d70074db0060c628b6d220f95d08f0dfa052d420f95d08f0df50df5108da560860c65017d70074db00e0592041d52844db00f0df50df5108da560060
-- 002:c65017d70074db00204028d6d238f15f00e0592041d52844db0060c61017de18745e08d04028b6d20098db0860c68872d40098db08845578555420f95d0860c65017d70074db0860c628b6d220f95d08f0dfa052d420f95d0860c65017d70074db08f0df50df5108da5608e0592041d52844db0860c61017de18745e08e0592041d52844db08204028d6d238f15f00f0df50df5108da5600e0592041d52844db08e0592041d52844db00d04028b6d20098db0060c68872d40098db0860c68872d40098db00f0dfa052d420f95d00f0df50df5108da5608f0df50df5108da560060c628b6d220f95d00f0dfa052d420f9
-- 003:5d08f0dfa052d420f95d00204028d6d238f15f0060c628b6d2180e5b0860c628b6d2180e5b00845578555420f95d08845578555420f95d0860c68872d40098db00e0592041d52844db00204028d6d238f15f08204028d6d238f15f00845578555420f95d0060c628b6d220f95d0860c628b6d220f95d0060c628b6d2180e5b00d04028b6d20098db08d04028b6d20098db00d04028b6d20098db00845578555420f95d0060c68872d40098db0060c61017de18745e0060c628b6d220f95d0060c628b6d2180e5b0060c628b6d2180e5b0060c628b6d220f95d00d04028b6d20098db0060c628b6d220f95d0060c65017
-- 004:d70074db00f0dfa052d420f95d00e0592041d52844db0060c65017d70074db0060c61017de18745e00204028d6d238f15f0060c61017de18745e0060c628b6d2180e5b08d04028b6d20098db08845578555420f95d0860c628b6d220f95d08d04028b6d20098db0860c628b6d220f95d0860c628b6d2180e5b0860c628b6d2180e5b0860c628b6d220f95d0860c61017de18745e0860c61017de18745e0860c628b6d220f95d0860c65017d70074db0860c65017d70074db08e0592041d52844db0860c61017de18745e0860c61017de18745e08204028d6d238f15f0860c628b6d2180e5b00f0df50df5108da5608e0
-- 005:592041d52844db08f0df50df5108da5600d04028b6d20098db0860c68872d40098db08d04028b6d20098db00f0dfa052d420f95d08f0df50df5108da5608f0dfa052d420f95d0060c628b6d220f95d08f0dfa052d420f95d0860c628b6d220f95d00204028d6d238f15f0860c628b6d2180e5b08204028d6d238f15f00845578555420f95d0860c68872d40098db0060c68872d40098db00e0592041d52844db08204028d6d238f15f08e0592041d52844db00845578555420f95d0860c628b6d220f95d08845578555420f95d0060c628b6d2180e5b08d04028b6d20098db0860c628b6d2180e5b0000000000000000
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

