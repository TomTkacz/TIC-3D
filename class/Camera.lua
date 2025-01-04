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
        self.horizontalVector,self.verticalVector = Dir3D(horizontalX,0,horizontalZ),Dir3D(0,1,0)
    end

    function s:isPointInView(p,r)
        if r==nil then r=0 end
        local cameraPos = self.pos
        local clippingPlanes = self.clippingPlanes
        local isInView = true
        local errorMargin = 0.005

        local planeDistFromOrigin = -( clippingPlanes.left.normal:getDotProduct(cameraPos) )
        local signedDistanceToPlane = clippingPlanes.left.normal:getDotProduct(p) + planeDistFromOrigin
        isInView = isInView and signedDistanceToPlane >= -r - errorMargin
        if not isInView then return false end

        local planeDistFromOrigin = -( clippingPlanes.top.normal:getDotProduct(cameraPos) )
        local signedDistanceToPlane = clippingPlanes.top.normal:getDotProduct(p) + planeDistFromOrigin
        isInView = isInView and signedDistanceToPlane >= -r - errorMargin
        if not isInView then return false end

        local planeDistFromOrigin = -( clippingPlanes.right.normal:getDotProduct(cameraPos) )
        local signedDistanceToPlane = clippingPlanes.right.normal:getDotProduct(p) + planeDistFromOrigin
        isInView = isInView and signedDistanceToPlane >= -r - errorMargin
        if not isInView then return false end

        local planeDistFromOrigin = -( clippingPlanes.bottom.normal:getDotProduct(cameraPos) )
        local signedDistanceToPlane = clippingPlanes.bottom.normal:getDotProduct(p) + planeDistFromOrigin
        isInView = isInView and signedDistanceToPlane >= -r - errorMargin
        if not isInView then return false end

        local planeDistFromOrigin = -( clippingPlanes.near.normal:getDotProduct(cameraPos) )
        local signedDistanceToPlane = clippingPlanes.near.normal:getDotProduct(p) + planeDistFromOrigin
        isInView = isInView and signedDistanceToPlane >= -r - errorMargin
        if not isInView then return false end

        return isInView
    end

    setmetatable(s,Camera.mti)

    s:rotate(s.rot)
    s:updateVectors()

    return s

end

setmetatable(Camera,Camera.mt)