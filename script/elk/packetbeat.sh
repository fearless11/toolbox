#!/bin/bash
# date: 2021/09/08
# auth: vera
# desc: query packetbeat api status


yesterday=`date +%Y.%m.%d -d '1 days ago'`
index="packetbeat-7.5.1-${yesterday}"

get_api_request(){
    curl -s -u root:root  -XGET "http://127.0.0.1:9200/${index}/_search" -H 'Content-Type: application/json' -d'{  "size": 0,   "query": {    "constant_score": {      "filter": {        "terms": {          "server.ip": [            "10.19.202.135",            "10.19.203.135",            "10.19.152.135",            "10.19.153.135"          ]        }      },      "boost": 1.2    }  }  , "aggs": {    "status": {      "terms": {        "field": "http.response.status_code",        "size": 10      }    }  }}' | jq &> /tmp/alarmStatusCode.txt

    # raw data: date no200 is200 total rate 
    cat /tmp/alarmStatusCode.txt | egrep -w 'key|doc_count' | awk '{if($0~/key/) printf $0; else print $0}' | awk '{ total=total+$NF; if($0~/key": 200,/) is200=$NF; else no200=no200+$NF}END{ print "'${yesterday}' " no200/10000,is200/10000,total/10000,is200/total*100}' &>> alarmApiRequest.txt
}


get_api_time(){
    curl -s -u root:root  -XGET "http://127.0.0.1:9200/${index}/_search" -H 'Content-Type: application/json' -d'{  "size": 0,   "query": {    "constant_score": {      "filter": {        "terms": {          "server.ip": [            "10.19.202.135",            "10.19.203.135",            "10.19.152.135",            "10.19.153.135"          ]        }      },      "boost": 1.2    }  }, "aggs": {    "response_time": {    "range": {      "field": "event.duration",      "ranges": [          { "from": 0,  "to" :   10000000 },          { "from" : 10000000, "to" : 100000000 },          { "from" : 100000000, "to" : 500000000 },          { "from" :  500000000, "to" : 1000000000 },          { "from" : 1000000000 }      ]    }    }  }}' | jq &> /tmp/alarmResponsetime.txt

    # raw data: date 0~10ms 10~100ms 100~500ms 500~1000ms 1s+
    cat /tmp/alarmResponsetime.txt | egrep -w 'from|doc_count' | awk '{if($0~/from/) printf $0; else print $0}' | tr ',' ' ' | awk 'BEGIN{ printf "'${yesterday}' " }{ if($2==0)  printf $NF/10000" " ; else if($2==10000000)  printf $NF/10000" "; else if($2==100000000)  printf $NF/10000" "; else if($2==500000000)  printf  $NF/10000" " ; else if($2==1000000000)  print  $NF/10000}'  &>> alarmApiTime.txt
}


get_api_request
get_api_time


