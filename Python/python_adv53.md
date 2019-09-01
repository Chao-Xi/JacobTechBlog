# Run Code in Parallel Using the `Multiprocessing` AND `Concurrent` Module

**This is CPU bound process**

## 1.Simple multiprocessing

### Before using multiprocessing

```
import time
import multiprocessing

start = time.perf_counter()

def do_something():
    print(f'Sleeping 1 second(s)...')
    time.sleep(1)
    print('Do Sleeping...')

do_something()
do_something()

finish = time.perf_counter()

print(f'Finished in {round(finish - start, 2)} second(s)')
```

### Using multiprocessing => Finish

```
import time
import multiprocessing

start = time.perf_counter()

def do_something():
    print(f'Sleeping 1 second(s)...')
    time.sleep(1)
    print('Do Sleeping...')

p1 = multiprocessing.Process(target=do_something)
p2 = multiprocessing.Process(target=do_something)

p1.start()
p2.start()

finish = time.perf_counter()

print(f'Finished in {round(finish - start, 2)} second(s)')
```

```
Finished in 0.0 second(s)   #This is not right
Sleeping 1 second...
Sleeping 1 second...
Do Sleeping...
Do Sleeping...
```

### Using `join` in multiprocessing

```
...

p1.start()
p2.start()

p1.join()
p2.join()

...
```
```
Sleeping 1 second...
Sleeping 1 second...
Do Sleeping...
Do Sleeping...
Finished in 1.01 second(s)
```

### Using multiprocessing with arguments in list

```
import time
import multiprocessing

start = time.perf_counter()

def do_something(seconds):
    print(f'Sleeping {seconds} second(s)...')
    time.sleep(seconds)
    print('Do Sleeping...')
 
processes = []

for _ in range(10):
    p = multiprocessing.Process(target=do_something, args=[1.5])
    p.start()
    processes.append(p)

for process in processes:
    process.join()
    
finish = time.perf_counter()

print(f'Finished in {round(finish - start, 2)} second(s)')
```

```
#  Finished in 1.52 second(s) 
```

## 2.Using multiprocessing with concurrent

### With simple executor

```
import time
import concurrent.futures

start = time.perf_counter()

def do_something(seconds):
    print(f'Sleeping {seconds} second(s)...')
    time.sleep(seconds)
    return f'Done Sleep...{seconds}'

with concurrent.futures.ProcessPoolExecutor() as executor:
	f1 = executor.submit(do_something, 2)
   print(f1.result())

finish = time.perf_counter()

print(f'Finished in {round(finish-start, 2)} second(s)')
```

```
with concurrent.futures.ProcessPoolExecutor() as executor:
	f1 = executor.submit(do_something, 2)
   print(f1.result())
```

### With comprehensive lists

```
with concurrent.futures.ProcessPoolExecutor() as executor:
	secs = [5, 4, 3, 2, 1]
	# results = [executor.submit(do_something, 1) for _ in range(10)] ❤️
	results = [executor.submit(do_something, sec) for sec in secs]  ❤️
	
	for f in concurrent.futures.as_completed(results):   ❤️
	        print(f.result())

# Done Sleep...5
# Done Sleep...4
# Done Sleep...3
# Done Sleep...2
# Done Sleep...1
```

### With `executor.map()` function

```
import time
import concurrent.futures

start = time.perf_counter()

def do_something(seconds):
    print(f'Sleeping {seconds} second(s)...')
    time.sleep(seconds)
    return f'Done Sleep...{seconds}'

with concurrent.futures.ProcessPoolExecutor() as executor:
	 secs = [5, 4, 3, 2, 1]
	 results = executor.map(do_something, secs)  ❤️
	 
	 for result in results:                      ❤️
        print(result)

finish = time.perf_counter()

print(f'Finished in {round(finish-start, 2)} second(s)')        
        
        
# Done Sleep...5
# Done Sleep...4
# Done Sleep...3
# Done Sleep...2
# Done Sleep...1
```

## 3.Using multiprocessing(CPU bound) to download images

```
import time
import concurrent.futures
from PIL import Image, ImageFilter
# CPU bound operation since used multiprocess while thread is I/O bound operation

img_names = [
    'photo-1549692520-acc6669e2f0c.jpg',
    'photo-1550439062-609e1531270e.jpg',
    'photo-1493976040374-85c8e12f0c0e.jpg',
    'photo-1504198453319-5ce911bafcde.jpg',
    'photo-1507143550189-fed454f93097.jpg',
    'photo-1513938709626-033611b8cc03.jpg',
    'photo-1516117172878-fd2c41f4a759.jpg',
    'photo-1516972810927-80185027ca84.jpg',
    'photo-1522364723953-452d3431c267.jpg',
    'photo-1524429656589-6633a470097c.jpg',
    'photo-1530122037265-a5f1f91d3b99.jpg',
    'photo-1530224264768-7ff8c1789d79.jpg',
    'photo-1532009324734-20a7a5813719.jpg',
    'photo-1541698444083-023c97d3f4b6.jpg',
    'photo-1564135624576-c5c88640f235.jpg'
]

dir_img_names = []

for img in img_names:
    img_name = f'image/{img}'
    dir_img_names.append(img_name)

# print(dir_img_names)

t1 = time.perf_counter()

size = (1200, 1200)

def process_image(img_name):
    img = Image.open(img_name)

    img = img.filter(ImageFilter.GaussianBlur(15))

    img.thumbnail(size)
    img.save(f'/processed/{img_name}')
    print(f'{img_name} was processed...')

# with concurrent.futures.ThreadPoolExecutor() as executor:   # I/O bound ❤️
with concurrent.futures.ProcessPoolExecutor() as executor: # CPU bound ❤️
    executor.map(process_image, dir_img_names)


t2 = time.perf_counter()

print(f'Finished in {t2-t1} seconds')
```     