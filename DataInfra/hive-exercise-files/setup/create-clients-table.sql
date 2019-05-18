create table clients (
    Name                string,
    Symbol              string,
    LastSale            double,
    MarketCapLabel      string,
    MarketCapAmount     bigint,
    IPOyear             int,
    Sector              string,
    industry            string,
    SummaryQuote        string
)
row format serde 'com.bizo.hive.serde.csv.CSVSerde'
stored as textfile;
