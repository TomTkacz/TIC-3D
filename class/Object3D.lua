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

    -- takes a triangle object (table with "vertices" key that contains 3 Pos3D objects) and returns two tables:
    -- one containing tables with keys "vertex" and "plane" for storing the vertex outside of one or more viewing planes (Pos3D) and that plane
    -- and another containing vertices inside all the viewing planes
    local function sortTriangleVerticesByPlaneClipping(tri,origin,rot,scale)

        local clippedVertexPlanePairs = {}
        local unclippedVertices = {}
        local transform = origin ~= nil

        for vertexIndex=1,3 do

            local vertex = tri.vertices[vertexIndex]:copy()
            local vertexLocalTransformPos = vertex
            if transform then vertexLocalTransformPos = vertex:toLocalTransform(origin,rot,scale) end
            
            local pointInView,planes = camera:isPointInView(vertexLocalTransformPos)
            
            if pointInView then
                table.insert(unclippedVertices,vertexLocalTransformPos)
            else
                local clipsNearPlane = false
                local planeIndex = 2
                for i,plane in ipairs(planes) do
                    if plane == "near" then
                        clipsNearPlane = true
                        break
                    end
                    planeIndex = i
                end
                table.insert(clippedVertexPlanePairs,{vertex=vertexLocalTransformPos,plane=planes[planeIndex],clipsNearPlane=clipsNearPlane})
            end

        end

        return clippedVertexPlanePairs,unclippedVertices

    end

    local function getResultantTriangles(clippedVertexPlanePairs,unclippedVertices)

        -- if #clippedVertexPlanePairs ~= 0 then
        --     local clippingNear = false
        --     for _,v in pairs(clippedVertexPlanePairs) do
        --         if v.clipsNearPlane then
        --             clippingNear = true
        --             break
        --         end
        --     end
        --     if clippingNear then
        --         trace("---")
        --         trace("clips near!")
        --     end
        -- end

        local result = {}

        if #clippedVertexPlanePairs == 0 then

            return { {vertices=unclippedVertices} }

        elseif #clippedVertexPlanePairs == 1 then

            local tri1,tri2={vertices={}},{vertices={}}

            tri1.vertices[1] = unclippedVertices[1]
            tri1.vertices[2] = unclippedVertices[2]
            tri1.vertices[3] = getVectorPlaneIntersection( unclippedVertices[1], dirBetween3DPoints(unclippedVertices[1], clippedVertexPlanePairs[1].vertex), camera.clippingPlanes[clippedVertexPlanePairs[1].plane] )
            tri2.vertices[1] = tri1.vertices[3]
            tri2.vertices[2] = unclippedVertices[2]
            tri2.vertices[3] = getVectorPlaneIntersection( unclippedVertices[2], dirBetween3DPoints(unclippedVertices[2], clippedVertexPlanePairs[1].vertex), camera.clippingPlanes[clippedVertexPlanePairs[1].plane] )
            
            local tri1Clipped,tri1Unclipped = sortTriangleVerticesByPlaneClipping(tri1)
            local tri1Absolute = {}
            if #tri1Clipped > 0 then
                tri1Absolute = getResultantTriangles(tri1Clipped,tri1Unclipped)
                for _,v in pairs(tri1Absolute) do
                    table.insert(result,v)
                end
            else
                table.insert(result,tri1)
            end

            local tri2Clipped,tri2Unclipped = sortTriangleVerticesByPlaneClipping(tri2)
            local tri2Absolute = {}
            if #tri2Clipped > 0 then
                tri2Absolute = getResultantTriangles(tri2Clipped,tri2Unclipped)
                for _,v in pairs(tri2Absolute) do
                    table.insert(result,v)
                end
            else
                table.insert(result,tri2)
            end
            
        elseif #clippedVertexPlanePairs == 2 then

            local t={vertices={}}

            t.vertices[1] = unclippedVertices[1]
            t.vertices[2] = getVectorPlaneIntersection( t.vertices[1], dirBetween3DPoints(t.vertices[1],clippedVertexPlanePairs[1].vertex), camera.clippingPlanes[clippedVertexPlanePairs[1].plane] )
            t.vertices[3] = getVectorPlaneIntersection( t.vertices[1], dirBetween3DPoints(t.vertices[1],clippedVertexPlanePairs[2].vertex), camera.clippingPlanes[clippedVertexPlanePairs[2].plane] )

            if clippedVertexPlanePairs[1].plane ~= clippedVertexPlanePairs[2].plane then
                local t1,t2 = {vertices={}},{vertices={}}
                t1.vertices[1] = getVectorPlaneIntersection( clippedVertexPlanePairs[1].vertex, dirBetween3DPoints(clippedVertexPlanePairs[1].vertex,clippedVertexPlanePairs[2].vertex), camera.clippingPlanes[clippedVertexPlanePairs[1].plane] )
                t1.vertices[2] = getVectorPlaneIntersection( clippedVertexPlanePairs[2].vertex, dirBetween3DPoints(clippedVertexPlanePairs[2].vertex,clippedVertexPlanePairs[1].vertex), camera.clippingPlanes[clippedVertexPlanePairs[2].plane] )
                t1.vertices[3] = t.vertices[2]
                t2.vertices[1] = t1.vertices[2]
                t2.vertices[2] = t.vertices[2]
                t2.vertices[3] = t.vertices[3]
                table.insert(result,t1)
                table.insert(result,t2)
            end

            local tClipped,tUnclipped = sortTriangleVerticesByPlaneClipping(t)
            local tAbsolute = {}
            if #tClipped > 0 then
                tAbsolute = getResultantTriangles(tClipped,tUnclipped)
                for _,v in pairs(tAbsolute) do
                    table.insert(result,v)
                end
            else
                table.insert(result,t)
            end

        elseif #clippedVertexPlanePairs == 3 then
            
            local p1,p2,p3 = clippedVertexPlanePairs[1].vertex,clippedVertexPlanePairs[2].vertex,clippedVertexPlanePairs[3].vertex
            local plane1,plane2,plane3 = clippedVertexPlanePairs[1].plane,clippedVertexPlanePairs[2].plane,clippedVertexPlanePairs[3].plane
            if plane1 ~= plane2 or plane2 ~= plane3 then
                if plane1 == plane2 then
                    -- local t1,t2 = {vertices={}},{vertices={}}
                    -- t1.vertices[1] = getVectorPlaneIntersection( p1, dirBetween3DPoints(p1,p3), camera.clippingPlanes[plane1] )
                    -- t1.vertices[2] = getVectorPlaneIntersection( p2, dirBetween3DPoints(p2,p3), camera.clippingPlanes[plane1] )
                    -- t1.vertices[3] = getVectorPlaneIntersection( p2, dirBetween3DPoints(p2,p3), camera.clippingPlanes[plane3] )
                    -- t2.vertices[1] = t1.vertices[1]
                    -- t2.vertices[2] = t1.vertices[3]
                    -- t2.vertices[3] = getVectorPlaneIntersection( p1, dirBetween3DPoints(p1,p3), camera.clippingPlanes[plane3] )
                    -- table.insert(result,t1)
                    -- table.insert(result,t2)
                elseif plane2 == plane3 then
                    -- TODO
                else
                    -- local t1,t2,t3,t4 = {vertices={}},{vertices={}},{vertices={}},{vertices={}}
                    -- t1.vertices[1] = getVectorPlaneIntersection( p1, dirBetween3DPoints(p1,p2), camera.clippingPlanes[plane1] )
                    -- t1.vertices[2] = getVectorPlaneIntersection( p1, dirBetween3DPoints(p1,p2), camera.clippingPlanes[plane2] )
                    -- t1.vertices[3] = getVectorPlaneIntersection( p1, dirBetween3DPoints(p1,p3), camera.clippingPlanes[plane1] ) --
                    -- t2.vertices[1] = t1.vertices[2]
                    -- t2.vertices[2] = t1.vertices[3] --
                    -- t2.vertices[3] = getVectorPlaneIntersection( p1, dirBetween3DPoints(p1,p3), camera.clippingPlanes[plane3] ) --
                    -- t3.vertices[1] = t1.vertices[2]
                    -- t3.vertices[2] = t2.vertices[3] --
                    -- t3.vertices[3] = getVectorPlaneIntersection( p2, dirBetween3DPoints(p2,p3), camera.clippingPlanes[plane2] )
                    -- t4.vertices[1] = t3.vertices[3]
                    -- t4.vertices[2] = t2.vertices[3] --
                    -- t4.vertices[3] = getVectorPlaneIntersection( p2, dirBetween3DPoints(p2,p3), camera.clippingPlanes[plane3] )
                    -- table.insert(result,t1)
                    -- table.insert(result,t2)
                    -- table.insert(result,t3)
                    -- table.insert(result,t4)
                end
            end

        end

        return result

    end

    for triangleIndex,triangle in ipairs(mesh.triangles) do

        local triangleCenter = triangle.center:toLocalTransform(self.origin,self.rot,self.scale)
        local triangleBoundingSphereRadius = distBetween3DPoints( triangleCenter, triangle.vertices[1]:toLocalTransform(self.origin,self.rot,self.scale) )

        if camera:isPointInView(triangleCenter,triangleBoundingSphereRadius) then

            local resultantTriangles = {}
            if triangleIndex == 12 then
                resultantTriangles = getResultantTriangles( sortTriangleVerticesByPlaneClipping(triangle,self.origin,self.rot,self.scale) )
            end

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