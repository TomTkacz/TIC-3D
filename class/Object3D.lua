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

        -- local triangleCenter = ( Pos3D(table.unpack(triangle[1])) + Pos3D(table.unpack(triangle[2])) + Pos3D(table.unpack(triangle[3])) ) / 3
        -- local clippingSphereRadius = distBetween3DPoints(triangleCenter,Pos3D(table.unpack(triangle[1])))
        -- local centerPos = triangleCenter:getScreenPos(self.origin,self.rot,self.scale)
        
        local triangleIsVisible = true

        for _,vertex in ipairs(triangle) do

            local vertexPos = Pos3D(table.unpack(vertex))
            local vertexLocalTransformPos = vertexPos:toLocalTransform(self.origin,self.rot,self.scale)
            if not camera:isPointInView(vertexLocalTransformPos) then triangleIsVisible = false end
            local vertexCamPos = vertexLocalTransformPos:toCameraTransform()
            local screenPos = worldSpaceToScreenSpace(vertexCamPos)

            table.insert(data,screenPos.x)
            table.insert(data,screenPos.y)

        end

        if triangleIsVisible then
            table.insert(data,(i%11)+1)
            tri(table.unpack(data))
            --circ(centerPos.x,centerPos.y,3,12)
        end
    end
end