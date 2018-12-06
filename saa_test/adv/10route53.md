# Route 53 Overview

### Amazon Route 53 provides three main functions:

* Domain registration
* **Domain Name System (DNS) service**
* Health checking

## Supported DNS Resource Record Types

### 1.A (Address) Format

is an IPv4 address in dotted decimal notation for e.g. 192.0.2.1

### 2.AAAA Format

is an IPv6 address in colon-separated hexadecimal format

### 3.CNAME Format

DNS protocol does not allow creation of a CNAME record for the top node of a DNS namespace, also known as the zone apex for e.g. the DNS name example.com registration, the zone apex is example.com, a CNAME record for example.com cannot be created, but CNAME records can be created for www.example.com,


If a CNAME record is created for a subdomain, any other resource record sets for that subdomain cannot be created for e.g. if a CNAME created for www.example.com, not other resource record sets for which the value of the Name field is www.example.com can be created

### Alias resource record sets

Route 53 supports alias resource record sets, which enables routing of queries to a CloudFront distribution, Elastic Beanstalk, ELB, an S3 bucket 

Alias records help map the apex zone (root domain without the www) records to the load balancer DNS name as the DNS specification requires “zone apex” to point to an ‘A’ record (ip address) and not to an CNAME

### Questions

1.What does Amazon Route53 provide?

**A scalable Domain Name System**

2.Does Amazon Route 53 support NS Records?

**Yes, it supports Name Server records.**

3.Does Route 53 support MX Records?  (**MX (Mail Xchange) Format**)

**Yes**

4.Which of the following statements are true about Amazon Route 53 resource records? Choose 2 answers

* An Alias record can map one DNS name to another Amazon Route 53 DNS name.
* An Amazon Route 53 CNAME record can point to any DNS record hosted anywhere.

5.Which statements are true about Amazon Route 53? (Choose 2 answers)

* **You can register your domain name**
* **Amazon Route 53 can perform health checks and failovers to a backup site in the even of the primary site failure**

6.A customer is hosting their company website on a cluster of web servers that are behind a public-facing load balancer. The customer also uses Amazon Route 53 to manage their public DNS. How should the customer configure the DNS zone apex record to point to the load balancer?

**Create an A record aliased to the load balancer DNS name**

7.A user has configured ELB with three instances. The user wants to achieve High Availability as well as redundancy with ELB. Which of the below mentioned AWS services helps the user achieve this for ELB?

**Route 53**

8.How can the domain’s zone apex for example “myzoneapexdomain com” be pointed towards an Elastic Load Balancer?

**By using an Amazon Route 53 Alias record**

9.You need to create a simple, holistic check for your system’s general availability and uptime. Your system presents itself as an **HTTP-speaking API**. What is the simplest tool on AWS to achieve this with?

**Route53 Health Checks **