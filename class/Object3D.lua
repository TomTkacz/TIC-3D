Object3D={}
Object3D.mt={}
Object3D.mti={}
Object3D._inits={}
Object3D._hitChecks={}

function Object3D.mt.__call(self,type,...)

    trace("wow")
    local s=Object3D._inits[type](table.unpack(args))
    s.type=type
    
    function s:getHitPoint(ray)
        return Object3D._hitChecks[self.type](self,ray)
    end

    setmetatable(s,Object3D.mti)
    return s

end
setmetatable(Object3D,Object3D.mt)

-- SPHERE --

function Object3D._inits.sphere(self,pos,radius)
    return {pos=pos,r=radius}
end

function Object3D._hitChecks.sphere(self,ray)
    local r=ray
    local co=r.pos-sphere.pos
	local a=r.dir:dot(r.dir)
	local b=2*co:dot(r.dir)
	local c=co:dot(co)-(sphere.r*sphere.r)
	local disc=(b*b)-4*a*c
	if disc<0 then
		screen.pixels[y][x]=0
		return
	end
	local hit1=(-b+math.sqrt(disc))/(2*a)
	local hit2=(-b-math.sqrt(disc))/(2*a)
	local hit=-1
	if hit2<0 or (hit1>=0 and hit1<hit2) then hit=hit1 end
	if hit1<0 or (hit2>=0 and hit2<hit1) then hit=hit2 end
    return hit
end

-- TRIANGLE --

function Object3D._inits.triangle(self,pos1,pos2,pos3,rot)

end

function Object3D._hitChecks.triangle(self)

end