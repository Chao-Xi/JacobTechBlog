import os
import glob
import numpy as np
import mem_profile
import time

print(f'Memory (Before): {mem_profile.memory_usage_psutil()} MB')

def lines_to_list(dir):
	os.chdir(dir)
	for filename in glob.iglob("*.log"):
		with open(filename) as f:
			for line in f:
				line = line.strip()
				rtime = int(line.split(' ')[-1])
				yield rtime

if __name__ == '__main__':
	log_list = list(lines_to_list("/var/log/httpd/"))
	t1 = time.perf_counter()

	print(f'90% of requests return a response in {int(np.percentile(log_list, 90))} ms')
	print(f'95% of requests return a response in {int(np.percentile(log_list, 95))} ms')
	print(f'99% of requests return a response in {int(np.percentile(log_list, 99))} ms')

	t2 = time.perf_counter()
	
	# output memory usage and time usage
	print(f'Memory (After) : {mem_profile.memory_usage_psutil()}MB')
	print(f'Took {t2-t1} Seconds')

   
