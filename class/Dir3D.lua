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