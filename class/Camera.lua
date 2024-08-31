Camera={}
Camera.mt={}
Camera.mti={}

function Camera.mt.__call(self,pos,rot,dir)

    local s={
        pos=pos,
        rot=rot,
        dir=dir,
    }

    function s:rotate(r)
        self.rot=self.rot+r
        self.dir:rotate(r.x,r.y,r.z)
    end

    function s:updateClippingPlanes()

        self.clippingPlanes = {}

        self.clippingPlanes.near = {
            origin=translate3D(self.pos,self.dir,0.25),
            normal=self.dir:copy(),
        }

        self.clippingPlanes.left = {
            origin=self.pos,
            normal=self.dir:copy(),
        }
        self.clippingPlanes.left.normal:rotateAboutAxis(self.verticalVector,-(viewport.fov/2)+(PI_OVER_TWO))

        self.clippingPlanes.right = {
            origin=self.pos,
            normal=self.dir:copy(),
        }
        self.clippingPlanes.right.normal:rotateAboutAxis(self.verticalVector,(viewport.fov/2)-(PI_OVER_TWO))

        self.clippingPlanes.top = {
            origin=self.pos,
            normal=self.dir:copy(),
        }
        self.clippingPlanes.top.normal:rotateAboutAxis(self.horizontalVector,(viewport._vfov/2)-(PI_OVER_TWO))

        self.clippingPlanes.bottom = {
            origin=self.pos,
            normal=self.dir:copy(),
        }
        self.clippingPlanes.bottom.normal:rotateAboutAxis(self.horizontalVector,-(viewport._vfov/2)+(PI_OVER_TWO))

    end

    function s:updateVectors()
        local horizontalVector,verticalVector = self.dir:copy(),self.dir:copy()
        horizontalVector:rotate(0,-PI_OVER_TWO,0) -- points right (will need to fixed if cam points up or down)
        verticalVector:rotateAboutAxis(horizontalVector,PI_OVER_TWO) -- points up
        self.horizontalVector,self.verticalVector = horizontalVector,verticalVector
    end

    function s:isPointInView(p,r)
        if r==nil then r=0 end
        local cameraPos = self.pos
        local clippingPlanes = self.clippingPlanes
        local isInView = true
        local errorMargin = 0.005

        local planeDistFromOrigin = -( clippingPlanes.left.normal:dot(cameraPos) )
        local signedDistanceToPlane = clippingPlanes.left.normal:dot(p) + planeDistFromOrigin
        isInView = isInView and signedDistanceToPlane >= -r - errorMargin
        if not isInView then return false end

        local planeDistFromOrigin = -( clippingPlanes.top.normal:dot(cameraPos) )
        local signedDistanceToPlane = clippingPlanes.top.normal:dot(p) + planeDistFromOrigin
        isInView = isInView and signedDistanceToPlane >= -r - errorMargin
        if not isInView then return false end

        local planeDistFromOrigin = -( clippingPlanes.right.normal:dot(cameraPos) )
        local signedDistanceToPlane = clippingPlanes.right.normal:dot(p) + planeDistFromOrigin
        isInView = isInView and signedDistanceToPlane >= -r - errorMargin
        if not isInView then return false end

        local planeDistFromOrigin = -( clippingPlanes.bottom.normal:dot(cameraPos) )
        local signedDistanceToPlane = clippingPlanes.bottom.normal:dot(p) + planeDistFromOrigin
        isInView = isInView and signedDistanceToPlane >= -r - errorMargin
        if not isInView then return false end

        local planeDistFromOrigin = -( clippingPlanes.near.normal:dot(cameraPos) )
        local signedDistanceToPlane = clippingPlanes.near.normal:dot(p) + planeDistFromOrigin
        isInView = isInView and signedDistanceToPlane >= -r - errorMargin
        if not isInView then return false end

        return isInView
    end

    setmetatable(s,Camera.mti)

    s:rotate(s.rot)

    return s

end

setmetatable(Camera,Camera.mt)