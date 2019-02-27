# SelectionSort algorithm

### Detailed look at how Selection Sort works

```
[0]  [1]  [2]  [3]  [4]  [5] 
 7    8    5    4    9    2
```

**`minValue = 7`**

```
7 < 8 ?  yes
7 < 5 ?  false
```
**`minValue = 5`**

```
5 < 4 ?  false
```
**`minValue = 4`**

```
4 < 9 ?  yes
4 < 2 ?  false
```

**`minValue = 2`**

**Swap `2` with first position unsorted part of the list**

```
[0]  [1]  [2]  [3]  [4]  [5] 
(2)   8    5    4    9    7
```

**`minValue = 8`**

```
[0]  [1]  [2]  [3]  [4]  [5] 
(2)   8    5    4    9    7
```

```
8 < 5 ? false
```
**`minValue = 5`**

```
5 < 4 ? false
```

**`minValue = 4`**

```
4 < 9 ? true
4 < 7 ? true
```

**Swap `4` with first position unsorted part of the list**

```
[0]  [1]  [2]  [3]  [4]  [5] 
(2)  (4)   5    8    9    7
```
**`minValue = 5`**

```
5 < 8 ? true
5 < 9 ? true
5 < 7 ? true
```
**`5` in correct position**

```
[0]  [1]  [2]  [3]  [4]  [5] 
(2)  (4)  (5)   8    9    7
```

**`minValue = 8`**

```
8 < 9 ? true
8 < 7 ? false
```
**`minValue = 7`**

**Swap `7` with first position unsorted part of the list**

```
[0]  [1]  [2]  [3]  [4]  [5] 
(2)  (4)  (5)  (7)   9    8
```

**`minValue = 9`**

```
9 < 8 ? false
```
**`minValue = 8`**

**Swap `8` with first position unsorted part of the list**

```
[0]  [1]  [2]  [3]  [4]  [5] 
(2)  (4)  (5)  (7)  (8)   9
```

**[2 4 5 7 8 9]**

* selection Sort is not a fast sorting algorithm because it uses nested loops to sort
* It is useful only for small data sets
* **It run in O(n²)**


## Code

```
#---------------------------------------
# Selection Sort
#---------------------------------------			
def selection_sort(A):
	for i in range (0, len(A) - 1):
		minIndex = i
		for j in range (i+1, len(A)):
			if A[j] < A[minIndex]:
				minIndex = j
		if minIndex != i:
			A[i], A[minIndex] = A[minIndex], A[i]
			
A = [5,9,1,2,4,8,6,3,7]
print(A)
selection_sort(A)
print(A)
```

```
[5, 9, 1, 2, 4, 8, 6, 3, 7]
[1, 2, 3, 4, 5, 6, 7, 8, 9]
```



