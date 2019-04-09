import os
import glob
import math
import functools

def lines_to_list(dir):
	os.chdir(dir)
	for filename in glob.iglob("*.log"):
		with open(filename) as f:
			for line in f:
				line = line.strip()
				rtime = int(line.split(' ')[-1])
				yield rtime

# Two nested loop and allocation of "rtime" inside the loops, so the time&space complexity are both O(n²)


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
# Simple algorithmic operation, so the time&space complexity are both O(1)


if __name__ == '__main__':

	log_list = list(lines_to_list("/var/log/httpd/"))     
	log_list.sort()
	# Python built-in Timsort is  the fastest sort to deal with random ordered and many duplicates list
    # The time complexity is n and space complexity is also n

	print(f'90% of requests return a response in {int(percentile(log_list, percent=0.9))} ms')
	print(f'95% of requests return a response in {int(percentile(log_list, percent=0.95))} ms')
	print(f'99% of requests return a response in {int(percentile(log_list, percent=0.99))} ms')
    
    # The total time and space complexity are both O(n²) + n * O(1) = O(n²) 






