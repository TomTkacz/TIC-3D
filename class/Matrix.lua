Matrix={}
Matrix.mt={}
Matrix.mti={}

function Matrix.mt.__call(self,rows,cols)
    local values = {}
    for row = 1, rows do
        local rowValues = {}
        for col = 1, cols do
            rowValues[col] = 0
        end
        values[row] = rowValues
    end
    local s = { rows = rows, cols = cols, values = values }
    return setmetatable(s, Matrix.mti)
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

Matrix.M44 = Matrix(4,4)
Matrix.M41 = Matrix(4,1)

function Matrix.bindLocalMatrixToFunction(func,rows,cols,initialValuesTable)
	local m = Matrix(rows,cols)
	local unpack = table.unpack
	function transform(...)
		local params={...}
		if initialValuesTable then m.values = initialValuesTable end
		return func(m,unpack(params))
	end
	return transform
end