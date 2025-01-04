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
Matrix4D.screenProjectionMatrix.values = {
	{"viewportfocaldist",0,0,0},
	{0,"viewportfocaldist",0,0},
	{0,0,1,0},
	{0,0,1,0}
}

function Matrix4D.mt.__call(self,x,y,z,w)
	local s=Matrix(4,1)
	s.values = {{x},{y},{z},{w}}

	function s:getCopy()
		return Matrix4D(self[1][1],self[2][1],self[3][1],self[4][1])
	end

	function s:applyRotation(x,y,z)
		local sin = sinq
		local cos = cosq
		local sinx,cosx = sin(x),cos(x)
		local siny,cosy = sin(y),cos(y)
		local sinz,cosz = sin(z),cos(z)
		local rx,ry,rz=Matrix4D.rotationMatrixX,Matrix4D.rotationMatrixY,Matrix4D.rotationMatrixZ

		rx[2][2] = cosx
		rx[2][3] = -sinx
		rx[3][2] = sinx
		rx[3][3] = cosx

		ry[1][1] = cosy
		ry[1][3] = siny
		ry[3][1] = -siny
		ry[3][3] = cosy

		rz[1][1] = cosz
		rz[1][2] = -sinz
		rz[2][1] = sinz
		rz[2][2] = cosz

		self.values = ((rx*ry*rz)*self).values
	end

	function s:applyAxisAngleRotation(dir,angle)
		local c=cosq(angle)
		local s=sinq(angle)
		local C=1-c
		local x=dir.x
		local y=dir.y
		local z=dir.z
		local Q=Matrix(4,4)
		local xC,yC,zC,xs,ys,zs = x*C,y*C,z*C,x*s,y*s,z*s
		Q.values={
			{ x*xC+c,  y*xC-zs, z*xC+ys, 0 },
			{ y*xC+zs, y*yC+c,  z*yC-xs, 0 },
			{ z*xC-ys, z*yC+xs, z*zC+c,  0 },
			{ 0,       0,       0,       1 }
		}
		self.values = (Q*self).values
	end

	function s:applyScaleFactor(sx,sy,sz)
		local Q=Matrix(4,4)
		Q.values = {
			{ sx, 0, 0, 0 },
			{ 0, sy, 0, 0 },
			{ 0, 0, sz, 0 },
			{ 0, 0, 0, 1 }
		}
		self.values = (Q*self).values
	end

	function s:applyTranslation(tx,ty,tz)
		local Q=Matrix(4,4)
		Q.values = {
			{ 1, 0, 0, tx },
			{ 0, 1, 0, ty },
			{ 0, 0, 1, tz },
			{ 0, 0, 0, 1 }
		}
		self.values = (Q*self).values
	end

	function s:getCanonical()
		return Matrix4D(self[1][1]/self[4][1],self[2][1]/self[4][1],self[3][1]/self[4][1],1)
	end

	function s:toLocalTransform(origin,rot,scale)
		local m=self:getCopy()
		m:applyScaleFactor(scale,scale,scale)
		m:applyRotation(rot.x,rot.y,rot.z)
		m:applyTranslation(origin.x,origin.y,origin.z)
		return Pos3D(m[1][1],m[2][1],m[3][1],m[4][1])
	end

	function s:toScreenSpace()

		local projectionMatrix = Matrix4D.screenProjectionMatrix

		local result = Matrix4D.fromMatrix(projectionMatrix*self):getCanonical()
		result[1][1] = ((result[1][1]+viewport.size.w/2)*SCREEN_WIDTH)/viewport.size.w
		result[2][1] = ((result[2][1]+viewport.size.h/2)*SCREEN_HEIGHT)/viewport.size.h

		return Pos2D(result[1][1],result[2][1])

	end

	setmetatable(s,Matrix4D.mti)
	return s
end

function Matrix4D.fromVector3D(v)
	return Matrix4D(v.x,v.y,v.z,v.w)
end

function Matrix4D.fromMatrix(m)
	return Matrix4D(m[1][1],m[2][1],m[3][1],m[4][1])
end

Matrix4D.mti.__index = Matrix.mti.__index
Matrix4D.mti.__add = Matrix.mti.__add
Matrix4D.mti.__sub = Matrix.mti.__sub
Matrix4D.mti.__mul = Matrix.mti.__mul

setmetatable(Matrix4D,Matrix4D.mt)