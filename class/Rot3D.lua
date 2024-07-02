Rot3D={}
Rot3D.mt={}
Rot3D.mti={}

function Rot3D.mt.__call(self,x,y,z)
	local s={x=x,y=y,z=z}

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