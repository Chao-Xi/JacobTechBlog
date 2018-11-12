# Raid, Volume and Snapshots

## RAID = Redundant Array of Independent Disks

### RAID 0 - Striped, No Redundancy, Good Performance
### RAID 1 - Mirrored, Redundancy
### RAID 5 - Good for reads, bad for writes, AWS does not recommend ever putting RAID 5's on EBS
### raid 10 - Striped & Mirrored, Good Redundancy, Good Performance

## Create Windows Instance

### 1.change exist SG inbound and add `RDP` rule

![Alt Image Text](images/6_1.jpg "body image")

### 2.create windows 2012 server

![Alt Image Text](images/6_2.jpg "body image")

#### Add new 4 storages

![Alt Image Text](images/6_3.jpg "body image")

#### Attach SG to it

![Alt Image Text](images/6_4.jpg "body image")

#### Download key for windows server password 

![Alt Image Text](images/6_5.jpg "body image")


#### Get windows password and retrieve windows password for admin

![Alt Image Text](images/6_6.jpg "body image")

![Alt Image Text](images/6_7.jpg "body image")

![Alt Image Text](images/6_8.jpg "body image")

## Login into Windows Instance and change 4 new volumes to striped volume

![Alt Image Text](images/6_9.jpg "body image")

#### Delete these 4 volumes

![Alt Image Text](images/6_10.jpg "body image")

#### Change these 4 volumes to new striped volume

![Alt Image Text](images/6_11.jpg "body image")

![Alt Image Text](images/6_13.jpg "body image")

![Alt Image Text](images/6_14.jpg "body image")

![Alt Image Text](images/6_15.jpg "body image")

![Alt Image Text](images/6_16.jpg "body image")

![Alt Image Text](images/6_17.jpg "body image")


## How can I take a Snapshot of a RAID Array?

**Problem** - Take a snapshot, the snapshot `excludes data held in the cache` by applications and the OS. 

This tends not to matter on a single volume, however using multiple volumes in a RAID array, this can be a problem due to interdependencies of the array. 


###  Solution - Take an application consistent snapshot. 


## How can I take a Snapshot of a RAID Array? 

* Stop the application from writing to disk. 
* Flush all caches to the disk. 

### How can we do this? 

* Freeze the file system 
* Unmount the RAID Array 
* Shutting down the associated EC2 instance. 
