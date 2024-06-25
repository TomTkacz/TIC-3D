import re

verticesData=[]
facesData=[]
vertexNormalsData=[]

with open("assets/models/cube.obj","r") as f:
    lines = [line.rstrip() for line in f]
    
def parseVertexLines(line):
    v=[0,0,0]
    for i,s in enumerate(line.split()):
        v[i]=float(s)
    verticesData.append(v)

def parseVertexNormalLines(line):
    vn=[0,0,0]
    for i,s in enumerate(line.split()):
        vn[i]=float(s)
    vertexNormalsData.append(vn)

# sees where to find vertex and vertex normal data via the face format v/#/vn or v//vn or v/vn
# reads from verticesData and vertexNormalsData to construct the face: [ v1=[ x,y,z, vn=[x,y,z] ], v2=[...], v3=[...] ]
def parseFaceLines(line):
    
    f=[]
    
    # given 1/2/3, should only capture 1 and 3 (may break if middle num is >99)
    # given 1//2,  should capture both 1 and 2
    # given 1/2,   should only capture 1
    nums=re.findall(r"[0-9]+(?=//)|(?<=//)[0-9]+|(?<!/)[0-9]+(?=/)|(?<=[/0-9][0-9]/)[0-9]+",line)
    
    for i in range(len(nums)):
        
        # if face is in format v/#/vn or v//vn i.e. len(nums)==6 then navigate nums in pairs
        if not i%2==0 and len(nums)==6:
            continue
        vertexIndex=int(nums[i])-1
        vertexNormalIndex=int(nums[i+1])-1
        
        # if face is in format v/# i.e. len(nums)==3 then there is no vertex normal data to append to vertex
        if len(verticesData[vertexIndex])<=3 and not len(nums)==3:
            verticesData[vertexIndex].append(vertexNormalsData[vertexNormalIndex])
            
        f.append(verticesData[vertexIndex])
        
    facesData.append(f)
        
for line in lines:
    # checks for .obj line prefixes
    prefix=re.findall("^[A-Za-z]+",line)
    if len(prefix) == 0:
        continue
    match prefix[0]:
        case "v":
            parseVertexLines(line[2:])
        case "f":
            parseFaceLines(line[2:])
        case "vn":
            parseVertexNormalLines(line[2:])
            
print(facesData)