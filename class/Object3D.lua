Object3D={}
Object3D.mt={}
Object3D.mti={}
Object3D._inits={}
Object3D._hitChecks={}
Object3D._renderRoutines={}

---@param type string
function Object3D.mt.__call(self,type,...)

    local s={}
    s=Object3D._inits[type](...)
    s.type=type
    s.hasCustomRenderRoutine = Object3D._renderRoutines[type] ~= nil

    function s:render()
        return Object3D._renderRoutines[self.type](self)
    end

    setmetatable(s,Object3D.mti)
    table.insert(scene.activeObjects,s)
    return #scene.activeObjects

end
setmetatable(Object3D,Object3D.mt)

-- MESH --

function Object3D._inits.mesh(meshID,pos,rot,dir,scale)
    local mesh = scene.loadedObjects[meshID]
    return {
        meshID=mesh.meshID,
        pos=pos,
        rot=rot,
        dir=dir,
        scale=scale,
        origin=mesh.origin,
        numberOfTriangles=mesh.numberOfTriangles
    }
end

function Object3D._renderRoutines.mesh(self)
    local mesh = scene.loadedObjects[self.meshID]
    self.origin = self.pos

    for i,triangle in pairs(mesh.triangles) do
        data={}
        for _,vertex in ipairs(triangle) do
            self.origin = self.pos
            local vertexPos = Pos3D(table.unpack(vertex))

            -- scale mesh
            vertexPos:scale(self.scale,self.scale,self.scale)

            -- translate/rotate mesh about its origin
            vertexPos:rotateAboutAxis(Dir3D(1,0,0),self.rot.x)
            vertexPos:rotateAboutAxis(Dir3D(0,1,0),self.rot.y)
            vertexPos:rotateAboutAxis(Dir3D(0,0,1),self.rot.z)
            vertexPos:translate(self.origin.x,self.origin.y,self.origin.z)

            local color = 12
            local pVisible = camera:pointIsInView(vertexPos)
            if not pVisible then color = 0 end

            -- translate/rotate mesh about the camera
            vertexPos:translate(-camera.pos.x,-camera.pos.y,-camera.pos.z)
            vertexPos:rotateAboutAxis(Dir3D(1,0,0),-camera.rot.x)
            vertexPos:rotateAboutAxis(Dir3D(0,1,0),math.pi-camera.rot.y)
            vertexPos:rotateAboutAxis(Dir3D(0,0,1),-camera.rot.z)

            -- project 3D position to screen space
            local screenPos = worldSpaceToScreenSpace(vertexPos)

            table.insert(data,screenPos.x)
            table.insert(data,screenPos.y)
            circ(screenPos.x,screenPos.y,1,color)
            line(0,0,0,150,8)
            line(SCREEN_WIDTH-1,0,SCREEN_WIDTH-1,150,8)
        end

        table.insert(data,(i%11)+1)
        --tri(table.unpack(data))
    end
end