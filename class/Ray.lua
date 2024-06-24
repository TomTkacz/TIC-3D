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