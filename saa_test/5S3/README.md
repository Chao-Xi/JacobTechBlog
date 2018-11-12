# AWS S3

## Courses List

1. [AWS S3 Overview](1S3_Overview.md)
2. [S3 - Versioning Lab](2S3_Versioning.md)
3. [LifeCycle Management, IA S3 & Glacier Lab](3S3_LifeCycle.md)
4. [Introduction to CloudFront](4CDN_Cloudfront.md)
5. [S3 Security & Encryption](5Security_Encryption.md)
6. [Storage Gateway](6Storage_Gateway.md)
7. [S3 Import and Export](7Import_Export.md)

## Exam Tips

### AWS S3 Overview

* Remember S3 is object based i.e. allows you to upload files
* Files can be from 1 Byte to 5Tb
* There is unlimited storage
* Files are stored in Buckets
* S3 is a universal namespace, that is, **names must be unique globally**
* https://s3-eu-west-1.amazonaws.com/bucketname


#### 1.Read after Write consistency for PUTS of new Object(can take some time to propagate)
#### 2.Eventual Consistency for overwrite PUTS and DELETES

### Which means:

1. `Add` new object is an instance operation
2. `Update` and `Delete` may take some times, not immediately
3. `UPDATE` and `Delete` may takes some times to propagate, which means after you update object and read immediately, you may read the old version of the object. 

### s3 storage Classes/Tiers

1. **S3** (durable, immediately available, **frequently accessed**)
2. **S3 - IA** (durable, immediately available, **infrequently accessed**)
3. **S3 - RRS** Reduced Redundancy Storage (data that is easily reproducible, such as thumb nails)
4. **Glacier** - **Archived data, where you can wait 3-5 hours before accessing**.

### Remember the core fundamentals of S3

* Key (name)
* Value (data)
* Version ID
* Metadata
* Access control lists

### S3 - Versioning

1. Stores all versions of an object (including all writes and even if you delete an object)
2. Great backup tool
3. **Once enabled, Versioning cannot be disabled , only suspended**
4. Integrates with Lifecycle rule
5. **Versioning's MFA Delete capability, which users multi-factor authentication, can be used to provide an additional layer of security**
6. **Cross Religion Replication, requires versioning enabled on source bucket**


### S3 - LifeCycle Management

* Can be used in conjunction with versioning
* Can be applied to current versions and pervious versions
* Following actions can now be done;
  * Transition to the Standard - Infrequent Access Storage Class (128Kb and 30 days after the creation date)
  * Archive to the Glacier storage Class (do days after IA, if relevant)
  * Permanently Delete


### S3 - CloudFront

* Edge Location - This is the location where `content will be cached`. `This is separate to an AWS Region/AZ`
* Origin - This is the origin of all the files that the CDN will distribute. This can be either an `S3 bucket`, an `EC2 instance`, an `Elastic Load Balancer` or `Route53`
* Distribution - This is the name given the CDN which consists pf a collection of Edge Locations
  * Web Distribution - Typically used for Websites
  * RTMP - Used for Media Streaming
Edge locations are not just READ only, you can write them too (ie. put object in to them)
* Objects are cached for the life of the TTL(Time to Live)
* You can clear the cached objects, but you will be charged


### Securing your buckets

#### 1.By default, all newly created buckets are `PRIVATE`
#### 2.You can setup access control to your buckets using

* **Bucket Policies**
* **Access Control Lists**

#### 3.S3 buckets can be configured to crate access logs which log all requests made to the S3 bucket. This can be done to another bucket


### Encryption

#### 1.In Transit

**SSL/TLS**


#### 2.At reset

##### Server Side Encryption

* S3 Managed Keys - **SSE-S3(S3 manage the data and master encryption keys)**
* AWS Key Management Services, Managed Keys - **SSE-KMS(WS manage the data key but you manage the master key in AWS KMS.)**
* Server Side Encryption with Customer Provided Keys - **SSE-C(you manage the encryption key)**

### Storage Gateway

#### Gateway Stored Volumes

**Entire Dataset is stored on site and is asynchronously backed up to S3**

#### Gateway Cached Volumes

**Entire Dataset is stored on S3 and the most frequently accessed data is cached on site**

#### Gateway Virtual Tape Library (VTL)

**Used for backup and uses popular backup applications like by NetBackup, Backup Exec, Veam etc.**

### S3 Import and Export

#### Import/Export Disk

* Import to EBS
* Import to S3
* Import to Glacier
* Export from S3

#### Import/Export Snowball

* Import to S3
* Export to S3
