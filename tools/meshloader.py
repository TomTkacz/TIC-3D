from pathlib import Path
from os import listdir
from subprocess import Popen,STDOUT

sourceFileNames = listdir("assets/models")
sourceFilePaths = []

for fileName in sourceFileNames:
    sourceFilePaths.append(Path(fileName))
    # with Popen(["python","tools/meshloader.py"]) as p:
    #     pass

with Popen(["python","tools/OBJparser.py","-i",f"assets/models/{sourceFileNames[0]}","-o","assets/meshdata"]) as p:
    pass

### UNDER CONSTRUCTION ###