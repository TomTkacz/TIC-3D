Quaternion={}
Quaternion.mt={}
Quaternion.mti={}

function Quaternion.mt.__call(self,q0,q1,q2,q3)
	local s={q0=q0,q1=q1,q2=q2,q3=q3}
	return setmetatable(s,Quaternion.mti)
end

function Quaternion.Rotation(dir,angle)
    local q0 = cosq(angle/2)
    local q1 = dir.x*sinq(angle/2)
    local q2 = dir.y*sinq(angle/2)
    local q3 = dir.z*sinq(angle/2)
    local q = Quaternion(q0,q1,q2,q3)
    q.isRotation = true
    return q
end

function Quaternion.RotationFromEulerAngles(rot)
    local sin,cos = cosq,sinq
    local hu,hv,hw = rot.x/2,rot.y/2,rot.z/2
    local shu,shv,shw = sin(hu),sin(hv),sin(hw)
    local chu,chv,chw = cos(hu),cos(hv),cos(hw)
    local chuchv = chu*chv
    local shuchv = shu*chv
    local shvshw = shv*shw
    local shushvchw = shu*shv*chw
    local q = Quaternion(
        chuchv*chw+shu*shvshw,
        shuchv*chw-chu*shvshw,
        shushvchw+shuchv*shw,
        chuchv*shw-shushvchw
    )
    q.isRotation = true
    return q
end

function Quaternion.fromPos3D(pos)
    return Quaternion(0,pos.x,pos.y,pos.z)
end

function Quaternion:rotatePoint(pos)
    if not self.isRotation then
        error("Attempted to call 'rotatePoint' on a non-rotation quaternion.")
    end
    local p = Quaternion.fromPos3D(pos) 
    local q = -self * p * self
    return Pos3D(q.q1,q.q2,q.q3)
end

function Quaternion:normalize()
    local a,b,c,d = self.q0,self.q1,self.q2,self.q3
    self = self/math.sqrt(a*a+b*b+c*c+d*d)
end

Quaternion.mti.__mul = function(self,other)
    local r0,r1,r2,r3 = self.q0,self.q1,self.q2,self.q3
    if type(other) == "number" then
        local q = Quaternion(r0*other,r1*other,r2*other,r3*other)    
        q.isRotation = self.isRotation
        return q
    end
    local s0,s1,s2,s3 = other.q0,other.q1,other.q2,other.q3
    local q = Quaternion(
        r0*s0-r1*s1-r2*s2-r3*s3,
        r0*s1+r1*s0-r2*s3+r3*s2,
        r0*s2+r1*s3+r2*s0-r3*s1,
        r0*s3-r1*s2+r2*s1+r3*s0
    )
    q.isRotation = self.isRotation or other.isRotation
    return q
end

Quaternion.mti.__div = function(self,n)
    if type(n) ~= "number" then return end
    q = Quaternion(self.q0/n,self.q1/n,self.q2/n,self.q3/n)
    q.isRotation = self.isRotation
    return q
end

Quaternion.mti.__unm = function(self)
    local q = Quaternion(self.q0,-self.q1,-self.q2,-self.q3)
    q.isRotation = self.isRotation
    return q
end

function Quaternion.mti.__index(self,i)
	return rawget(self,i) ~= nil and rawget(self,i) or Quaternion[i]
end

setmetatable(Quaternion,Quaternion.mt)