# Volume vs Snapshot Lab

## Volume vs Snapshot

### Volumes exist on EBS: `Virtual Hard Disk`
### Snapshot exits on S3
### You can take a snapshot of a volume, this will `store that volume on S3`
### Snapshots are point in time copies of Volumes
### Snapshots are `incremental`, this means that only the blocks that have changed since your `last snapshot are move to S3`
### If this is your first snapshot, it may take some time to create



## Create Magnetic Volume (10G)

![Alt Image Text](images/5_1.jpg "body image")


### attach it to an running instance

![Alt Image Text](images/5_2.jpg "body image")

### ssh to instance and lists information about all available or the specified block devices.

![Alt Image Text](images/5_3.jpg "body image")

#### `xvdf` already attach to instance, but no `mount point` currently

### check this vol is file system or not 

```
$ sudo su
$ file -s /dev/xvd
/dev/xvdf: data        #  It's not file system
```

### Transfer this block device to file system


```
$ mkfs -t ext4 /dev/xvdf
# mkfs: make file system
# -t type
# /dev/xvdf : mount location
```
![Alt Image Text](images/5_4.jpg "body image")

### mount `/dev/xvdf` to `/fileserver`

```
$ mkdir /fileserver
$ mount /dev/xvdf /fileserver
```

![Alt Image Text](images/5_5.jpg "body image")

#### add tmp files inside `/fileserver`


### unmount `/dev/xvdf` from `/fileserver`

```
$ umount /dev/xvdf
$ cd /fileserver
$ ls
$ 
```
### create Snapshot of this volume

![Alt Image Text](images/5_6.jpg "body image")

![Alt Image Text](images/5_7.jpg "body image")

### Detach and delete this volume 


![Alt Image Text](images/5_8.jpg "body image")

![Alt Image Text](images/5_9.jpg "body image")


## Create new Volume (gp2 ssd)

### You can change type of volume from snapshot

![Alt Image Text](images/5_10.jpg "body image")


### After it reattached to instance

![Alt Image Text](images/5_11.jpg "body image")

```
$ sudo su
$ file -s /dev/xvd
```

#### It's file system, so you don't have to transfer file system again

![Alt Image Text](images/5_12.jpg "body image")


### mount again and files exist

![Alt Image Text](images/5_13.jpg "body image")


## Volumes vs Snapshots - Security

* **Snapshots of encrypted volumes are encrypted automatically**
* Volumes restored from encrypted snapshots are encrypted automatically
* You can share snapshots, but only if they are unencrypted

#### These snapshots can be shared with other AWS account or made public


## Snapshots of Root Device Volumes

**To create a snapshot for Amazon EBS volumes that servers as root devices, you should stop the instance before taking the snapshot**

