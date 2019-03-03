# QuickSort algorithm

## Detailed look at how Quick Sort works

```
 0   1   2   3   4   5  6   7  8
 17  41  5   22  54  6  29  3  13
      ^
     Pivot
```

**Pivot**: The pivot is using to compare every number two, 

<span  style="color: #AE87FA; ">For example: Pivot is:</span>   **22**

```
 0   1   2   3    4      5   6   7   8
 17  6   5   3   [22]   41  54  29  13
 --------------  Pivot  ---------------
 Left Partition         Right Partition 
 X < Pivot              X > Pivot
```

**For example: First item is used for Pivot**

```
0   1   2   3    4  5  6   7   8
17  41  5   22  54  6  29  3  13
^ 
```

**For example: Last item is used for Pivot**


```
0   1   2   3    4  5  6   7   8
17  41  5   22  54  6  29  3   13
                               ^
```
**For example: Or randomly chosen pivots ensure O(nlogn)**

**For example: Middle item as Pivot**

```
0   1   2   3   4  5  6   7   8
17  41  5   22  54  6  29  3   13
                ^
```

**For example: Median of three as Pivot**

```
 0    1   2   3    4    5  6   7    8
[17]  41  5   22  [54]  6  29  3   [13]
 ^                 ^                ^      
```

### Median of three as Pivot

```
 0    1   2   3    4    5  6   7    8
[17]  41  5   22  [54]  6  29  3   [13]
 ^                 ^                ^   
First            Middle            Last   
```

<span  style="font-size:1.5em;font-weight: bold;color: red">`Pivot=17`</span>

```
0     1   2   3    4  5  6   7   8
[17]  41  5   22  54  6  29  3  13
^ 
First
```

```
0    1    2   3   4  5   6   7   8
17  [41]  5   22  54 6   29  3  13
     ^ 
   border
```
```
0    1    2   3   4  5   6   7   8
17  [41]  5   22  54 6   29  3  13
     ^    ^
   border
```

**5 < Pivot?  =>  true  => border and 5 swap**

```
0    1   2    3   4  5   6   7   8
17   5   41   22  54 6   29  3  13
     ^   ^    
   border
```
**both `^` moving forward**

```
0    1   2    3   4  5   6   7   8
17   5   41   22  54 6   29  3  13
         ^    ^  
        border
```

**22 < Pivot?  =>  false**

```
0    1   2    3   4  5   6   7   8
17   5   41   22  54 6   29  3  13
         ^        ^
       border
```

**54 < Pivot?  =>  false**

```
0    1   2    3   4   5   6   7   8
17   5   41   22  54  6   29  3  13
         ^            ^
       border
```

**6 < Pivot?  =>  true  => border and 6 swap position**

```
0    1   2  3   4   5   6   7   8
17   5   6  22  54  41  29  3  13
         ^           ^     
        border       
```
**both `^` moving forward**

```
0    1   2  3   4   5   6   7   8
17   5   6  22  54  41  29  3  13
            ^           ^     
          border       
```


**29 < Pivot?  =>  false**

```
0    1   2  3   4   5   6   7   8
17   5   6  22  54  41  29  3  13
            ^               ^     
           border       
```

**3 < Pivot?  =>  true => border and 3 swap position**

```
0    1   2  3   4   5   6   7   8
17   5   6  3   54  41  29  22  13
            ^                ^     
           border
```
**both `^` moving forward**

```
0    1   2  3   4   5   6   7   8
17   5   6  3   54  41  29  22  13
                ^                ^     
               border
```

**13 < Pivot?  =>  true   =>  border and 13 swap position**

```
0    1   2  3   4   5   6   7   8
17   5   6  3   13  41  29  22  54
                ^                ^     
               border         
```

#### Swap border and  Pivot

```
0    1   2  3     4   5   6   7   8
13   5   6  3   [17]  41  29  22  54
 --------------  Pivot  ---------------
 Left Partition         Right Partition 
 All < Pivot              All > Pivot        
```

### Left: Second round of Median of three


```
0    1   2  3  
13   5   6  3 
^    ^      ^
```

**swap 13 and 5**

```
0    1   2  3  
5   13   6  3 
^
```

<span  style="font-size:1em;font-weight: bold;color: red">`Pivot=5`</span>

```
0    1   2  3  
5   13   6  3 
    ^    ^
   border
```

**6 < Pivot?  =>  false**

```
0    1   2  3  
5   13   6  3 
    ^       ^
   border
```

**3 < Pivot?  =>  true  => 3 and border swap**

```
0   1   2  3  
5   3   6  13 
    ^      ^
   border
```

```
0   1   2  3  
5   3   6  13 
- Pivot -----
L        R  
```

#### Swap border and Pivot

```
0   1   2  3  
3   5   6  13
```

### Right: Second round of Median of three

```
5   6   7   8
41  29  22  54
    ^    ^
  border
```

<span  style="font-size:1em;font-weight: bold;color: red">`Pivot=41`</span>

**22 < Pivot?  =>  true  => 22 and border swap**

```
5   6   7   8
41  22  29  54
    ^    ^
  border
```
**both `^` moving forward**

```
5   6   7   8
41  22  29  54
        ^    ^
      border
```
**54 < Pivot?  =>  false**


**Swap border and Pivot**

```
5   6   7   8
29  22  41  54
- Pivot -----
L        R  
```

**Recursively do the quick with left part until get to the one item**
```
5   6   7   8
22  29  41  54
```

## Quick Sort 

* Quicksort is recursive(method calls itself）
* Divide-and-conquer algorithm 
* **Very efficient for large data sets**
* **Worst case is `O(n²)`**
* **Average case is `O(nlogn)`**
* Performance depends largely on Pivot selection


## Simple Code

```
#---------------------------------------
# Quick Sort
#---------------------------------------
def quick_sort(A):
	quick_sort2(A, 0, len(A)-1)
# quick_sort() is basic a user interface that lists the user just passed down a list 
# Recursive function quicksort passing low index and high index 
	
def quick_sort2(A, low, hi):
# If there are more than one item to be sorted instead of quicksort


	if hi-low < threshold and low < hi:
		quick_selection(A, low, hi)
# Small list, like less than 2o items, we can user selection sort

	elif low < hi:
# If low is than high, partition function which does most work of quicksort function
# And it returns the pivot around the list  
		p = partition(A, low, hi)
		quick_sort2(A, low, p - 1)
		quick_sort2(A, p + 1, hi)
# Recursively call the quick sort function on left side and right side
	
def get_pivot(A, low, hi):
	mid = (hi + low) // 2
# Get mid index, low index and high index
# Compare these and chose middle of those 
	s = sorted([A[low], A[mid], A[hi]])
	if s[1] == A[low]:
		return low
	elif s[1] == A[mid]:
		return mid
	return hi
	
def partition(A, low, hi):
	pivotIndex = get_pivot(A, low, hi)
# Get pivot function return a pivot index for our pivot value
	pivotValue = A[pivotIndex]
	A[pivotIndex], A[low] = A[low], A[pivotIndex]
# Swap the pivot value into the leftmost position of our list
	border = low
# Set border equals to the low item

# Iterate through the list
	for i in range(low, hi+1):
# If the item is less than the pivot value, then swap it with our border value  
		if A[i] < pivotValue:
# All items are below pivot value are going to swapped to the left of the list
			border += 1
			A[i], A[border] = A[border], A[i]
	A[low], A[border] = A[border], A[low]
# After iterating this list, swap low item which is pivot value into the border position 

	return (border)
	
def quick_selection(x, first, last):
	for i in range (first, last):
		minIndex = i
		for j in range (i+1, last+1):
			if x[j] < x[minIndex]:
				minIndex = j
		if minIndex != i:
			x[i], x[minIndex] = x[minIndex], x[i]
			
A = [5,9,1,2,4,8,6,3,7]
print(A)
quick_sort(A)
print(A)
```




