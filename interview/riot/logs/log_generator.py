import numpy as np
import random

num_deck = list(range(1,5001))
random.shuffle(num_deck)

a = np.array(num_deck)
p1 = np.percentile(a, 90)
p2 = np.percentile(a, 95)
p3 = np.percentile(a, 99)

print(a)
print(p1)
print(p2)
print(p3)



import math
import functools

def percentile(N, percent, key=lambda x:x):
    """
    Find the percentile of a list of values.

    @parameter N - is a list of values. Note N MUST BE already sorted.
    @parameter percent - a float value from 0.0 to 1.0.
    @parameter key - optional key function to compute value from each element of N.

    @return - the percentile of the values
    """
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

# median is 50th percentile.
# median = functools.partial(percentile, percent=0.5)

print()

