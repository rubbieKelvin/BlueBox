# this is for updating the .pyproject file for Qt
echo "
import os
import json

projectname = 'bluebox'

data = dict(
    files=[]
)

def getfiles(dir, ignore=[]):
    cont = os.listdir(dir)
    
    for i in cont: 
        if i in ignore: continue 
        rel = os.path.join(dir, i) 
        
        if os.path.isfile(rel):
            data['files'].append(rel)
        elif os.path.isdir(rel):
            getfiles(rel, ignore=ignore)

getfiles('.', ignore=[
    '__pycache__',
    '.git',
    '.writer',
    'run.dev.sh'
])

with open(projectname+'.pyproject', 'w') as file:
    json.dump(data, file, indent=4)

" > .writer

# run the file
python .writer

# delete the file
rm .writer

# run the actual project
fbs run