# Working with data in Hive

## Understanding table structure in Hive

### What is Hive table

A defined table-like structure we can use to run SQL queries against; 

Hive typically just does things on Read. 

So, the **schemas** defined at the **time that you actually issue your query**.


### Hive table types

**a table available in two main types, `managed` and `external`**

#### Managed

* **Hive owns data**

* **Data no longer is in its original location**

 * When you create a managed table in Hive, the system actually moves the data from its original location into the Hive warehouse.

* **Format follows the typical SQL convention**

 * **This data lives in a specific location in Hadoop**, in HDFS and it's known as the Hive warehouse. The path is User, Hive, and Warehouse.


#### External

* Definition only
* Points to files in HDFS
* More fragile


## Creating tables in hive

### What's in store

* Open Hue Metastore manager
* upload file
* Browse data and other tables

### Demo on `hue 5.13`

* **imported data** : `Exercise Files > data > CpgsleyServices-SalesData-US-Nocommas.csv`
* **Browsers -> tables**
* import tables

**Encounter errors: Name node is in safe mode**

RESOLUTION: Run the command below using the `HDFS OS user` to disable safe mode:

```
sudo -u hdfs hadoop dfsadmin -safemode leave
```
![Alt Image Text](images/hive/3_1.png "Body image")

**Import to table: `Name: sales_nocomma`**


![Alt Image Text](images/hive/3_2.png "Body image")
![Alt Image Text](images/hive/3_3.png "Body image")
![Alt Image Text](images/hive/3_4.png "Body image")

## Handling CSV file in Hive

### Quoted CSV in Hive
 
* The default engine for CSV files in Hive expects that there are no quoted strings containing commas. This is a problem because many CSV files contained quoted values that contain commas. 
* To have Hive handle this properly we need to use a **custom engine, called `SerDe`, to process the data.** 

### What's in Store 

#### 1. Open HUE Metastore Manager 


2. Upload file with quoted strings 
3. Upload custom SerDe 
4. Apply `SerDe` to our table settings 
