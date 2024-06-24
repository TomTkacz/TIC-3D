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

-- [TQ-Bundler: include.Pickle]

----------------------------------------------
-- Pickle.lua
-- A table serialization utility for lua
-- Steve Dekorte, http://www.dekorte.com, Apr 2000
-- Freeware
----------------------------------------------

function pickle(t)
    return Pickle:clone():pickle_(t)
end

Pickle = {
    clone = function (t) local nt={}; for i, v in pairs(t) do nt[i]=v end return nt end 
}

function Pickle:pickle_(root)
    if type(root) ~= "table" then 
        error("can only pickle tables, not ".. type(root).."s")
    end
    self._tableToRef = {}
    self._refToTable = {}
    local savecount = 0
    self:ref_(root)
    local s = ""

    while #(self._refToTable) > savecount do
        savecount = savecount + 1
        local t = self._refToTable[savecount]
        s = s.."{\n"
        for i, v in pairs(t) do
            if type(v) ~= "function" then
                s = string.format("%s[%s]=%s,\n", s, self:value_(i), self:value_(v))
            end
        end
        s = s.."},\n"
    end

    return string.format("{%s}", s)
end

function Pickle:value_(v)
    local vtype = type(v)
    if vtype == "string" then return string.format("%q", v)
    elseif vtype == "number" then return round(v,2)
    elseif vtype == "boolean" then return tostring(v)
    elseif vtype == "table" then return "{"..self:ref_(v).."}"
    else error("pickle a "..type(v).." is not supported")
    end
end

function Pickle:ref_(t)
    local ref = self._tableToRef[t]
    if not ref then 
        if t == self then error("can't pickle the pickle class") end
        table.insert(self._refToTable, t)
        ref = #(self._refToTable)
        self._tableToRef[t] = ref
    end
    return ref
end

-- [/TQ-Bundler: include.Pickle]

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

sphere={
	pos=Pos3D(0,0,15),
	r=5
}

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

-- could genericize this to a hit() method in an Object3D class?
function renderPixel(x,y)
	targetpos=screenSpaceToViewportSpace(x,y)
	r=Ray.fromPoints(camera.pos,targetpos)
	co=r.pos-sphere.pos
	a=r.dir:dot(r.dir)
	b=2*co:dot(r.dir)
	c=co:dot(co)-(sphere.r*sphere.r)
	disc=(b*b)-4*a*c
	if disc<0 then
		screen.pixels[y][x]=0
		return
	end
	hit1=(-b+math.sqrt(disc))/(2*a)
	hit2=(-b-math.sqrt(disc))/(2*a)
	hit=-1
	if hit2<0 or (hit1>=0 and hit1<hit2) then hit=hit1 end
	if hit1<0 or (hit2>=0 and hit2<hit1) then hit=hit2 end
	if hit>=0 then
		local distanceToLight=distBetween3DPoints(translate3D(camera.pos,r.dir,hit),light.pos)
		if distanceToLight>13 then
			screen.pixels[y][x]=1
		else
			screen.pixels[y][x]=7.5-math.floor(distanceToLight/2)+1
		end
	else
		screen.pixels[y][x]=0
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