## Get Log Percentiles

1. The code is written with python3 
2. Make sure the directory "/var/log/httpd/" is your absolute path on your server

1.Method one 

* Time Complexity: O(n²)
* Space Complexity: O(n²)

* `lines_to_list()`: Two nested loop and allocation of "rtime" inside the loops, so the time&space complexity are both O(n²)
* `percentile()`: Simple algorithmic operation, so the time&space complexity are both O(1)
* `log_list.sort()`: The time complexity is n and space complexity is also n
* The total time and space complexity are both `O(n²) + n * O(1) = O(n²)` 


2.Method two

* Time Complexity:  O(n²)
* Space Complexity: O(n²)

* `lines_to_list()` same as above

3.memory_time_Test 

* `pip3 install pympler`
* `pip3 install psutil`
* run two python scripts and output memory and time usage separately 