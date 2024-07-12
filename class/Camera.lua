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
        self.clippingPlanes.near = self.dir:copy()

        self.clippingPlanes.left = self.dir:copy()
        self.clippingPlanes.left:rotateAboutAxis(self.verticalVector,-(viewport.fov/2)+(math.pi/2))

        self.clippingPlanes.right = self.dir:copy()
        self.clippingPlanes.right:rotateAboutAxis(self.verticalVector,(viewport.fov/2)-(math.pi/2))

        self.clippingPlanes.top = self.dir:copy()
        self.clippingPlanes.top:rotateAboutAxis(self.horizontalVector,(viewport._vfov/2)-(math.pi/2))

        self.clippingPlanes.bottom = self.dir:copy()
        self.clippingPlanes.bottom:rotateAboutAxis(self.horizontalVector,-(viewport._vfov/2)+(math.pi/2))

    end

    function s:updateVectors()
        local horizontalVector,verticalVector = self.dir:copy(),self.dir:copy()
        horizontalVector:rotate(0,-math.pi/2,0) -- points right (will need to fixed if cam points up or down)
        verticalVector:rotateAboutAxis(horizontalVector,math.pi/2) -- points up
        self.horizontalVector,self.verticalVector = horizontalVector,verticalVector
    end

    function s:isPointInView(p,r)
        if r==nil then r=0 end
        local cameraPos = self.pos
        local clippingPlanes = self.clippingPlanes
        local isInView = true

        local planeDistFromOrigin = -( clippingPlanes.near:dot(cameraPos) )
        isInView = true and clippingPlanes.near:dot(p) + planeDistFromOrigin >= -r
        if not isInView then return false end

        planeDistFromOrigin = -( clippingPlanes.left:dot(cameraPos) )
        isInView = true and clippingPlanes.left:dot(p) + planeDistFromOrigin >= -r
        if not isInView then return false end

        planeDistFromOrigin = -( clippingPlanes.right:dot(cameraPos) )
        isInView = true and clippingPlanes.right:dot(p) + planeDistFromOrigin >= -r
        if not isInView then return false end

        planeDistFromOrigin = -( clippingPlanes.top:dot(cameraPos) )
        isInView = true and clippingPlanes.top:dot(p) + planeDistFromOrigin >= -r
        if not isInView then return false end

        planeDistFromOrigin = -( clippingPlanes.bottom:dot(cameraPos) )
        isInView = true and clippingPlanes.bottom:dot(p) + planeDistFromOrigin >= -r
        if not isInView then return false end

        return isInView
    end

    setmetatable(s,Camera.mti)

    s:rotate(s.rot)

    return s

end

setmetatable(Camera,Camera.mt)