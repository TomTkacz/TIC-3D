Matrix={}
Matrix.mt={}
Matrix.mti={}

function Matrix.mt.__call(self,rows,cols,fill)
	if fill==nil then fill=0 end
	s={rows=rows,cols=cols,values={}}

	function s:applyRotation(x,y,z)
		local sin = math.sin
		local cos = math.cos
		local rx=Matrix(3,3)
		local sinx,cosx = sin(x),cos(x)
		rx.values={{1,0,0},{0,cosx,-sinx},{0,sinx,cosx}}
		local ry=Matrix(3,3)
		local siny,cosy = sin(y),cos(y)
		ry.values={{cosy,0,siny},{0,1,0},{-siny,0,cosy}}
		local rz=Matrix(3,3)
		local sinz,cosz = sin(z),cos(z)
		rz.values={{cosz,-sinz,0},{sinz,cosz,0},{0,0,1}}
		self.values = (self*(rx*ry*rz)).values
	end

	function s:applyAxisAngleRotation(dir,angle)
		local c=math.cos(angle)
		local s=math.sin(angle)
		local C=1-c
		local x=dir.x
		local y=dir.y
		local z=dir.z
		local Q=Matrix(3,3)
		Q.values={
			{ x*x*C+c, x*y*C-z*s, x*z*C+y*s },
			{ y*x*C+z*s, y*y*C+c, y*z*C-x*s },
			{ z*x*C-y*s, z*y*C+x*s, z*z*C+c },
		}
		self.values = (self*Q).values
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

function Matrix.fromVector(v)
	local m=Matrix(1,3)
	m.values={{v.x,v.y,v.z}}
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

function Matrix.mti.__mul(self,m)
	if type(m)=="table" then
		if self.cols ~= m.rows then return end
		local n=Matrix(self.rows,m.cols)
		for nrow=1,self.rows do
			for ncol=1,m.cols do
				local total=0
				for col=1,self.cols do
					total=total+(self[nrow][col]*m[col][ncol])
				end
				n[nrow][ncol]=total
			end
		end
		return n
	end
	local n=Matrix(self.rows,self.cols)
	for row=1,self.rows do
		for col=1,self.cols do
			n[row][col] = self[row][col]*m
		end
	end
	return n
end

setmetatable(Matrix,Matrix.mt)