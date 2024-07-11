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

	function s:toLocalTransform(origin,rot,scale)

		local vertexPos = self:canonical()

		-- scale
		vertexPos:scale(scale,scale,scale)

		-- translate/rotate about the origin
		vertexPos:rotateAboutAxis(Dir3D(1,0,0),rot.x)
		vertexPos:rotateAboutAxis(Dir3D(0,1,0),rot.y)
		vertexPos:rotateAboutAxis(Dir3D(0,0,1),rot.z)
		vertexPos:translate(origin.x,origin.y,origin.z)

		return vertexPos

	end

	function s:toCameraTransform()

		local vertexPos = self:canonical()

		-- translate/rotate about the camera
		vertexPos:translate(-camera.pos.x,-camera.pos.y,-camera.pos.z)
		vertexPos:rotateAboutAxis(Dir3D(1,0,0),-camera.rot.x)
		vertexPos:rotateAboutAxis(Dir3D(0,1,0),math.pi-camera.rot.y)
		vertexPos:rotateAboutAxis(Dir3D(0,0,1),-camera.rot.z)

		return vertexPos

	end

	function s:canonical()
		return Pos3D(self.x/self.w,self.y/self.w,self.z/self.w,1)
	end

	setmetatable(s,Pos3D.mti)
	return s
end

function Pos3D.fromMatrix(m)
	if m.rows~=1 or m.cols~=3 then return end
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