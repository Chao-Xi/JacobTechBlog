# AWS DNS & Route 53

## Courses List

1. [DNS](1Dns_Intro.md)
2. [Route53 The Basics - Lab](2route53_lab.md)
3. [Routing Policy](3route53_routing_policy.md)

## Exam Tips 

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


### Remember the different routing policies and their use cases;

* Simple 
* Weighted 
* Latency 
* Failover 
* Geolocation 



