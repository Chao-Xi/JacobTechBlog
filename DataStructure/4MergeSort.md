# MergeSort algorithm

## Simple sort

### 1.

```
  2   4   3   1
```

### 2.



```
  2   4  |  3   1
   /          \
2    4      3    1
```

### 3.

**Inner Sort**

```
2   4   |   1   3
```

### 4.

**Outer Sort**

```
2 > 1
```

**[ 1 ]**

```
2 < 3
```

**[ 1 2 ]**


```
4 > 3
```

**[ 1 2 3 ]**

**[ 1 2 3 4 ]**


## Complicate sort

### 1. Split list

```
 0    1    2   3      4   5   6    7    
 17   87   6   22  |  41  3   13   54
```

```
 0    1    2   3      0   1   2    3    
 17   87   6   22  ||  41  3   13   54
```

```
 17  |  87  ||  6  | 22  ||  41  |  3  ||  13  |  54
```

```
 17  ||  87  ||  6  ||  22  ||  41 || 3  ||  13  ||  54
```

### 2. Inner Sort

```
 17  ||  87  ||  6  ||  22  ||  (3)  ||  (41)  ||  13  ||  54
```

### 3.Merge into left and right side separately

```
 17  |  87  ||  6  | 22  ||  3  |  41  ||  13  |  54
```

#### l. Lift Side 

```
17  87  ||   6   22
^            ^
```
**` 17 > 6 `**

**[ 6 ]**

```
17  87  ||   6   22
^                ^
```

**` 17 < 22 `**

**[  6  17  ]**

```
17  87  ||   6   22
    ^            ^
```

**` 22 < 87 `**

**[  6  17  22 ]**

**[  6  17  22   87  ]**


#### r. Right Side 


```
 3   41  ||  13   54
 ^           ^
```

**` 3 < 13 `**

**[ 3 ]**


```
 3   41  ||  13   54
     ^        ^
```

**` 13 < 41 `**

**[ 3  13 ]**


```
 3   41  ||  13   54
     ^            ^
```

**` 41 < 54 `**

**[ 3  13  41 ]**

**[ 3  13  41 54 ]**


### 4.Merge into left and right side separately

```
 6  17  22   87  ||  3  13  41 54
 ^                   ^
```

`6  >  3`

**[ 3 ]**

```
 6  17  22   87  ||  3  13  41 54
 ^                      ^
```

`6  < 13`

**[ 3 6   ]**

```
 6  17  22   87  ||  3  13  41 54
    ^                   ^
```

`17  > 13`

**[ 3 6 13 ]**

```
 6  17  22   87  ||  3  13  41  54
    ^                       ^
```

`17  <  41`

**[ 3 6 17 ]**

```
 6  17  22   87  ||  3  13  41  54
        ^                   ^
```

`22  <  41`

**[ 3 6 17 22 ]**

```
 6  17  22   87  ||  3  13  41  54
             ^              ^
```

`87  >  41`

**[ 3 6 17 22 41 ]**

```
 6  17  22   87  ||  3  13  41  54
             ^                  ^
```

`87  >  54`

**[ 3 6 17 22 41 54 ]**

**[ 3 6 17 22 41 54 87 ]**

## Merge Sort - Summary

* MergeSort is recursive (method that calls itself)
* Divide and conquer algorithm 
* **Very efficient for large data sets**


## Big O Analysis

* Merge sort does log n merge steps because each merge step **double the list size**
* It does n work for each merge step because it must look at every item
* So it runs in **`O(nlogn)`**


## Code example

```
import sys

def merge_sort(A):
	merge_sort2(A, 0, len(A)-1)

def merge_sort2(A, first, last):
#  In Python 3, they made the / operator do a floating-point division, 
#  and added the // operator to do integer division 
	if first < last:
		middle = (first + last)//2
		merge_sort2(A, first, middle)
		merge_sort2(A, middle+1, last)
		merge(A, first, middle, last)

def merge(A, first, middle, last):
	L = A[first:middle+1]
	R = A[middle+1:last+1]
	L.append(sys.maxsize)  #Reach the end of list
	R.append(sys.maxsize)
	i = j = 0
	#Index i for left half and j for the right half
	#Initialize was 0

	for k in range (first, last+1):
		if L[i] <= R[j]:
			A[k] = L[i]
			i += 1
		else:
			A[k] = R[j]
			j += 1

A = [5,9,1,2,4,8,6,3,7]
print(A)
merge_sort(A)
print(A)
```

**A(k)**  `| 1 | 5 | 6 | 2 | 7 |`

**L(i)**  `| 1 | 5 | 6 | sys.maxsize |`

**R(j)**  `| 2 | 7 | 9 | sys.maxsize |`          

```
[5, 9, 1, 2, 4, 8, 6, 3, 7]
[1, 2, 3, 4, 5, 6, 7, 8, 9]
```