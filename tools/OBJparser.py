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
    
    # given 1/2/3, should only capture 1 and 3
    # given 1//2,  should capture both 1 and 2
    # given 1/2,   should only capture 1
    rawNums=re.split("[/\s]",line)
    indices = [0,2,3,5,6,8]
    nums = []
    for i in indices:
        nums.append(rawNums[i])
    
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
    
# allocates 24 bits: 1 sign, 20 base (max 1048575), 3 exponent (max 7)
def floatToThreeByteHex(n):
    
    # constants for bit lengths
    BASE_BITS = 20
    EXPONENT_BITS = 3

    # extracting sign
    sign = 0 if n >= 0 else 1
        
    wholeNum = abs(int(n))
    wholeNumLength = len(str(wholeNum)) if wholeNum > 0 else 0
    decimalNum = int(str(round(abs(n)-wholeNum,7-wholeNumLength)).split(".")[1])
    decimalNumLength = len(str(decimalNum)) if decimalNum > 0 else 0
        
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
    
fileExtension = ".map" if outputFile[-5:] != ".map" else ""

# TODO: check flag to include vertex normals in output file
with open(outputFile+fileExtension,"wb") as f:
    
    f.write( bytes.fromhex( f"{len(facesData):0{2}X}" ) ) # number of faces
    f.write( bytes.fromhex("00") ) # flags
    
    for face in facesData:
        for vector in face:
            for i in range(3):
                dec = floatToThreeByteHex(vector[i])
                hx = f"{dec:0{6}X}"
                f.write( bytes.fromhex(hx) )

with open(outputFile+fileExtension,"ab") as f:
    f.write(bytes(32640-getsize(outputFile+fileExtension)))