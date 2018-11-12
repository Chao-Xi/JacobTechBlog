# Instance Metadata Data

## Get EC2 Instance Metadata

### 1.ssh to your EC2 instance

```
curl http://169.254.169.254/latest/meta-data/
ami-id
ami-launch-index
ami-manifest-path
block-device-mapping/
events/
hostname
instance-action
instance-id
instance-type
local-hostname
local-ipv4
mac
metrics/
network/
placement/
profile
public-hostname
public-ipv4
public-keys/
reservation-id
security-groups
```

```
$ curl http://169.254.169.254/latest/meta-data/public-ipv4
54.233.233.21
```

## Exam Tips

### http://169.254.169.254/latest/meta-data/

 

