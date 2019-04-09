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


a = (lines_to_list("/Users/jxi/python/riot/logs/"))
a_list = list(a)
a_list.sort()



"""
    Find the percentile of a list of values.

    @parameter N - is a list of values. Note N MUST BE already sorted.
    @parameter percent - a float value from 0.0 to 1.0.
    @parameter key - optional key function to compute value from each element of N.

    @return - the percentile of the values
 """

def percentile(N, percent, key=lambda x:x):
	
	if not N:
		return None
	k = (len(N)-1) * percent
	f = math.floor(k)
	c = math.ceil(k)
	if f == c:
		return key(N[int(k)])
	d0 = key(N[int(f)]) * (c-k)
	d1 = key(N[int(c)]) * (k-f)

	return d0+d1


print(int(percentile(a_list, percent=0.9)))
print(int(percentile(a_list, percent=0.95)))
print(int(percentile(a_list, percent=0.99)))

