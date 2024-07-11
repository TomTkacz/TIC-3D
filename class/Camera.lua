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
        self.clippingPlanes.near = self.dir:canonical()

        self.clippingPlanes.left = self.dir:canonical()
        self.clippingPlanes.left:rotateAboutAxis(self.verticalVector,-(math.rad(viewport.fov)/2)+(math.pi/2))

        self.clippingPlanes.right = self.dir:canonical()
        self.clippingPlanes.right:rotateAboutAxis(self.verticalVector,(math.rad(viewport.fov)/2)-(math.pi/2))

        self.clippingPlanes.top = self.dir:canonical()
        self.clippingPlanes.top:rotateAboutAxis(self.horizontalVector,(viewport._vfov/2)-(math.pi/2))

        self.clippingPlanes.bottom = self.dir:canonical()
        self.clippingPlanes.bottom:rotateAboutAxis(self.horizontalVector,-(viewport._vfov/2)+(math.pi/2))

    end

    function s:updateVectors()
        local horizontalVector,verticalVector = self.dir:canonical(),self.dir:canonical()
        horizontalVector:rotate(0,-math.pi/2,0) -- points right (will need to fixed if cam points up or down)
        verticalVector:rotateAboutAxis(horizontalVector,math.pi/2) -- points up
        self.horizontalVector,self.verticalVector = horizontalVector,verticalVector
    end

    function s:pointIsInView(p)
        local isInView = true

        local planeDistFromOrigin = -( self.clippingPlanes.near:dot(self.pos) )
        isInView = true and self.clippingPlanes.near:dot(p) + planeDistFromOrigin >= 0
        if not isInView then return false end

        planeDistFromOrigin = -( self.clippingPlanes.left:dot(self.pos) )
        isInView = true and self.clippingPlanes.left:dot(p) + planeDistFromOrigin >= 0
        if not isInView then return false end

        planeDistFromOrigin = -( self.clippingPlanes.right:dot(self.pos) )
        isInView = true and self.clippingPlanes.right:dot(p) + planeDistFromOrigin >= 0
        if not isInView then return false end

        planeDistFromOrigin = -( self.clippingPlanes.top:dot(self.pos) )
        isInView = true and self.clippingPlanes.top:dot(p) + planeDistFromOrigin >= 0
        if not isInView then return false end

        planeDistFromOrigin = -( self.clippingPlanes.bottom:dot(self.pos) )
        isInView = true and self.clippingPlanes.bottom:dot(p) + planeDistFromOrigin >= 0
        if not isInView then return false end

        return isInView
    end

    setmetatable(s,Camera.mti)

    s:rotate(s.rot)

    return s

end

setmetatable(Camera,Camera.mt)