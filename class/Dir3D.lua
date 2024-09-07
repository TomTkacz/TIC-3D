Dir3D={}
Dir3D.mt={}
Dir3D.mti={}

function Dir3D.mt.__call(self,x,y,z,w)
	local s={x=x,y=y,z=z,w=0}
	if w then s.w=w end
	s.matrix=Matrix4D.fromVector3D(s)

	function s:getCopy()
		return Dir3D(self.x,self.y,self.z,self.w)
	end

	function s:updateMatrix()
		self.matrix.values={{self.x},{self.y},{self.z},{self.w}}
	end

	function s:getDotProduct(p2)
		return (self.x*p2.x)+(self.y*p2.y)+(self.z*p2.z)
	end

	function s:getCrossProduct(v)
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

	function s:getCanonical()
		local div=self.w
		if self.w == 0 then div = 1 end
		return Dir3D(self.x/div,self.y/div,self.z/div,0)
	end

	function s:getMagnitude()
		local v = self:getCanonical()
		if v.w == 0 then
			return math.sqrt(math.abs(v:getDotProduct(v)))
		end
		return math.sqrt(math.abs(v:getDotProduct(v))-1)
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

function Dir3D.fromMatrix4D(m)
	return Dir3D(m[1][1],m[2][1],m[3][1],m[4][1])
end

setmetatable(Dir3D,Dir3D.mt)