# Elasticache

## What is Elasticache 

ElastiCache is a web service that makes it easy to deploy, operate, and **scale an in-memory cache in the cloud**. 

##### The service improves the performance of web applications by allowing you to retrieve information from fast, managed, in-memory caches, instead of relying entirely on slower disk-based databases. 

Amazon ElastiCache can be used to significantly **improve latency and throughput for many read-heavy application workloads** (such as social networking, gaming, media sharing and Q&A portals) or **compute-intensive workloads** (such as a recommendation engine). 


Caching improves application performance by **storing critical pieces of data in memory for low-latency access.** Cached information may include the results of `I/O-intensive database queries` or the results of `computationally-intensive calculations`.


## Types of Elasticache  

### Memcached

**A widely adopted memory `object caching system`.** ElastiCache is protocol compliant with Memcached, so popular tools that you use today with existing Memcached environments will work seamlessly with the service.


### Redis
 
**A popular open-source in-memory `key-value store` that supports data structures such as sorted sets and lists**. ElastiCache supports `Master / Slave replication` and `Multi-AZ` **which can be used to achieve cross AZ redundancy**. 


## Elasticache Exam Tips 

* Typically you will be given a scenario where a particular database is **under a lot of stress/load**. You may be asked which service you should use to alleviate this. 


* Elasticache is a good choice if your database is particularly read heavy and not prone to frequent changing. 

* Redshift is a good answer if the reason your database is feeling stress is because management keep running OLAP transactions on it etc. 

