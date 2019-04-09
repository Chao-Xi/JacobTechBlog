import os
import glob
import math
import functools
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

def percentile(List, percent):

	if not List:
		return None

	pos = (len(List)-1)*percent
	floor = math.floor(pos)
	ceil = math.ceil(pos)

	if ceil == floor:
		return List[int(pos)]

	k1 = List[int(floor)] * (ceil - pos)
	k2 = List[int(ceil)] * (pos - floor)

	return k1+k2


if __name__ == '__main__':
	t1 = time.perf_counter()

	log_list = list(lines_to_list("/var/log/httpd/"))
	log_list.sort()

	print(f'90% of requests return a response in {int(percentile(log_list, percent=0.9))} ms')
	print(f'95% of requests return a response in {int(percentile(log_list, percent=0.95))} ms')
	print(f'99% of requests return a response in {int(percentile(log_list, percent=0.99))} ms')

	t2 = time.perf_counter()

	# output memory usage and time usage
	print(f'Memory (After) : {mem_profile.memory_usage_psutil()}MB')
	print(f'Took {t2-t1} Seconds')

