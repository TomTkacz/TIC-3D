Pos2D={}
Pos2D.mt={}
Pos2D.mti={}

function Pos2D.mt.__call(self,x,y)
	local s={x=x,y=y}
	setmetatable(s,Pos2D.mti)
	return s
end

function Pos2D.fromMatrix(m)
	local rows = #m
	local p = Pos2D(m[1][1],m[2][1])
	if rows > 2 then
		p.x = p.x/m[3][1]
		p.y = p.y/m[3][1]
	end
	return p
end

setmetatable(Pos2D,Pos2D.mt)