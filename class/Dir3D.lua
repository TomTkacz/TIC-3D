Dir3D={}
Dir3D.mt={}
Dir3D.mti={}

function Dir3D.mt.__call(self,x,y,z,w)
	local s={x=x,y=y,z=z,w=(w or 0)}
	return setmetatable(s,Dir3D.mti)
end

function Dir3D:getCopy()
	return Dir3D(self.x,self.y,self.z,self.w)
end

function Dir3D:getDotProduct(p2)
	return (self.x*p2.x)+(self.y*p2.y)+(self.z*p2.z)
end

function Dir3D:getCrossProduct(v)
	local x = ( self.y * v.z ) - ( v.y * self.z )
	local y = ( self.z * v.x ) - ( v.z * self.x )
	local z = ( self.x * v.y ) - ( v.x * self.y )
	return Dir3D(x,y,z,self.w)
end

function Dir3D:rotate(x,y,z)
	local qr = Quaternion.RotationFromEulerAngles(Dir3D(x,y,z))
	local newDir = qr:rotatePoint(self)
	self.x,self.y,self.z,self.w = newDir.x,newDir.y,newDir.z,0
end

function Dir3D:rotateAboutAxis(dir,angle)
	local rq = Quaternion.Rotation(dir,angle)
	local newDir = rq:rotatePoint(self)
	self.x,self.y,self.z,self.w = newDir.x,newDir.y,newDir.z,0
end

function Dir3D:getCanonical()
	local div=self.w
	if self.w == 0 then div = 1 end
	return Dir3D(self.x/div,self.y/div,self.z/div,0)
end

function Dir3D:getMagnitude()
	local v = self:getCanonical()
	if v.w == 0 then
		return math.sqrt(math.abs(v:getDotProduct(v)))
	end
	return math.sqrt(math.abs(v:getDotProduct(v))-1)
end

function Dir3D.mti.__index(self,i)
	return Dir3D[i]
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

setmetatable(Dir3D,Dir3D.mt)