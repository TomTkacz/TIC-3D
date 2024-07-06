import re
import argparse
from os import listdir
from os.path import getsize

verticesData=[]
facesData=[]
vertexNormalsData=[]
    
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
    
    rawNums=re.split("//|[/\s]",line)
    numOfVertices=len( re.findall("\s",line) ) + 1
    numsPerVertex=len(rawNums)/numOfVertices
    hasNormals = len( re.findall("//",line) ) > 0 or numsPerVertex==3
    
    vertices = []
    normals = []
    
    for i,n in enumerate(rawNums):
        if numsPerVertex > 1:
            if hasNormals and i%numsPerVertex==1:
                normals.append(int(n))
            elif i%numsPerVertex==0:
                vertices.append(int(n))
        else:
            vertices.append(int(n))
        
    for i in range(len(vertices)):

        vertexIndex=vertices[i]-1
        vertexNormalIndex=normals[i]-1
        
        if hasNormals:
            verticesData[vertexIndex].append(vertexNormalsData[vertexNormalIndex])
        
        if numOfVertices==3:
            f.append(verticesData[vertexIndex])
        elif numOfVertices%3==0:
            f.append(verticesData[vertexIndex])
            if (i+1)%numsPerVertex==0:
                facesData.append(f)
                f=[]
                
        
    facesData.append(f)
    
# allocates 24 bits: 1 sign, 20 base (max 1048575), 3 exponent (max 7)
def floatToThreeByteHex(n):
    
    # constants for bit lengths
    BASE_BITS = 20
    EXPONENT_BITS = 3

    # extracting sign
    sign = 0 if n >= 0 else 1
        
    wholeNum = abs(int(n)) # 0
    wholeNumLength = len(str(wholeNum)) if wholeNum > 0 else 0 # 0
    decimalNumString = str(round(abs(n)-wholeNum,7-wholeNumLength)).split(".")[1]
    decimalNumLength = len( decimalNumString ) if int(decimalNumString) > 0 else 0
    decimalNum = int(decimalNumString)
    
    base = wholeNum*(10**decimalNumLength)+decimalNum
    exponent = decimalNumLength
    
    # combine sign, base, and exponent into a single integer
    result = (sign << (BASE_BITS + EXPONENT_BITS)) | (base << EXPONENT_BITS) | exponent

    return result

parser = argparse.ArgumentParser()
parser.add_argument("-i", "--inputfile")
parser.add_argument("-o", "--outputfile")
args = parser.parse_args()

inputFile=""
outputFile=""

if args.inputfile:
    inputFile=args.inputfile
else:
    print("You must enter an input file (-i)")
    exit(1)
    
with open(inputFile,"r") as f:
    
    lines = [line.rstrip() for line in f]
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
    
# if an output file is not provided, name it the same as input file
if args.outputfile:
    try:
        listdir(args.outputfile)
        directory = args.outputfile
        if directory[-1] == "/" or directory[-1] == "\\":
            directory = directory[:-1]
        outputFile = directory + "/" + re.findall(r"([^\/]+)(?=[.])",inputFile)[-1]
    except:
        outputFile = args.outputfile
else:
    outputFile = re.findall(r"([^\/]+)(?=[.])",inputFile)[-1]
    
fileExtension = ".mesh" if outputFile[-5:] != ".mesh" else ""
    
# TODO: check flag to include vertex normals in output file
with open(outputFile+fileExtension,"w") as f:
    lines = []
    for face in facesData:
        for vector in face:
            for i in range(3):
                dec = floatToThreeByteHex(vector[i])
                hx = f"{dec:0{6}X}"
                lines.append(hx)
                
    meshName = re.split(r"[\/]",outputFile)[-1]
    meshName = re.split(r"[.]",meshName)[-2] if len( re.split(r"[.]",meshName) ) > 1 else meshName
                
    lines.insert(0,meshName) # name of mesh
    lines.insert(1,f"{len(facesData):0{2}X}") # number of faces
    lines.insert(2,"00") # flags
    f.writelines(line + "\n" for line in lines)