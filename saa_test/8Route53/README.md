# AWS DNS & Route 53

## Courses List

1. [DNS](1Dns_Intro.md)
2. [Route53 The Basics - Lab](2route53_lab.md)
3. [Routing Policy](3route53_routing_policy.md)

## Exam Tips 

#### CNAMES(Canonical Name) can be used to resolve one domain name to another
#### Alias Records: are used to map resource `record sets` in your `hosted zone` to `Elastic Load Balancers`, `CloudFront distributions`, or `S3 buckets` that are configured as websites.


### Key difference

A CNAME can't be used for naked domain names (zone apex). You **can't have a CNAME** for `http://acloud.guru`, it must be either an **A record or an Alias**.

**Amazon Route 53 will automatically reflect those changes in DNS answers for IP changes of load balancing**

* ELB's do not have pre-defined IPv4 addresses, you resolve to them using a DNS name. 
* Understand the difference between an Alias Record and a CNAME. 
* Given the choice, always choose an Alias Record over a CNAME. 

| CNAME Records | Alias Records   |
|:------------- |:---------------:|
| You can't create a CNAME record at the zone apex. For example, if you register the DNS name example.com, the zone apex is example.com.     | You can create an alias record at the zone apex. |        
| Route 53 charges for CNAME queries.      | Route 53 doesn't charge for alias queries to AWS resources.         |    
| A CNAME record redirects queries for a domain name regardless of record type | Route 53 responds to a DNS query only when the name and type of the alias record matches the name and type in the query.        |
| A CNAME record can point to any DNS record that is hosted anywhere.      | An alias record can only point to selected AWS resources or to another record in the hosted zone that you're creating the alias record in.        |    
| A CNAME record appears as a CNAME record in response to dig or nslookup queries. | An alias record appears as the record type that you specified when you created the record, such as A or AAAA. The alias property is visible only in the Route 53 console or in the response to a programmatic request, such as an AWS CLI `list-resource-record-sets` command.        |


## Route53 The Basics - Lab

* create public hosted zone
* copy `4 name severs(NS) value` and paste Name Severs in `Domain Registrars`
* Create `Record Set` and point **Alias to created ELB**

### Remember the different routing policies and their use cases;

* **Simple:** 
* **Weighted** : Weighted Routing Policies let you split your traffic based on different weights assigned.
* **Latency**: Latency based routing allows you to route your traffic based on the **lowest network latency** for your end user
* **Failover**: Route53 will monitor the health of your primary site using a **health check**.
* **Geolocation**: Geolocation routing lets you choose where your traffic will be **sent based on the geographic location of your users** (ie the location from which DNS queries originate). 

### Active-Active and Active-Passive Failover

#### 1.Active-Active Failover (All)

configuration want all of your resources to be available the majority of the time
When a resource becomes unavailable, Route 53 can detect that it's unhealthy and stop including it when responding to queries.

#### 2.Active-Passive Failover (Primary, secondary)

* Use an active-passive failover configuration when you want a **primary resource or group of resources to be available the majority of the time** 
 
* you want a **secondary resource or group of resources to be on standby in case all the primary resources become unavailable**.

* When responding to queries, Route 53 includes only the healthy primary resources. 

* If **all the primary resources are unhealthy**, **Route 53 begins to include only the healthy secondary resources in response to DNS queries**.

### ways

* Configuring Active-Passive Failover with One Primary and One Secondary Resource
* Configuring Active-Passive Failover with Multiple Primary and Secondary Resources
* Configuring Active-Passive Failover with Weighted Records







