from contextlib2 import contextmanager
import os
import glob
import numpy as np


@contextmanager
def change_dir(destination):
	try:
		cwd = os.getcwd()
		os.chdir(destination)
		yield
	finally:
		os.chdir(cwd)


# def list_contents(dir):
# 	with change_dir(dir):
# 		for file in glob.iglob("*.log"):
# 			with open(file) as f:
# 				for line in 
# 		return a




def lines_to_list(filename):
	with open(filename) as f:
		for line in f:
			line = line.strip()
			rtime = int(line.split(' ')[-1])
			yield rtime


a = (lines_to_list("/Users/jxi/python/riot/logs/2018-13-11.log"))
a_list = list(a)
p1 = int(np.percentile(a_list, 90))
p2 = int(np.percentile(a_list, 95))
p3 = int(np.percentile(a_list, 99))
print(p1)
print(p2)
print(p3)
# def list_files(dir):
# 	with change_dir(dir):
# 		for files in glob.iglob("*.log"):
# 			yield files

# def list_content(dir):
# 	for file in list_lines(dir):
# 	with open(file) in file:



# dir="/Users/jxi/python/riot/logs"

	# 	for file in files:
	# 		with open(file) as f:
	# 			a = f.read()

	# return a


# if __name__ == "__main__":
# 	for file in list_lines("/Users/jxi/python/riot/logs"):
# 		print(a)

