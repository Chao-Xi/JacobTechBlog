create table sales_all_years (RowID smallint, OrderID int, OrderDate date, OrderMonthYear date, Quantity int, Quote float, DiscountPct float, Rate float, SaleAmount float, CustomerName string, CompanyName string, Sector string, Industry string, City string, ZipCode string, State string, Region string, ProjectCompleteDate date, DaystoComplete int, ProductKey string, ProductCategory string, ProductSubCategory string, Consultant string, Manager string, HourlyWage float, RowCount int, WageMargin float)
partitioned by (yr int)
row format serde 'com.bizo.hive.serde.csv.CSVSerde'
stored as textfile;


-- add the partitions
alter table sales_all_years
add partition (yr=2009)
location '2009/';

alter table sales_all_years
add partition (yr=2010)
location '2010/';

alter table sales_all_years
add partition (yr=2011)
location '2011/';

alter table sales_all_years
add partition (yr=2012)
location '2012/';
