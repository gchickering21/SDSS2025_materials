import os

f = open("latex_requirements.txt")
lines = f.readlines()

for line in lines:
    os.system("mpm --install=" + line)
