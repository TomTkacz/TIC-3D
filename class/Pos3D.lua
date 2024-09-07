Pos3D={}
Pos3D.mt={}
Pos3D.mti={}

function Pos3D.mt.__call(self,x,y,z,w)
	local s={x=x,y=y,z=z,w=1}
	if w then s.w=w end
	s.matrix=Matrix4D.fromVector3D(s)

	function s:updateMatrix()
		self.matrix.values={{self.x},{self.y},{self.z},{self.w}}
	end

	function s:getCopy()
		return Pos3D(self.x,self.y,self.z,self.w)
	end

	function s:getDotProduct(p2)
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

	function s:getCrossProduct(v)
		local x = ( self.y * v.z ) - ( v.y * self.z )
		local y = ( self.z * v.x ) - ( v.z * self.x )
		local z = ( self.x * v.y ) - ( v.x * self.y )
		return Pos3D(x,y,z,self.w)
	end

	function s:toLocalTransform(origin,rot,scale)
		return self.matrix:toLocalTransform(origin,rot,scale)
	end

	function s:toScreenSpace()
		return self.matrix:toScreenSpace()
	end
	
	function s:getMagnitude()
		if s.w == 0 then
			return math.sqrt(self:getDotProduct(self))
		end
		return math.sqrt(math.abs(self:getDotProduct(self)-1))
	end

	function s:toCameraTransform()

		local m = self.matrix:getCopy()

		-- translate/rotate about the camera
		m:applyTranslation(-camera.pos.x,-camera.pos.y,-camera.pos.z)
		m:applyAxisAngleRotation(Dir3D(1,0,0),-camera.rot.x)
		m:applyAxisAngleRotation(Dir3D(0,1,0),PI-camera.rot.y)
		m:applyAxisAngleRotation(Dir3D(0,0,1),-camera.rot.z)

		return Pos3D.fromMatrix4D(m)

	end

	function s:canonical()
		local div = 1
		if self.w ~= 0 then div=self.w end
		return Pos3D(self.x/div,self.y/div,self.z/div,1)
	end

	setmetatable(s,Pos3D.mti)
	return s
end

function Pos3D.fromMatrix4D(m)
	return Pos3D(m[1][1],m[2][1],m[3][1],m[4][1])
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