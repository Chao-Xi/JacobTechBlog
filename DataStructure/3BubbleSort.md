# BubbleSort algorithm

```
3  2  4  1
^  ^
```

```
3 < 2 ?  false
```

```
2  3  4  1
   ^  ^
```
```
3 < 4 ?  true
```
```
2  3  4  1
      ^  ^
```
```
4 < 1 ?  false
```

```
2  3  1  4
^  ^
```
```
2 < 3 ? true
```

```
2  3  1  4
   ^  ^
```

```
3 < 1 ? false
```

```
2  1  3  4
      ^  ^
```
```
3 < 4 ? true
```
```
2  1  3  4
^  ^
```
```
2 < 1 ? false
```
```
1  2  3  4
```

* Worst complexity:  `O(n²)`
* Average complexity: `O(n²)`
* Best complexity: `O(n)`
* Space complexity: `O(1)`

```
Outer Loop: i = 0 to n-1
	Inner Loop: j=0 to n-1-i
```

## Code example

### not optimized	

```	
def bubble_sort1(A):
	for i in range (0, len(A) - 1):
		for j in range (0, len(A) - i - 1):
			if A[j] > A[j+1]:
				A[j], A[j+1] = A[j+1], A[j]

A = [5,9,1,2,4,8,6,3,7]
print(A)
bubble_sort1(A)
print(A)

> [5, 9, 1, 2, 4, 8, 6, 3, 7]
> [1, 2, 3, 4, 5, 6, 7, 8, 9]
```

### optimized to exit if no swaps occur	
```
def bubble_sort2(A):
	for i in range (0, len(A) - 1):
		done = True
		for j in range (0, len(A) - i - 1):
			if A[j] > A[j+1]:
				A[j], A[j+1] = A[j+1], A[j]
				done = False
		if done:
			return
```






