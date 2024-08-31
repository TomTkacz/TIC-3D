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
    if s.hasCustomRenderRoutine then s.renderRoutine = Object3D._renderRoutines[s.type] end

    function s:render()
        return self.renderRoutine(self)
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

    local function shallowCopyTable(orig)
        local copy = {}
        for i, orig_value in ipairs(orig) do
            copy[i] = orig_value
        end
        return copy
    end

    local function getResultantTriangles(verticesTable)

        local resultantTriangles,newBorderVertices = {},{}
        local borderVertices = verticesTable
        local getSignedDistToPlane = getSignedDistToPlane
        local getVectorPlaneIntersection = getVectorPlaneIntersection
        local dirBetween3DPoints = dirBetween3DPoints

        for _,plane in pairs(camera.clippingPlanes) do

            for i,v1 in ipairs(borderVertices) do

                local v2 = nil
                if i~=#borderVertices then v2=borderVertices[i+1] else v2=borderVertices[1] end

                local closerPointToPlane,furtherPointToPlane = v1,v2
                local signedDistv1ToPlane,signedDistv2ToPlane =  getSignedDistToPlane(v1,plane),getSignedDistToPlane(v2,plane)
                if signedDistv2ToPlane < signedDistv1ToPlane then
                    closerPointToPlane = v2
                    furtherPointToPlane = v1
                end

                local intersectionPoint = getVectorPlaneIntersection(furtherPointToPlane,dirBetween3DPoints(furtherPointToPlane,closerPointToPlane),plane)

                if signedDistv2ToPlane >= 0 then
                    if signedDistv1ToPlane < 0 then
                        table.insert(newBorderVertices,intersectionPoint)
                    end
                    table.insert(newBorderVertices,v2)
                elseif signedDistv1ToPlane >= 0 then
                    table.insert(newBorderVertices,intersectionPoint)
                end

            end

            borderVertices = shallowCopyTable(newBorderVertices)
            newBorderVertices = {}

        end

        local anchorPoint = borderVertices[1]
        for i=2,#borderVertices-1 do
            table.insert(resultantTriangles,{vertices={ anchorPoint,borderVertices[i],borderVertices[i+1] }})
        end

        return resultantTriangles

    end

    for triangleIndex,triangle in ipairs(mesh.triangles) do

        local triangleCenter = triangle.center:toLocalTransform(self.origin,self.rot,self.scale)
        local triangleVertexLocalTransform = triangle.vertices[1]:toLocalTransform(self.origin,self.rot,self.scale)
        local triangleBoundingSphereRadius = distBetween3DPoints( triangleCenter, triangleVertexLocalTransform )

        if camera:isPointInView(triangleCenter,triangleBoundingSphereRadius) then

            local resultantTriangles = {}
            resultantTriangles = getResultantTriangles({triangleVertexLocalTransform,triangle.vertices[2]:toLocalTransform(self.origin,self.rot,self.scale),triangle.vertices[3]:toLocalTransform(self.origin,self.rot,self.scale)})

            for _,t in pairs(resultantTriangles) do

                local triangleScreenValues = {}

                for _,vertex in pairs(t.vertices) do
                    local screenPos = worldSpaceToScreenSpace(vertex:toCameraTransform())
                    table.insert(triangleScreenValues,screenPos.x)
                    table.insert(triangleScreenValues,screenPos.y)
                end

                table.insert(triangleScreenValues,1+(triangleIndex%7))
                tri(table.unpack(triangleScreenValues))
                triangleScreenValues[7] = 12
                trib(table.unpack(triangleScreenValues))

            end

        end
    end
end