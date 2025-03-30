Pos3D={}
Pos3D.mt={}
Pos3D.mti={}

function Pos3D.mt.__call(self,x,y,z,w)
	local s={x=x,y=y,z=z,w=(w or 1)}
	return setmetatable(s,Pos3D.mti)
end

function Pos3D:getCopy()
	return Pos3D(self.x,self.y,self.z,self.w)
end

function Pos3D:getDotProduct(p2)
	return (self.x*p2.x)+(self.y*p2.y)+(self.z*p2.z)+(self.w*p2.w)
end

function Pos3D:scale(sx,sy,sz)
	return self * Pos3D(sx,sy,sz)
end

function Pos3D:translate(tx,ty,tz)
	return self + Pos3D(tx,ty,tz)
end

function Pos3D:rotateAboutAxis(dir,angle)
	local rq = Quaternion.Rotation(dir,angle)
	local newPos = rq:rotatePoint(self)
	self.x,self.y,self.z,self.w = newPos.x,newPos.y,newPos.z,1
end

function Pos3D:getCrossProduct(v)
	local x = ( self.y * v.z ) - ( v.y * self.z )
	local y = ( self.z * v.x ) - ( v.z * self.x )
	local z = ( self.x * v.y ) - ( v.x * self.y )
	return Pos3D(x,y,z,self.w)
end

function Pos3D:toLocalTransform(origin,rot,scale)
	local newPoint = self*scale
	local rq = Quaternion.RotationFromEulerAngles(rot)
	newPoint = rq:rotatePoint(newPoint)
	newPoint = newPoint+origin
	return newPoint
end

function Pos3D:toScreenSpace()
	local x,y,z = self.x,self.y,self.z
	local fd = viewport._focalDist
	local sw,sh,vw,vh = SCREEN_WIDTH,SCREEN_HEIGHT,viewport.size.w,viewport.size.h
	local fdz = fd/z
	return Pos2D(
		(fdz*x+vw/2)*(sw/vw),
		(fdz*y+vh/2)*(sh/vh)
	)
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