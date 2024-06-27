from pathlib import Path
from os import listdir
from os.path import getsize
from subprocess import Popen

meshSourceFileNames = listdir("assets/models")
meshSourceFilePaths = []
filesData = []

def stripFileExtension(s):
    return s.split(".")[-2]

for fileName in meshSourceFileNames:
    meshSourceFilePaths.append(Path("assets/models/"+fileName))

    with Popen(["python","internal/OBJparser.py","-i",f"assets/models/{fileName}","-o","assets/meshdata"]) as p:
        pass
    
    with open(f"assets/meshdata/{stripFileExtension(fileName)}.mesh","r") as f:
        filesData.append([line for line in f.readlines()])

freeBytes = 32640 # 32kb in map
insufficientStorage = False

for i,lines in enumerate(filesData):
    with open("assets/meshdata/meshdata.map","wb" if i==0 else "ab") as f:
        for j,line in enumerate(lines):
            if len(line)*0.5 > freeBytes:
                insufficientStorage = True
                break
            f.write( bytes.fromhex(line) )
            freeBytes -= len(line)*0.5
    if insufficientStorage:
        print(f"could not write {stripFileExtension(meshSourceFileNames[j])} to meshdata.map -- insufficient storage!")
        break

# fills rest of unused 32kb with zeroes
with open("assets/meshdata/meshdata.map","ab") as f:
    freeBytes = 32640-getsize("assets/meshdata/meshdata.map")
    f.write(bytes(freeBytes if freeBytes > 0 else 0))