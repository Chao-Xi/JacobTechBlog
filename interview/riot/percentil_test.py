import math

def Get_percentile(List, percent):

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


alist = list(range(1,1004))
print(Get_percentile(alist, 0.5))


import numpy as np
print(np.percentile(alist, 50))



