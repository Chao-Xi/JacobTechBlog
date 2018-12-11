#### 1.Elastic File System Lab --Update EC2 Mount instructions

1. Go to EC2, then to Security Groups, Choose Security Group and click Actions, then Edit Inbound Rules, Add NFS
2. Install the NFS helper to EC2: `sudo yum install -y amazon-efs-utils`
3. Mount your NFS to EC2: `sudo mount -t efs your-nfs-file-system-id:/ /var/www/html`


#### 2.Deeper insights on kineses

#### 3.A lecture on Redshift (Redshift clustering)

#### 4.Which of the following are true about Amazon S3 - OneZone-IA?

S3 - OneZone-IA is most often used with objects that are easy to re-create.
S3 - OneZone-IA offers 99.50% availability.
S3 - OneZone-IA offers 99.999999999% durability.

* Same low latency and high throughput performance of S3 Standard and S3 Standard-IA
* Designed for durability of 99.999999999% of objects in a single Availability Zone, but data will be lost in the event of Availability Zone destruction
* Designed for 99.50% availability over a given year
* Backed with the Amazon S3 Service Level Agreement for availability
* Supports SSL for data in transit and encryption of data at rest
* Lifecycle management for automatic migration of objects


#### 5.To protect S3 data from accidental deletion and overwriting you should (chose 1 correct answers)

Enable S3 versioning on the bucket

#### 6.What service would you use for an e-commerce customer to perform data analysis in real-time.

**EMR Elastic MapReduce (EMR)**

* Redshift is a data-warehouse service provided by AWS. 
* EMR is used for analytics

Amazon EMR securely and reliably handles a broad set of big data use cases, including log analysis, web indexing, data transformations (ETL), machine learning, financial analysis, scientific simulation, and bioinformatics.

#### 7.Can I create a Read Replica of another Read Replica?

**Amazon RDS for MySQL:** You can create a second-tier Read Replica from an existing first-tier Read Replica. By creating a second-tier Read Replica, y**ou may be able to move some of the replication load from the master database instance to a first-tier Read Replica.** Please note that a second-tier Read Replica may lag further behind the master because of additional replication latency introduced as transactions are replicated from the master to the first tier replica and then to the second-tier replica.

**Amazon RDS for PostgreSQL:** Read Replicas of Read Replicas are not currently supported.

#### 8.Which backup architecture will meet these requirements?

A. Backup RDS using automated daily DB backups Backup the EC2 instances using EBS snapshots and supplement with file-level backups to **Amazon Glacier** using traditional enterprise backup software to provide file level restore

**It is no good because it uses Glacier, and the RTO is 2 hours.**

B. Backup RDS using a **Multi-AZ Deployment** Backup the EC2 instances using Amis, and supplement by copying file system data to S3 to provide file level restore.

**It is no good because it uses "Multi-AZ Deployment" as a backup strategy.**

C. Backup RDS database to S3 using Oracle RMAN Backup the EC2 instances using Amis, and supplement with EBS snapshots for individual volume restore

**doesn't mention how it will handle individual file restores**

D.Backup RDS using automated daily DB backups Backup the EC2 instances using AMIs and supplement with file-level backup to S3 using traditional enterprise backup software to provide file level restore

**Correct**


