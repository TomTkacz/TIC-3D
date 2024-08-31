Matrix={}
Matrix.mt={}
Matrix.mti={}

function Matrix.mt.__call(self,rows,cols,fill)
	if fill==nil then fill=0 end
	s={rows=rows,cols=cols,values={}}

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

	for row=1,rows do
		s.values[row]={}
		for col=1,cols do
			s.values[row][col]=fill
		end
	end
	setmetatable(s,Matrix.mti)
	return s
end

function Matrix.fromVector(v,d)
	if d then
		m=Matrix(4,1)
		m.values={{v.x},{v.y},{v.z},{v.w}}
	else
		m=Matrix(1,4)
		m.values={{v.x,v.y,v.z,v.w}}
	end
	return m
end

function Matrix.mti.__index(self,i)
	return self.values[i]
end

function Matrix.mti.__add(self,m)
	if self.rows ~= m.rows then return end
	if self.cols ~= m.cols then return end
	n=Matrix(self.rows,self.cols)
	for row=1,self.rows do
		for col=1,self.cols do
			n[row][col] = self[row][col]+m[row][col]
		end
	end
	return n
end

function Matrix.mti.__sub(self,m)
	if self.rows ~= m.rows then return end
	if self.cols ~= m.cols then return end
	n=Matrix(self.rows,self.cols)
	for row=1,self.rows do
		for col=1,self.cols do
			n[row][col] = self[row][col]-m[row][col]
		end
	end
	return n
end

function Matrix.mti.__mul(self,m2)
	-- multiply rows with columns
	local m1=self
	local mtx = Matrix(m1.rows,m2.cols)
	for i = 1,m1.rows do
		for j = 1,m2.cols do
			local num = m1.values[i][1] * m2.values[1][j]
			for n = 2,m1.cols do
				num = num + m1.values[i][n] * m2.values[n][j]
			end
			mtx.values[i][j] = num
		end
	end
	return mtx
end

setmetatable(Matrix,Matrix.mt)