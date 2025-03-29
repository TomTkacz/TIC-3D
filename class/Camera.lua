Camera={}
Camera.mt={}
Camera.mti={}

function Camera.mt.__call(self,pos,rot,dir)

    local s={
        pos=pos,
        rot=rot,
        dir=dir,
    }

    function s:initalizeClippingPlanes()

        self.clippingPlanes = {

            near={
                origin=WORLD_ORIGIN,
                normalTheta=0,
            },
    
            left={
                origin=WORLD_ORIGIN,
                normalTheta=-(viewport.fov/2)+(PI_OVER_TWO),
            },
    
            right={
                origin=WORLD_ORIGIN,
                normalTheta=(viewport.fov/2)-(PI_OVER_TWO),
            },
    
            top={
                origin=WORLD_ORIGIN,
                normalTheta=(viewport._vfov/2)-(PI_OVER_TWO),
            },
    
            bottom={
                origin=WORLD_ORIGIN,
                normalTheta=-(viewport._vfov/2)+(PI_OVER_TWO)
            },
    
        }

    end

    function s:rotate(r)
        self.rot=self.rot+r
        self.dir:rotate(r.x,r.y,r.z)
    end

    function s:updateClippingPlanes()

        for k,p in pairs(self.clippingPlanes) do
            local rotationAxis = (k=="left" or k=="right") and self.verticalVector or self.horizontalVector
            local normal = self.dir:getCopy()
            normal:rotateAboutAxis(rotationAxis,p.normalTheta)
            self.clippingPlanes[k].normal = normal
            self.clippingPlanes[k].origin = self.pos
        end

    end

    function s:updateVectors()
        local horizontalX,horizontalZ = cosq(PI-self.rot.y),sinq(PI-self.rot.y)
        local hv,vv = self.horizontalVector,self.verticalVector
        if not hv then self.horizontalVector = Dir3D(); hv = self.horizontalVector end
        if not vv then self.verticalVector = Y_AXIS end
        hv.x,hv.y,hv.z = horizontalX,0,horizontalZ
    end

    function s:isPointInView(p,r)
        
        if r==nil then r=0 end
        local errorMargin = 0.005

        for _,plane in pairs(self.clippingPlanes) do
            if getSignedDistToPlane(p,plane) < -r - errorMargin then return false
        end

        return true end

    end

    setmetatable(s,Camera.mti)

    s:rotate(s.rot)
    s:updateVectors()

    return s

end

setmetatable(Camera,Camera.mt)