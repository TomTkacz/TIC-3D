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
        self.renderRoutine(self)
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

    -- local function shallowCopyTable(orig)
    --     local copy = {}
    --     for i=1, #orig do
    --         copy[i] = orig[i]
    --     end
    --     return copy
    -- end

    local function getResultantTriangles(verticesTable)

        local resultantTriangles,newBorderVertices = {},{}
        local borderVertices = verticesTable
        local move = table.move
        local abs = math.abs

        for planeIndex=1,#camera.clippingPlanes do

            local plane = camera.clippingPlanes[planeIndex]
            local insertIndex = 1

            for i=1,#borderVertices do

                local v1 = borderVertices[i]
                local v2 = i~=#borderVertices and borderVertices[i+1] or borderVertices[1]

                local closerPointToPlane,furtherPointToPlane = v1,v2
                local signedDistv1ToPlane,signedDistv2ToPlane =  getSignedDistToPlane(v1,plane),getSignedDistToPlane(v2,plane)
                if abs(signedDistv2ToPlane) < abs(signedDistv1ToPlane) then
                    closerPointToPlane = v2
                    furtherPointToPlane = v1
                end

                local intersectionPoint = getVectorPlaneIntersection(furtherPointToPlane,dirBetween3DPoints(furtherPointToPlane,closerPointToPlane),plane)

                if signedDistv2ToPlane >= 0 then
                    if signedDistv1ToPlane < 0 then
                        newBorderVertices[insertIndex] = intersectionPoint
                        insertIndex=insertIndex+1
                    end
                    newBorderVertices[insertIndex] = v2
                    insertIndex=insertIndex+1
                elseif signedDistv1ToPlane >= 0 then
                    newBorderVertices[insertIndex] = intersectionPoint
                    insertIndex=insertIndex+1
                end

            end

            move(newBorderVertices,1,insertIndex-1,1,borderVertices)

        end

        local anchorPoint = borderVertices[1]
        for i=2,#borderVertices-1 do
            table.insert(resultantTriangles,{vertices={ anchorPoint,borderVertices[i],borderVertices[i+1] }})
        end

        return resultantTriangles

    end

    for triangleIndex=1,#mesh.triangles do

        local triangle = mesh.triangles[triangleIndex]
        local triangleVertices = triangle.vertices
        local triangleCenter = triangle.center:toLocalTransform(self.origin,self.rot,self.scale)
        local triangleVertexLocalTransform = triangleVertices[1]:toLocalTransform(self.origin,self.rot,self.scale)
        local triangleBoundingSphereRadius = distBetween3DPoints( triangleCenter, triangleVertexLocalTransform )

        if camera:isPointInView(triangleCenter,triangleBoundingSphereRadius) then

            local resultantTriangles = {}
            resultantTriangles = getResultantTriangles({
                triangleVertexLocalTransform,
                triangleVertices[2]:toLocalTransform(self.origin,self.rot,self.scale),
                triangleVertices[3]:toLocalTransform(self.origin,self.rot,self.scale)
            })

            local triangleScreenValues = {}
            local unpack = table.unpack
            for i=1,#resultantTriangles do

                local t = resultantTriangles[i]
                local insertIndex = 1

                for j=1,3 do
                    local vertex = t.vertices[j]
                    local screenPos = vertex:toCameraTransform():toScreenSpace()
                    triangleScreenValues[insertIndex] = screenPos.x
                    triangleScreenValues[insertIndex+1] = screenPos.y
                    insertIndex=insertIndex+2
                end

                triangleScreenValues[insertIndex] = 1+(triangleIndex%7)
                tri(unpack(triangleScreenValues))
                -- triangleScreenValues[7] = 12
                -- trib(table.unpack(triangleScreenValues))

            end

        end
    end
end