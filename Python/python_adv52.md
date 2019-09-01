# Run Code Concurrently Using the Threading and Concurrent Module

## Thread module in simple way

### No thread module： Sequentially running

```
import time
import threading

start = time.perf_counter()

def do_something():
    print('Sleeping 1 second...')
    time.sleep(1)
    print('Do Sleeping...')


do_something()
do_something()

finish = time.perf_counter()
print(f'Finished in {round(finish-start, 2)} second(s)')
```

```
Do Sleeping...
Sleeping 1 second...
Do Sleeping...
Finished in 2.01 second(s)
```

**Finished in 2.01 second(s)**

## Thread module

### `threading.Thread(target=do_something)` run thread 

**Just passing in the name of the function**

```
t1 = threading.Thread(target=do_something) 
t2 = threading.Thread(target=do_something) 

t1.start()
t2.start()

# Sleeping 1 second...
# Sleeping 1 second...
# Finished in 0.0 second(s)
# Do Sleeping...
# Do Sleeping...
```

**Finished in 0.0 second(s)**


### Thread finish before calculating the finish time

```
t1 = threading.Thread(target=do_something) 
t2 = threading.Thread(target=do_something) 

t1.start()
t2.start()

t1.join()    
t2.join()

# Sleeping 1 second...
# Sleeping 1 second...
# Do Sleeping...
# Do Sleeping...
# Finished in 1.01 second(s)
```

### Run thread in loop

```
import time
import threading

start = time.perf_counter()

# With arg pass in 
def do_something_var(seconds):
    print(f'Sleeping {seconds} second(s)...')
    time.sleep(seconds)
    print('Do Sleeping...')

threads = [] # List of thread

for _ in range(10):
    # t = threading.Thread(target=do_something)
    t = threading.Thread(target=do_something_var, args=[2])  # Finished in 2.0 second(s)
    t.start()
    threads.append(t)

for thread in threads:
    thread.join()
# Finished in 1.0 second(s)

finish = time.perf_counter()
print(f'Finished in {round(finish-start, 2)} second(s)')

# Sleeping 2 second(s)...
# ...
# Sleeping 2 second(s)...
# Do Sleeping...
# ...
# Do Sleeping...
# Finished in 2.0 second(s)
```



* `_` is **throwable variable** which means we're not using anything whithin the loop


## Concurrent to run thread

```
import concurrent.futures
import time

start = time.perf_counter()

def do_something_var(seconds):
    print(f'Sleeping {seconds} second(s)...')
    time.sleep(seconds)
    return f'Do Sleeping...{seconds}'

with concurrent.futures.ThreadPoolExecutor() as executor:
	results = [executor.submit(do_something_var, 1) for _ in range(10)]
	

for f in concurrent.futures.as_completed(results):
        print(f.result())
 
finish = time.perf_counter()

print(f'Finished in {round(finish-start, 2)} second(s)')

# Finished in 1.0 second(s)
``` 

* `[executor.submit(do_something_var, 1) for _ in range(10)]`: Lists Comprehensions

### With pass in variable

```
with concurrent.futures.ThreadPoolExecutor() as executor:
	secs = [5, 4, 3, 2, 1]
	results = [executor.submit(do_something_var, sec) for sec in secs]
	
	for f in concurrent.futures.as_completed(results):
	        print(f.result())
  
# Do Sleeping...1
# Do Sleeping...2
# Do Sleeping...3
# Do Sleeping...4
# Do Sleeping...5
# Finished in 5.01 second(s)
```

### With `executor.map()` to loop the threads

```
with concurrent.futures.ThreadPoolExecutor() as executor:
	secs = [5, 4, 3, 2, 1]
	
	results = executor.map(do_something_var, secs)
	
	for result in results:
        print(result)
   
   for f in concurrent.futures.as_completed(results):
        print(f.result())
        
# Do Sleeping...5
# Do Sleeping...4
# Do Sleeping...3
# Do Sleeping...2
# Do Sleeping...1
# Finished in 5.01 second(s)
```

## Download images （Using multiple threads to download images)

### `downimages.py`

```
# download the images
import requests
import time
import concurrent.futures
import os


img_urls = [
    'https://images.unsplash.com/photo-1516117172878-fd2c41f4a759',
    'https://images.unsplash.com/photo-1532009324734-20a7a5813719',
    'https://images.unsplash.com/photo-1524429656589-6633a470097c',
    'https://images.unsplash.com/photo-1530224264768-7ff8c1789d79',
    'https://images.unsplash.com/photo-1564135624576-c5c88640f235',
    'https://images.unsplash.com/photo-1541698444083-023c97d3f4b6',
    'https://images.unsplash.com/photo-1522364723953-452d3431c267',
    'https://images.unsplash.com/photo-1513938709626-033611b8cc03',
    'https://images.unsplash.com/photo-1507143550189-fed454f93097',
    'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e',
    'https://images.unsplash.com/photo-1504198453319-5ce911bafcde',
    'https://images.unsplash.com/photo-1530122037265-a5f1f91d3b99',
    'https://images.unsplash.com/photo-1516972810927-80185027ca84',
    'https://images.unsplash.com/photo-1550439062-609e1531270e',
    'https://images.unsplash.com/photo-1549692520-acc6669e2f0c'
]

t1 = time.perf_counter()

target_dir = "image/"

def download_image(img_url):
    img_bytes = requests.get(img_url).content
    img_name = img_url.split('/')[3]
    img_name = f'{img_name}.jpg'
    fullname = os.path.join(target_dir, img_name)

    with open(fullname, 'wb') as img_file:
        img_file.write(img_bytes)
        print(f'{img_name} was downloaded...')


with concurrent.futures.ThreadPoolExecutor() as executor:
    executor.map(download_image, img_urls)


t2 = time.perf_counter()

print(f'Finished in {t2-t1} seconds')

# Finished in 11.064478837 seconds
```

**Download images to special dir**

```
import os
...
target_dir = "image/"
...
	img_name = f'{img_name}.jpg'
	fullname = os.path.join(target_dir, img_name)
...
```