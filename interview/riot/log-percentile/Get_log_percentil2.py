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
# Two nested loop and allocation of "rtime" inside the loops, so the time&space complexity are both O(n²)

if __name__ == '__main__':
	log_list = list(lines_to_list("/var/log/httpd/"))
	
	print(f'90% of requests return a response in {int(np.percentile(log_list, 90))} ms')
	print(f'95% of requests return a response in {int(np.percentile(log_list, 95))} ms')
	print(f'99% of requests return a response in {int(np.percentile(log_list, 99))} ms')

