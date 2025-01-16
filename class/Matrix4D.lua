Matrix4D={}
Matrix4D.mt={}
Matrix4D.mti={}

Matrix4D.rotationMatrixX,Matrix4D.rotationMatrixY,Matrix4D.rotationMatrixZ,Matrix4D.screenProjectionMatrix = Matrix(4,4),Matrix(4,4),Matrix(4,4),Matrix(4,4)

Matrix4D.rotationMatrixX.values = {
	{ 1, 0, 0, 0},
	{ 0, "cosx", "-sinx", 0 },
	{ 0, "sinx", "cosx", 0 },
	{ 0, 0, 0, 1}
}
Matrix4D.rotationMatrixY.values = {
	{ "cosy", 0, "siny", 0},
	{ 0, 1, 0, 0 },
	{ "-siny", 0, "cosy", 0 },
	{ 0, 0, 0, 1}
}
Matrix4D.rotationMatrixZ.values = {
	{ "cosz", "-sinz", 0, 0},
	{ "sinz", "cosz", 0, 0},
	{ 0, 0, 1, 0},
	{ 0, 0, 0, 1}
}

function Matrix4D.mt.__call(self,x,y,z,w)
	local s=Matrix(4,1)
	s.values = {{x},{y},{z},{w}}
	return setmetatable(s,Matrix4D.mti)
end

function Matrix4D:getCopy()
	return Matrix4D(self[1][1],self[2][1],self[3][1],self[4][1])
end

do
	local function applyRotation(m,self,x,y,z)
		local sin = sinq
		local cos = cosq
		local sinx,cosx = sin(x),cos(x)
		local siny,cosy = sin(y),cos(y)
		local sinz,cosz = sin(z),cos(z)
		local rx,ry,rz=Matrix4D.rotationMatrixX,Matrix4D.rotationMatrixY,Matrix4D.rotationMatrixZ
	
		if x ~= 0 then
			rx[2][2] = cosx
			rx[2][3] = -sinx
			rx[3][2] = sinx
			rx[3][3] = cosx
			m.values = (m*rx).values
		end
	
		if y ~= 0 then
			ry[1][1] = cosy
			ry[1][3] = siny
			ry[3][1] = -siny
			ry[3][3] = cosy
			m.values = (m*ry).values
		end
	
		if z ~= 0 then
			rz[1][1] = cosz
			rz[1][2] = -sinz
			rz[2][1] = sinz
			rz[2][2] = cosz
			m.values = (m*rz).values
		end
	
		self.values = (m*self).values
	end
	Matrix4D.applyRotation = Matrix.bindLocalMatrixToFunction(applyRotation,4,4,{
		{1,0,0,0},
		{0,1,0,0},
		{0,0,1,0},
		{0,0,0,1}
	})

	local function applyAxisAngleRotation(m,self,dir,angle)
		local c=cosq(angle)
		local s=sinq(angle)
		local C=1-c
		local x,y,z = dir.x,dir.y,dir.z
		local xC,yC,zC,xs,ys,zs = x*C,y*C,z*C,x*s,y*s,z*s
		local values = m.values

		values[1][1] = x*xC+c
		values[1][2] = y*xC-zs
		values[1][3] = z*xC+ys
		values[2][1] = y*xC+zs
		values[2][2] = y*yC+c
		values[2][3] = z*yC-xs
		values[3][1] = z*xC-ys
		values[3][2] = z*yC+xs
		values[3][3] = z*zC+c
		
		self.values = (m*self).values
	end
	Matrix4D.applyAxisAngleRotation = Matrix.bindLocalMatrixToFunction(applyAxisAngleRotation,4,4,{
		{0,0,0,0},
		{0,0,0,0},
		{0,0,0,0},
		{0,0,0,1}
	})

	local function applyScaleFactor(m,self,sx,sy,sz)
		local values = m.values
		values[1][1] = sx
		values[2][2] = sy
		values[3][3] = sz
		self.values = (m*self).values
	end
	Matrix4D.applyScaleFactor = Matrix.bindLocalMatrixToFunction(applyScaleFactor,4,4,{
		{0,0,0,0},
		{0,0,0,0},
		{0,0,0,0},
		{0,0,0,1}
	})

	local function applyTranslation(m,self,tx,ty,tz)
		local values = m.values
		values[1][4] = tx
		values[2][4] = ty
		values[3][4] = tz
		self.values = (m*self).values
	end
	Matrix4D.applyTranslation = Matrix.bindLocalMatrixToFunction(applyTranslation,4,4,{
		{1,0,0,0},
		{0,1,0,0},
		{0,0,1,0},
		{0,0,0,1}
	})

	local function toScreenSpace(m,self)
	
		local viewportWidth,viewportHeight,viewportFocalDist = viewport.size.w,viewport.size.h,viewport._focalDist
		local values = m.values
		values[1][1] = viewportFocalDist
		values[2][2] = viewportFocalDist

		local result = Matrix4D.fromMatrix(m*self):getCanonical().values
	
		result[1][1] = ((result[1][1]+viewportWidth/2)*SCREEN_WIDTH)/viewportWidth
		result[2][1] = ((result[2][1]+viewportHeight/2)*SCREEN_HEIGHT)/viewportHeight
	
		return Pos2D(result[1][1],result[2][1])
	
	end
	Matrix4D.toScreenSpace = Matrix.bindLocalMatrixToFunction(toScreenSpace,4,4,{
		{0,0,0,0},
		{0,0,0,0},
		{0,0,1,0},
		{0,0,1,0}
	})

end

function Matrix4D:getCanonical()
	local w = self[4][1]
	return Matrix4D(self[1][1]/w,self[2][1]/w,self[3][1]/w,1)
end

function Matrix4D:toLocalTransform(origin,rot,scale)

	local values = self.values
	local x,y,z,w = values[1][1],values[2][1],values[3][1],values[4][1]

	local sinq,cosq = sinq,cosq -- local references to external functions
	
	local sx,sy,sz = scale,scale,scale
	local tx,ty,tz = origin.x,origin.y,origin.z
	
	local sin_rx,cos_rx = sinq(rot.x),cosq(rot.x)
	local sin_ry,cos_ry = sinq(rot.y),cosq(rot.y)
	local sin_rz,cos_rz = sinq(rot.z),cosq(rot.z)

	local sxx,syy,szz = sx*x,sy*y,sz*z

	local finalX = cos_ry*cos_rz*sxx + cos_ry*-sin_rz*syy + sin_ry*szz + tx*w
	local finalY = (-sin_rx*-sin_ry*cos_rz+cos_rx*sin_rz)*sxx + (-sin_rx*-sin_ry*-sin_rz+cos_rx*cos_rz)*syy + -sin_rx*cos_ry*szz + ty*w
	local finalZ = (cos_rx*-sin_ry*cos_rz+sin_rx*sin_rz)*sxx + (cos_rx*-sin_ry*-sin_rz+sin_rx*cos_rz)*syy + cos_rx*cos_ry*szz + tz*w

	return Pos3D(finalX,finalY,finalZ,w)

end

function Matrix4D.fromVector3D(v)
	return Matrix4D(v.x,v.y,v.z,v.w)
end

function Matrix4D.fromMatrix(m)
	return Matrix4D(m[1][1],m[2][1],m[3][1],m[4][1])
end

function Matrix4D.mti.__index(self,i)
	return self.values[i] ~= nil and self.values[i] or Matrix4D[i]
end

Matrix4D.mti.__add = Matrix.mti.__add
Matrix4D.mti.__sub = Matrix.mti.__sub
Matrix4D.mti.__mul = Matrix.mti.__mul

setmetatable(Matrix4D,Matrix4D.mt)