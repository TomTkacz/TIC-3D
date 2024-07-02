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
    for _,triangle in pairs(mesh.triangles) do
        data={}
        for _,vertex in pairs(triangle) do
            self.origin = self.pos
            local vertexPos = Pos3D(table.unpack(vertex))

            local vModelScaled = vertexPos*self.scale
            local vModelRotated = vModelScaled
            vModelRotated:rotateAboutAxis(Dir3D(1,0,0),self.rot.x)
            vModelRotated:rotateAboutAxis(Dir3D(0,1,0),self.rot.y)
            vModelRotated:rotateAboutAxis(Dir3D(0,0,1),self.rot.z)
            local vWorld = vModelRotated+self.origin
            local vTranslated = vWorld-camera.pos
            -- local vCamera = vTranslated:rotateAboutAxis(-camera.dir,math.pi)
            -- man wtf
            screenPos=worldSpaceToScreenSpace(vWorld)
            table.insert(data,screenPos.x)
            table.insert(data,screenPos.y)
        end
        table.insert(data,12)
        trib(table.unpack(data))
    end
end