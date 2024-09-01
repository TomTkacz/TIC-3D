Matrix={}
Matrix.mt={}
Matrix.mti={}

function Matrix.mt.__call(self,rows,cols,fill)
	if fill==nil then fill=0 end
	s={rows=rows,cols=cols,values={}}

	for row=1,rows do
		s.values[row]={}
		for col=1,cols do
			s.values[row][col]=fill
		end
	end
	setmetatable(s,Matrix.mti)
	return s
end

function Matrix.mti.__index(self,i)
	return self.values[i]
end

function Matrix.mti.__add(self,m)
	n=Matrix(self.rows,self.cols)
	for row=1,self.rows do
		for col=1,self.cols do
			n[row][col] = self[row][col]+m[row][col]
		end
	end
	return n
end

function Matrix.mti.__sub(self,m)
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