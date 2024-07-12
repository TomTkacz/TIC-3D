Dir3D={}
Dir3D.mt={}
Dir3D.mti={}

function Dir3D.mt.__call(self,x,y,z,w)
	local s={x=x,y=y,z=z,w=0}
	if w~=nil then s.w=w end
	s.matrix=Matrix(4,1)
	s.matrix.values={{s.x},{s.y},{s.z},{s.w}}

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