Pos3D={}
Pos3D.mt={}
Pos3D.mti={}

function Pos3D.mt.__call(self,x,y,z,w)
	local s={x=x,y=y,z=z,w=(w or 1)}
	s.matrix=Matrix4D.fromVector3D(s)
	return setmetatable(s,Pos3D.mti)
end

function Pos3D:updateMatrix()
	self.matrix.values={{self.x},{self.y},{self.z},{self.w}}
end

function Pos3D:getCopy()
	return Pos3D(self.x,self.y,self.z,self.w)
end

function Pos3D:getDotProduct(p2)
	return (self.x*p2.x)+(self.y*p2.y)+(self.z*p2.z)+(self.w*p2.w)
end

function Pos3D:scale(sx,sy,sz)
	local m=self.matrix
	m:applyScaleFactor(sx,sy,sz)
	self.x,self.y,self.z,self.w = m[1][1],m[2][1],m[3][1],m[4][1]
	self:updateMatrix()
end

function Pos3D:translate(tx,ty,tz)
	local m=self.matrix
	m:applyTranslation(tx,ty,tz)
	self.x,self.y,self.z,self.w = m[1][1],m[2][1],m[3][1],m[4][1]
	self:updateMatrix()
end

function Pos3D:rotateAboutAxis(dir,angle)
	local rq = Quaternion.Rotation(dir,angle)
	local newPos = rq:rotatePoint(self)
	self.x,self.y,self.z,self.w = newPos.x,newPos.y,newPos.z,1
	self:updateMatrix()
end

function Pos3D:getCrossProduct(v)
	local x = ( self.y * v.z ) - ( v.y * self.z )
	local y = ( self.z * v.x ) - ( v.z * self.x )
	local z = ( self.x * v.y ) - ( v.x * self.y )
	return Pos3D(x,y,z,self.w)
end

function Pos3D:toLocalTransform(origin,rot,scale)
	local scaledPoint = self*scale
	local rq = Quaternion.RotationFromEulerAngles(rot)
	scaledPoint = rq:rotatePoint(scaledPoint)
	scaledPoint = scaledPoint+origin
	return scaledPoint
end

function Pos3D:toScreenSpace()
	return self.matrix:toScreenSpace()
end

function Pos3D:getMagnitude()
	if s.w == 0 then
		return math.sqrt(self:getDotProduct(self))
	end
	return math.sqrt(math.abs(self:getDotProduct(self)-1))
end

function Pos3D:toCameraTransform()

	local pos = camera.pos
	local rot = camera.rot
	local posx,posy,posz=pos.x,pos.y,pos.z
	local rotx,roty,rotz=rot.x,rot.y,rot.z

	local newPoint = Pos3D(self.x-posx,self.y-posy,self.z-posz)
	local rq = Quaternion.RotationFromEulerAngles(Rot3D(-rotx,PI-roty,-rotz))
	newPoint = rq:rotatePoint(newPoint)

	return newPoint

end

function Pos3D:canonical()
	local div = 1
	if self.w ~= 0 then div=self.w end
	return Pos3D(self.x/div,self.y/div,self.z/div,1)
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

function Pos3D.mti.__index(self,i)
	return rawget(self,i) ~= nil and rawget(self,i) or Pos3D[i]
end

setmetatable(Pos3D,Pos3D.mt)