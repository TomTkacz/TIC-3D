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

    function s:updatePlaneDistances()
        self._hPlaneDistance = math.sqrt( viewport._focalDist^2 + (viewport.size.w/2)^2 )
        self._vPlaneDistance = math.sqrt( viewport._focalDist^2 + (viewport.size.h/2)^2 )
    end

    function s:updateClippingPlanes()
        self.clippingPlanes = {}
        --local nearPlane = 
    end

    function s:updateVectors()
        -- local horizontalVector,verticalVector = self.dir,self.dir
        -- horizontalVector:rotate(0,-math.pi/2,0) -- points right (will need to fixed if cam points up or down)
        -- verticalVector:rotateAboutAxis(horizontalVector,math.pi/2) -- points up
        -- self.horizontalVector,self.verticalVector = horizontalVector,verticalVector
    end

    setmetatable(s,Camera.mti)

    s:rotate(s.rot)

    return s

end

setmetatable(Camera,Camera.mt)