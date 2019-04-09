import os
import glob
import numpy as np

def lines_to_list(dir):
	os.chdir(dir)
	for filename in glob.iglob("*.log"):
		with open(filename) as f:
			for line in f:
				line = line.strip()
				rtime = int(line.split(' ')[-1])
				yield rtime



if __name__ == '__main__':
	a = (lines_to_list("/Users/jxi/python/riot/logs/"))
	a_list = list(a)
	p1 = int(np.percentile(a_list, 90))
	p2 = int(np.percentile(a_list, 95))
	p3 = int(np.percentile(a_list, 99))
	print(p1)
	print(p2)
	print(p3)		

