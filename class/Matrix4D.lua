Matrix4D={}
Matrix4D.mt={}
Matrix4D.mti={}

function Matrix4D.mt.__call(self,x,y,z,w)
	local s=Matrix(4,1)
	s.values = {{x},{y},{z},{w}}

	function s:applyRotation(x,y,z)
		local sin = math.sin
		local cos = math.cos
		local sinx,cosx = sin(x),cos(x)
		local siny,cosy = sin(y),cos(y)
		local sinz,cosz = sin(z),cos(z)
		local rx,ry,rz=Matrix(4,4),Matrix(4,4),Matrix(4,4)

		rx.values={
			{ 1, 0, 0, 0},
			{ 0, cosx, -sinx, 0 },
			{ 0, sinx, cosx, 0 },
			{ 0, 0, 0, 1}
		}
		ry.values={
			{ cosy, 0, siny, 0},
			{ 0, 1, 0, 0 },
			{ -siny, 0, cosy, 0 },
			{ 0, 0, 0, 1}
		}
		rz.values={
			{ cosz, -sinz, 0, 0},
			{ sinz, cosz, 0, 0},
			{ 0, 0, 1, 0},
			{ 0, 0, 0, 1}
		}
		self.values = ((rx*ry*rz)*self).values
	end

	function s:applyAxisAngleRotation(dir,angle)
		local c=math.cos(angle)
		local s=math.sin(angle)
		local C=1-c
		local x=dir.x
		local y=dir.y
		local z=dir.z
		local Q=Matrix(4,4)
		Q.values={
			{ x*x*C+c,   x*y*C-z*s, x*z*C+y*s, 0 },
			{ y*x*C+z*s, y*y*C+c,   y*z*C-x*s, 0 },
			{ z*x*C-y*s, z*y*C+x*s, z*z*C+c,   0 },
			{ 0,         0,         0,         1 }
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

	setmetatable(s,Matrix4D.mti)
	return s
end

function Matrix4D.fromVector3D(v)
	return Matrix4D(v.x,v.y,v.z,v.w)
end

Matrix4D.mti.__index = Matrix.mti.__index
Matrix4D.mti.__add = Matrix.mti.__add
Matrix4D.mti.__sub = Matrix.mti.__sub
Matrix4D.mti.__mul = Matrix.mti.__mul

setmetatable(Matrix4D,Matrix4D.mt)