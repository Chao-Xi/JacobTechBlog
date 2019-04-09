import glob
for file in glob.iglob("*.log"):
    with open(file) as f:
        a = f.read()

        
print(a)