Object3D={}
Object3D.mt={}
Object3D.mti={}
Object3D._inits={}
Object3D._hitChecks={}
Object3D._renderRoutines={}

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

function Object3D._inits.mesh(meshID,pos)
    local mesh = scene.loadedObjects[meshID]
    return {meshID=meshID,pos=pos,origin=mesh.origin,numberOfTriangles=mesh.numberOfTriangles}
end

function Object3D._renderRoutines.mesh(self)
    mesh = scene.loadedObjects[self.meshID]
    mesh.origin=self.pos

    for _,triangle in pairs(mesh.triangles) do
        data={}
        for _,vertex in pairs(triangle) do
            vertexPos = Pos3D(table.unpack(vertex))
            screenPos=worldSpaceToScreenSpace(vertexPos+self.origin)
            table.insert(data,screenPos.x)
            table.insert(data,screenPos.y)
        end
        table.insert(data,12)
        trib(table.unpack(data))
    end
end