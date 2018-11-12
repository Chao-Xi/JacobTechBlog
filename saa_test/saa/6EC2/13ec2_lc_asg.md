# Launch Configurations & Auto Scaling Groups

## Create Launch Configurations Firstly

![Alt Image Text](images/13_1.jpg "body image")


## Create AutoScaling Group based on Launch Configurations

![Alt Image Text](images/13_2.jpg "body image")

* ASG WILL automatically spreads these three instances to three subnets
* Health check grace period: **150s**  150s is set as a session for instances are totally launched and all packages installed. (Apache installed in this exp.)

### create alarm for ASG

![Alt Image Text](images/13_3.jpg "body image")


### create alarm for ASG policies to adjust the capacity of this group

![Alt Image Text](images/13_4.jpg "body image")


### send notification for ASG

![Alt Image Text](images/13_5.jpg "body image")