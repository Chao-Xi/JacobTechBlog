# What is a MaxHap

* **Complete Binary Tree**
* **Every node <= Parents**
* **Parent is bigger than children**

```
                          25
                        /    \
                       16    24
                      / \   /  \
                     5  11 24   1
                    / \ /
                   2  3 5
```

## MaxHap is FAST!

#### 1. Insert in `O(log n)`
#### 2. Get Max in `O(1)`
#### 3. Remove Max in `O(log n)`

```
                          25
                        /    \
                       16    24
                      / \   /  \
                     5  11 24   1
                    / \ /
                   2  3 5
```

#### Easy to implement using an Array

```
                          25
                          (1)
                        /    \
                       16    24
                       (2)   (3)
                      / \   /  \
                     5  11 24   1
                    (4) (5)(6) (7)
                    / \ /
                   2  3 5
                  (8)(9)(10)

```

```
 1 |  2 |  3 |  4 |  5 |  6 |  7 | 8  |  9 | 10 |
-- | -- | -- | -- | -- | -- | -- | -- | -- | -- 
25 | 16 | 24 |  5 | 11 | 19 |  1 |  2 |  3 |  5 |
```

## MaxHap Operations

* **Push (Insert)**
* **Peek (get Max)**
* **Pop (Remove max)**

```
                          25
                        /    \
                       16    24
                      / \   /  \
                     5  11 19   1
                    / \ /
                   2  3 5
```

### Push 

* Add value to end of array
* Float it UP to its proper postion

**1. push 12**

```
                          25
                        /    \
                       16    24
                      / \   /  \
                     5  11 19   1
                    / \ / \
                   2  3 5 [12]
```

**2. `12>11?` => True**

```
                          25
                        /    \
                       16    24
                      / \   /  \
                     5 [12] 19   1
                    / \ / \
                   2  3 5  11
```

**2. `12>16?` => False**

```
                          25
                        /    \
                       16    24
                      / \   /  \
                     5  12 19   1
                    / \ / \
                   2  3 5  11
```

### Pop

* Move max to the end of array
* Delete it
* **Bubble Down** the item at index 1 to its proper position 
* **Return max**


**1.Pop out the max value of the heap**

```
                          25
                        /    \
                       16    24
                      / \   /  \
                     5  11 19   1
                    / \ /
                   2  3 5
```

**2.swap the the max value with last value of heap and pop out**

```
                          [5]
                        /    \
                       16    24
                      / \   /  \
                     5  11 19   1
                    / \ 
                   2  3
```

**3. `5>24?` => False**

```
                          24
                        /    \
                       16    [5]
                      / \   /  \
                     5  11 19   1
                    / \ 
                   2  3
```

**4. `5>19?` => False**

```
                          24
                        /    \
                       16    19
                      / \   /  \
                     5  11 [5]  1
                    / \ 
                   2  3
```


## Code Example

```
# Python MaxHeap
# public functions: push, peek, pop
# private functions: __swap, __floatUp, __bubbleDown

class MaxHeap:
	# constructor receive a list of items to insert into the heap
	def __init__(self, items=[]):
		super().__init__()
		self.heap = [0]
	# Createa new list called heap and place the value 0 which is index 0 and we're not going use that position	
		for i in items:
	# for loop to insert all items we passed in
			self.heap.append(i)
	# append each to list once a time
			self.__floatUp(len(self.heap) - 1)
	# after append it, float it up to the proper position
	

	def push(self, data):
		self.heap.append(data)
		self.__floatUp(len(self.heap) - 1)
	# receive the day, append it to the end of the heap 
	# float it up to the proper position

	def peek(self):
		if self.heap[1]:
			return self.heap[1]
	# checck at least we have one value on the heap
	# if we do, return the the first value of the heap list
		else:
			return False
	# if not, return falsem beacuse heap is empty


    # There possibilities:
    # Two or more value in the heap: Swap the max value to the very end of heap before we popped it off, the bubble down the value swapped into the top of position
    # Only one value in the heap, simply pop the top of value off the heap, we'll have empty heap after that
    # Empty heap and return false 

	def pop(self):
		if len(self.heap) > 2:
			self.__swap(1, len(self.heap) - 1)
			max = self.heap.pop()
			self.__bubbleDown(1)
		elif len(self.heap) == 2:
			max = self.heap.pop()
		else: 
			max = False
		return max

	def __swap(self, i, j):
		self.heap[i], self.heap[j] = self.heap[j], self.heap[i]
	# swap in python one assignment statements with both two variables
    
	def __floatUp(self, index):
	# float up assume inserted a value at the bottom of heap or at the end of the list and float it up to the proper position
	# If the index we passed in is index 1 (right position), no floating to be done, it's already at the top
		parent = index//2
	# Finding the parent index we're trying o float 
		if index <= 1:
			return
	# index is 1, 
		elif self.heap[index] > self.heap[parent]:
			self.__swap(index, parent)
			self.__floatUp(parent)
    # the index passed in is greater that it's parents
    # swap two
    # then we call float up on the parent node, it's recrusive function will continue until the values reaches its proper position 

	def __bubbleDown(self, index):
	# Insert the value on the top of heap and bubble down to the proper position
		left = index * 2
		right = index * 2 + 1
		largest = index
		if len(self.heap) > left and self.heap[largest] < self.heap[left]:
			largest = left
		if len(self.heap) > right and self.heap[largest] < self.heap[right]:
			largest = right
	# compare left and right child with index
		if largest != index:
			self.__swap(index, largest)
			self.__bubbleDown(largest)

m = MaxHeap([95, 3, 21])
m.push(10)
print(str(m.heap[0:len(m.heap)]))
print(str(m.pop()))
```

```
           95
         /    \
        3     21
```

**push 10**

```
           95
         /    \
        3     21 
      /
    [10]
```

```
           95
         /    \
       10     21 
      /
    3
```

**first one is 0**

```
[0, 95, 10, 21, 3]
```

**pop off 95**

```
95
```



