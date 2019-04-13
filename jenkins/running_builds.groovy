curl http://192.168.33.12:8080/job/Parameter-Category-Test1/
curl http://192.168.33.12:8080/job/Parameter-Category-Test1/api/json
curl http://192.168.33.12:8080/job/Parameter-Category-Test1/api/json?tree=builds


http://192.168.33.12:8080/api/

http://192.168.33.12:8080/api/json?pretty=true

http://192.168.33.12:8080/me/configure

curl -u admin:token http://192.168.33.12:8080/api/json?pretty=true

http://192.168.33.12:8080/api/json?pretty=true$tree=jobs[name,color]

http://192.168.33.12:8080/job/Parameter-Category-Test1/api/json?tree=builds[number]&pretty=ture



http://192.168.33.12:8080/job/Parameter-Category-Test1/api/json?tree=builds[number,id,result,timestamp]&pretty=true

http://192.168.33.12:8080/job/Parameter-Category-Test1/api/json?tree=builds[number,id,result,timestamp,status]&pretty=true


// All builds states
http://192.168.33.12:8080/job/Parameter-Category-Test1/api/json?tree=builds[building]&pretty=true


//check the job build or not
http://192.168.33.12:8080/job/Parameter-Category-Test1/api/json?tree=builds&building=true


http://192.168.33.12:8080/job/Parameter-Category-Test1/api/json?tree=builds[*]&pretty=true




//Final of builds

http://192.168.33.12:8080/job/Parameter-Category-Test1/api/json?tree=builds[building,id,number,result]&pretty=true 


data=`curl http://192.168.33.12:8080/job/Parameter-Category-Test1/api/json?tree=builds[building,id,number,result]&pretty=true `

`curl http://192.168.33.12:8080/job/Parameter-Category-Test1/api/json?tree=builds[building,id,number,result]`